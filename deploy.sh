#!/bin/sh

# deploying the dotfiles
cd ~/.dotfiles

for file in `find . -name .git -prune -o -name deploy.sh -o -type f -print`;
do
    file=${file#./}

    # if dir doesn't exists:
    dir=`dirname $file`
    if [ ! -d ~/$dir ]; then
        mkdir -p ~/$dir
    fi

    # add link:
    ln -f -s ~/.dotfiles/$file ~/$file
done

