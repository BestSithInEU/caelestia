# PATH configuration

# User binaries
fish_add_path -g ~/.local/bin
fish_add_path -g ~/.npm-global/bin
fish_add_path -g ~/.cargo/bin
fish_add_path -g ~/.go/bin

# CUDA
fish_add_path -g /opt/cuda/bin
set -gx CUDA_HOME /opt/cuda

# System
fish_add_path -g /usr/local/sbin
fish_add_path -g /usr/sbin
fish_add_path -g /sbin
