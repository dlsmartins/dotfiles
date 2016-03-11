# Path to oh-my-zsh
export ZSH=$XDG_CONFIG_HOME/zsh/oh-my-zsh
# Set folder to store z compdump files
export ZSH_COMPDUMP=$XDG_CACHE_HOME/zsh
# Set vimrc folder to respect XDG-BDS
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
# Set ZSH theme
ZSH_THEME="agnoster"
# Define aliases
alias lsa="ls -anlp"
# Load ls colors
eval `dircolors $XDG_CONFIG_HOME/.dir_colors`
# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder
# Load plugins
plugins=(git)
# Load oh my zsh
source $ZSH/oh-my-zsh.sh
# Set path
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export PATH=$HOME/bin:/usr/local/bin:$PATH
# export LANG=en_US.UTF-8

