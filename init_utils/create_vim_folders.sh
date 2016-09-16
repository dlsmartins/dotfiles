#! /bin/sh

if [ -z "$XDG_CACHE_HOME" ]; then
    echo "ERR: XDG_CACHE_HOME is unset!"
    exit 0
fi

mkdir -p "$XDG_CACHE_HOME"
mkdir -p "$XDG_CACHE_HOME/vim"
mkdir -p "$XDG_CACHE_HOME/vim/backup"
mkdir -p "$XDG_CACHE_HOME/vim/swap"
mkdir -p "$XDG_CACHE_HOME/vim/undo"
touch "$XDG_CACHE_HOME/vim/viminfo" || exit
