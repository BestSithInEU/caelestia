# C++ Development Configuration

# CUDA Configuration
set -x CUDA_HOME /opt/cuda
set -x CUDACXX /opt/cuda/bin/nvcc

# Compiler aliases
alias g++ 'g++ -std=c++20 -Wall -Wextra -pedantic'
alias g++d 'g++ -std=c++20 -Wall -Wextra -pedantic -g -O0 -DDEBUG'
alias g++r 'g++ -std=c++20 -Wall -Wextra -pedantic -O3 -DNDEBUG'
alias g++11 'g++ -std=c++11 -Wall -Wextra -pedantic'
alias g++14 'g++ -std=c++14 -Wall -Wextra -pedantic'
alias g++17 'g++ -std=c++17 -Wall -Wextra -pedantic'
alias g++20 'g++ -std=c++20 -Wall -Wextra -pedantic'
alias g++23 'g++ -std=c++23 -Wall -Wextra -pedantic'

alias clang++ 'clang++ -std=c++20 -Wall -Wextra -pedantic'
alias clang++d 'clang++ -std=c++20 -Wall -Wextra -pedantic -g -O0 -DDEBUG'
alias clang++r 'clang++ -std=c++20 -Wall -Wextra -pedantic -O3 -DNDEBUG'

# Build tools
alias cm 'cmake'
alias cmb 'cmake --build'
alias cmc 'cmake -DCMAKE_BUILD_TYPE=Debug'
alias cmr 'cmake -DCMAKE_BUILD_TYPE=Release'
alias cmg 'cmake -G'
alias cmn 'cmake -G Ninja'
alias cmt 'ctest'
alias cmtv 'ctest -V'

alias mk 'make'
alias mkc 'make clean'
alias mkd 'make debug'
alias mkr 'make release'
alias mkt 'make test'
alias mkj 'make -j(nproc)'

alias ninja 'ninja'
alias nb 'ninja build'
alias nc 'ninja clean'
alias nt 'ninja test'

# Debugging tools
alias gdb 'gdb -q'
alias lldb 'lldb'
alias valgrind 'valgrind --leak-check=full --show-leak-kinds=all'
alias vg 'valgrind'
alias vgf 'valgrind --leak-check=full'
alias vgc 'valgrind --tool=cachegrind'
alias vgp 'valgrind --tool=callgrind'
alias vgh 'valgrind --tool=helgrind'
alias vgm 'valgrind --tool=massif'

# Static analysis
alias cppcheck 'cppcheck --enable=all --suppress=missingIncludeSystem'
alias cpplint 'cpplint --filter=-legal/copyright'
alias clang-tidy 'clang-tidy'
alias clang-format 'clang-format -style=file'
alias cf 'clang-format -i'

# Documentation
alias doxygen 'doxygen'
alias doxy 'doxygen Doxyfile'

# Functions for C++ development
function cpp-new
    if test (count $argv) -eq 0
        echo "Usage: cpp-new <project_name>"
        return 1
    end

    set -l project $argv[1]
    mkdir -p $project/{src,include,tests,build}

    # Create CMakeLists.txt
    echo "cmake_minimum_required(VERSION 3.16)
