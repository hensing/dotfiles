HOSTNAME := $(shell hostname)
UNAME    := $(shell uname)
HEADLESS=.dircolors\
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
ifeq ($(UNAME), Darwin)
	brew install neovim python3
	pip3 install --user pynvim
else
	sudo apt-get install -y neovim python3-pip
	pip3 install --user pynvim
endif
	/usr/bin/env nvim --headless "+Lazy sync" +qa

ansible:
	sudo apt-get install software-properties-common
	sudo apt-add-repository ppa:ansible/ansible
	sudo apt-get update
	sudo apt-get install ansible openssh-server
	sudo ssh-copy-id root@$(HOSTNAME)
	ansible-playbook -i ansible/hosts.ini ansible/apt_packages.yml -l $(HOSTNAME)

wsl: tiny
	git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"

clean:
	echo "removing dead links"
	find -L ~/ -name . -o -type d -prune -o -type l -exec rm {} +

headless: tiny vim
