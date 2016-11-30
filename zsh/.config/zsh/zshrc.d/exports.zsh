export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export HISTFILE="$XDG_CACHE_HOME/.zsh_history"
export HISTSIZE=2000
export SAVEHIST=$HISTSIZE
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export EDITOR=vim
export BROWSER=jumanji
export PANEL_FIFO="/tmp/panel-fifo"

