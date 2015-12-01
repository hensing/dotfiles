HEADLESS=.dircolors\
		 .vim/bundle/Vundle.vim\
		 .zsh/git-prompt\
		 .zsh/z

all:
	git submodule update --init --recursive
	sh deploy.sh

tiny:
	git submodule init $(HEADLESS)
	git submodule update $(HEADLESS)
	sh deploy.sh
