# Borgmatic wrapper — loaded only when borgmatic is installed.
# Runs in a sub-shell so secrets don't leak into the current session.
if (( $+commands[borgmatic] )); then
    borgmatic() {
        (
            setopt allexport
            source /etc/borgmatic.d/.secrets
            unsetopt allexport
            /usr/bin/borgmatic "$@"
        )
    }
fi
