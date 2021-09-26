#!/usr/bin/env bash

backup_files(){
    local target_filename=$1

    if [ -e "$target_filename" ]; then
        if [ ! -L "$target_filename" ]; then
            mv "$target_filename" "$target_filename.backup"
            printf "-----> Rename file name: %s to %s" "$target_filename" "$target_filename.backup"
        fi
    fi

}

list_dotfiles(){
    `ls -a | grep '^\.'`
}



if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Installing YADR for the first time"
    git clone --depth=1 https://github.com/m/dotfiles.git "$HOME/.dotfiles"
    cd "$HOME/.dotfiles"
    while read 
    [ "$1" = "ask" ] && export ASK="true"

    rake install
else
    echo "YADR is already installed"
fi

echo "👌 Carry on with bootstrap environment setup!"