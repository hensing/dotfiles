# Jupyter / IPython aliases — loaded only when jupyter or ipython is present
if (( $+commands[jupyter] )); then
    alias i='jupyter console'
    alias jn='jupyter notebook'
    alias inp='jupyter notebook --ip=0.0.0.0'
elif (( $+commands[ipython] )); then
    alias i='ipython'
fi