project($project VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Add executable
add_executable(\${PROJECT_NAME} src/main.cpp)
target_include_directories(\${PROJECT_NAME} PRIVATE include)

# Enable warnings
if(MSVC)
    target_compile_options(\${PROJECT_NAME} PRIVATE /W4)
else()
    target_compile_options(\${PROJECT_NAME} PRIVATE -Wall -Wextra -pedantic)
endif()

# Debug/Release flags
if(CMAKE_BUILD_TYPE STREQUAL \"Debug\")
    target_compile_definitions(\${PROJECT_NAME} PRIVATE DEBUG)
else()
    target_compile_definitions(\${PROJECT_NAME} PRIVATE NDEBUG)
endif()" > $project/CMakeLists.txt

    # Create main.cpp
    echo "#include <iostream>

int main() {
    std::cout << \"Hello, World!\" << std::endl;
    return 0;
}" > $project/src/main.cpp

    # Create .clang-format
    echo "BasedOnStyle: LLVM
IndentWidth: 4
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: Empty
AlwaysBreakTemplateDeclarations: Yes" > $project/.clang-format

    echo "Created C++ project: $project"
    cd $project
end

function cpp-build
    if not test -d build
        mkdir build
    end
    cd build
    cmake .. $argv
    make -j(nproc)
    cd ..
end

function cpp-run
    if test -f build/Makefile
        cd build
        make -j(nproc)
        if test $status -eq 0
            set -l executable (find . -maxdepth 1 -type f -executable | head -1)
            if test -n "$executable"
                $executable $argv
            else
                echo "No executable found"
            end
        end
        cd ..
    else
        echo "No build directory found. Run cpp-build first."
    end
end

function cpp-clean
    if test -d build
        rm -rf build
        echo "Build directory cleaned"
    else
        echo "No build directory to clean"
    end
end

function cpp-debug
    if test (count $argv) -eq 0
        echo "Usage: cpp-debug <executable>"
        return 1
    end
    gdb -q $argv[1]
end

function cpp-profile
    if test (count $argv) -eq 0
        echo "Usage: cpp-profile <executable>"
        return 1
    end
    valgrind --tool=callgrind $argv
    kcachegrind callgrind.out.* 2>/dev/null || echo "Install kcachegrind to view results"
end

function cpp-leak
    if test (count $argv) -eq 0
        echo "Usage: cpp-leak <executable>"
        return 1
    end
    valgrind --leak-check=full --show-leak-kinds=all $argv
end

function cpp-format
    if test (count $argv) -eq 0
        find . -name "*.cpp" -o -name "*.hpp" -o -name "*.h" -o -name "*.cc" | xargs clang-format -i
    else
        clang-format -i $argv
    end
end

function cpp-check
    if test (count $argv) -eq 0
        cppcheck --enable=all --suppress=missingIncludeSystem src/
    else
        cppcheck --enable=all --suppress=missingIncludeSystem $argv
    end
end

function cpp-tidy
    if test -f compile_commands.json
        if test (count $argv) -eq 0
            find src -name "*.cpp" | xargs clang-tidy
        else
            clang-tidy $argv
        end
    else
        echo "No compile_commands.json found. Generate with: cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
    end
end

function cpp-bench
    if test (count $argv) -eq 0
        echo "Usage: cpp-bench <executable>"
        return 1
    end

    echo "Running benchmark..."
    time $argv
    echo ""
    echo "Memory usage:"
    /usr/bin/time -v $argv 2>&1 | grep -E "Maximum resident|User time|System time"
end

# Conan package manager aliases
if type -q conan
    alias conan 'conan'
    alias coi 'conan install'
    alias cob 'conan build'
    alias coc 'conan create'
    alias cop 'conan package'
    alias cos 'conan search'
    alias cou 'conan upload'
    alias cor 'conan remote'
end

# vcpkg package manager
if test -n "$VCPKG_ROOT"
    alias vcpkg '$VCPKG_ROOT/vcpkg'
    alias vci 'vcpkg install'
    alias vcr 'vcpkg remove'
    alias vcs 'vcpkg search'
    alias vcu 'vcpkg update'
    alias vcl 'vcpkg list'
end

# Build2 aliases
if type -q b
    alias b2 'b'
    alias b2c 'b clean'
    alias b2t 'b test'
    alias b2i 'b install'
    alias b2u 'b update'
end

# Compiler explorer shortcut
function godbolt
    if test (count $argv) -eq 0
        open "https://godbolt.org/"
    else
        echo "Paste your code at: https://godbolt.org/"
    end
end

# Quick C++ snippet runner
function cpp
    set -l tmpfile (mktemp /tmp/cpp_snippet.XXXXXX.cpp)

    if test (count $argv) -eq 0
        echo "#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    // Your code here

    return 0;
}" > $tmpfile
        $EDITOR $tmpfile
    else
        echo "#include <iostream>
#include <vector>
#include <string>
#include <algorithm>
using namespace std;

int main() {
    $argv
    return 0;
}" > $tmpfile
    end

    g++ -std=c++20 -o /tmp/cpp_snippet $tmpfile && /tmp/cpp_snippet
    rm -f $tmpfile /tmp/cpp_snippet
end
