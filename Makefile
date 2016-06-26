HEADLESS=.dircolors\
		 .vim/bundle/Vundle.vim\
		 .zsh/git-prompt\
		 .zsh/z

all:
	git submodule update --init --recursive
	./deploy.sh
	./fonts/install.sh

tiny:
	git submodule init $(HEADLESS)
	git submodule update $(HEADLESS)
	./deploy.sh

dump:
	gconftool-2 --dump '/apps/gnome-terminal' > gnome-terminal-conf.xml

apply:
	gconftool-2 --load gnome-terminal-conf.xml || true

vim:
	/usr/bin/env nvim +silent +PluginInstall +PluginClean +qall || /usr/bin/env vim +silent +PluginInstall +PluginClean +qall
	sudo pip install -U neovim
	~/.vim/bundle/YouCompleteMe/install.py --clang-completer

clean:
	echo "removing dead links"
	find -L ~/ -name . -o -type d -prune -o -type l -exec rm {} +
