# Python virtualenv via virtualenvwrapper — loaded only when the wrapper is present
export WORKON_HOME=~/.virtualenvs
local _venvwrapper=/usr/share/virtualenvwrapper/virtualenvwrapper.sh
[[ -f $_venvwrapper ]] && source $_venvwrapper
