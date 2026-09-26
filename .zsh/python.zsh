# Python virtualenv via virtualenvwrapper — loaded only when the wrapper is present
export WORKON_HOME=~/.virtualenvs
local _venvwrapper=/opt/homebrew/bin/virtualenvwrapper.sh
[[ -f $_venvwrapper ]] && source $_venvwrapper
