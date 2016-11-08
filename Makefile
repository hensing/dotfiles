HOSTNAME := $(shell hostname)
HEADLESS=.dircolors\
		 .vim/bundle/Vundle.vim\
		 .zsh/git-prompt\
		 .zsh/z

all:
	git submodule update --init --recursive
	./deploy.sh
	sudo fc-cache -f

tiny:
	git submodule init $(HEADLESS)
	git submodule update $(HEADLESS)
	./deploy.sh

dump:
	dconf dump /org/mate/terminal/ > mate-terminal-conf.dconf

apply:
	dconf load /org/mate/terminal/ < mate-terminal-conf.dconf

vim:
	/usr/bin/env nvim +silent +PluginInstall +PluginClean +qall || /usr/bin/env vim +silent +PluginInstall +PluginClean +qall
	sudo pip install -U neovim
	~/.vim/bundle/YouCompleteMe/install.py --clang-completer

ansible:
	sudo apt-get install software-properties-common
	sudo apt-add-repository ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install ansible openssh-server
	sudo ssh-copy-id root@$(HOSTNAME)
	ansible-playbook -i ansible/hosts.ini ansible/apt_packages.yml -l $(HOSTNAME)


clean:
	echo "removing dead links"
	find -L ~/ -name . -o -type d -prune -o -type l -exec rm {} +

