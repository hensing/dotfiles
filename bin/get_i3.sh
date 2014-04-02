#!/bin/bash

git clone git://code.i3wm.org/i3 ~/spielen/i3
git clone git://code.i3wm.org/i3status ~/spielen/i3status

sudo aptitude install dmenu suckless-tools '~dlibxcb' libstartup-notification0-dev libpcre3-dev libev-dev yajl-tools libyajl-dev libxcursor-dev asciidoc libconfuse-dev libasound2-dev libiw-dev flex bison

cd ~/spielen/i3
git pull
make
sudo make install

cd ~/spielen/i3status
git pull
make
sudo make install

