# Python and UV Configuration

# Python aliases
alias py 'python3'
alias python 'python3'
alias pip 'python3 -m pip'
alias venv 'python3 -m venv'
alias pydoc 'python3 -m pydoc'
alias pytest 'python3 -m pytest'

# UV (modern Python package manager) — frequent commands are abbrs in config.fish
if type -q uv
    alias uvp 'uv pip'
    alias uvpi 'uv pip install'
    alias uvps 'uv pip sync'
    alias uvpl 'uv pip list'
    alias uvpf 'uv pip freeze'
    alias uvpu 'uv pip uninstall'
    alias uvv 'uv venv'
    alias uvact 'source .venv-linux/bin/activate.fish; or source .venv/bin/activate.fish'
    alias uvd 'deactivate'
    alias uvc 'uv cache'
    alias uvcc 'uv cache clean'
    alias uvt 'uv tree'
end

# Virtual environment functions
function mkvenv
    set -l venv_name ".venv"
    if test -n "$argv[1]"
        set venv_name $argv[1]
    end

    if type -q uv
        uv venv $venv_name
        source $venv_name/bin/activate.fish
    else
        python3 -m venv $venv_name
        source $venv_name/bin/activate.fish
    end
end

function activate
    if test -f .venv/bin/activate.fish
        source .venv/bin/activate.fish
    else if test -f venv/bin/activate.fish
        source venv/bin/activate.fish
    else if test -f env/bin/activate.fish
        source env/bin/activate.fish
    else if test -n "$argv[1]" -a -f "$argv[1]/bin/activate.fish"
        source $argv[1]/bin/activate.fish
    else
        echo "No virtual environment found"
    end
end

function rmvenv
    if test -n "$VIRTUAL_ENV"
        deactivate
    end

    if test -d ".venv"
        rm -rf .venv
        echo "Removed .venv"
    else if test -d "venv"
        rm -rf venv
        echo "Removed venv"
    else if test -d "env"
        rm -rf env
        echo "Removed env"
    else if test -n "$argv[1]" -a -d "$argv[1]"
        rm -rf $argv[1]
        echo "Removed $argv[1]"
    else
        echo "No virtual environment to remove"
    end
end

# Auto-activate virtual environment when entering directory
function __auto_activate_venv --on-variable PWD
    # Prevent infinite recursion (sourcing activate and builtin cd re-trigger this)
    if set -q __activating_venv
        return
    end
    set -g __activating_venv 1

    set -l _saved_pwd $PWD
    if test -f .venv-linux/bin/activate.fish
        if test "$VIRTUAL_ENV" != "$PWD/.venv-linux"
            # Deactivate old venv before activating new one
            if test -n "$VIRTUAL_ENV"; and type -q deactivate
                deactivate
            end
            source .venv-linux/bin/activate.fish
            builtin cd $_saved_pwd
        end
    else if test -f .venv/bin/activate.fish
        if test "$VIRTUAL_ENV" != "$PWD/.venv"
            if test -n "$VIRTUAL_ENV"; and type -q deactivate
                deactivate
            end
            activate
            builtin cd $_saved_pwd
        end
    else if test -f venv/bin/activate.fish
        if test "$VIRTUAL_ENV" != "$PWD/venv"
            if test -n "$VIRTUAL_ENV"; and type -q deactivate
                deactivate
            end
            activate
            builtin cd $_saved_pwd
        end
    else if test -f .python-version
        # For pyenv users
        if type -q pyenv
            pyenv local (command cat .python-version)
        end
    else
        # No venv in this directory — deactivate stale one
        if test -n "$VIRTUAL_ENV"; and type -q deactivate
            deactivate
        end
    end

    set -e __activating_venv
end


# Pipx aliases
if type -q pipx
    alias pxi 'pipx install'
    alias pxu 'pipx upgrade'
    alias pxua 'pipx upgrade-all'
    alias pxun 'pipx uninstall'
    alias pxl 'pipx list'
    alias pxr 'pipx run'
    alias pxe 'pipx ensurepath'
end

# Conda/Mamba aliases
if type -q conda
    alias ca 'conda activate'
    alias cda 'conda deactivate'
    alias ci 'conda install'
    alias cu 'conda update'
    alias cr 'conda remove'
    alias cl 'conda list'
    alias ce 'conda env'
    alias cel 'conda env list'
    alias cec 'conda env create'
    alias cer 'conda env remove'
end

if type -q mamba
    alias ma 'mamba activate'
    alias mda 'mamba deactivate'
    alias mi 'mamba install'
    alias mu 'mamba update'
    alias mr 'mamba remove'
    alias ml 'mamba list'
    alias me 'mamba env'
end

# Jupyter aliases
alias jn 'jupyter notebook'
alias jl 'jupyter lab'
alias jc 'jupyter console'

# IPython
alias ipy 'ipython'
alias ipynb 'jupyter nbconvert'

# Django aliases
alias dj 'python manage.py'
alias djr 'python manage.py runserver'
alias djm 'python manage.py migrate'
alias djmm 'python manage.py makemigrations'
alias djs 'python manage.py shell'
alias djc 'python manage.py collectstatic'
alias djt 'python manage.py test'

# Flask aliases
alias fl 'flask'
alias flr 'flask run'
alias fld 'flask run --debug'

# FastAPI aliases
alias fapi 'uvicorn main:app --reload'
alias fapidev 'uvicorn main:app --reload --host 0.0.0.0 --port 8000'

# Python debugging and profiling
alias pdb 'python -m pdb'
alias profile 'python -m cProfile'
alias timeit 'python -m timeit'

# Python code quality
alias black 'black --line-length 88'
alias isort 'isort --profile black'
alias flake8 'flake8 --max-line-length 88'
alias mypy 'mypy --strict'
alias ruff 'ruff check'
alias rufff 'ruff format'

# Quick Python scripts
function pymath
    python3 -c "import math; print($argv)"
end

function pytime
    python3 -c "import time; print(time.time())"
end

function pyuuid
    python3 -c "import uuid; print(uuid.uuid4())"
end
