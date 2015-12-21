#!/bin/sh

# deploying the dotfiles
cd ~/.dotfiles

for file in `git ls-files|grep -v -E "(.gitmodules|.gitignore|deploy.sh|README|LICENSE|ansible|conda|Makefile)"`
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

ln -sf  ~/.dotfiles/.git/modules/.vim/bundle/Vundle.vim ~/.vim/bundle/Vundle.vim/.git

