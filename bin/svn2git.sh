#!/bin/bash
# https://gist.github.com/863084

export $authors_file=author-conv-file

git filter-branch -f --env-filter '

get_name () {
    grep "^$1=" "$authors_file" |
    sed "s/^.*=\(.*\) <.*>$/\1/"
}

get_email () {
    grep "^$1=" "$authors_file" |
    sed "s/^.*=.* <\(.*\)>$/\1/"
}

GIT_AUTHOR_NAME=$(get_name $GIT_COMMITTER_NAME) &&
    GIT_AUTHOR_EMAIL=$(get_email $GIT_COMMITTER_NAME) &&
    GIT_COMMITTER_NAME=$GIT_AUTHOR_NAME &&
    GIT_COMMITTER_EMAIL=$GIT_AUTHOR_EMAIL &&
    export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL &&
    export GIT_COMMITTER_NAME GIT_COMMITTER_EMAIL
' -- --all

# authors_file:
# h.wurst=Hans Wurst <hans@wurst.de>
