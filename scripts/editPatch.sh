#!/usr/bin/env bash

set -e

basedir="$(cd "$1" && pwd -P)"
target="$2"
gitcmd="git -c commit.gpgsign=false"

. "$basedir/scripts/functions.sh"

case "$target" in
    Paper-API|Paper-Server) ;;
    *)
        echo "Expected Paper-API or Paper-Server, got: $target" >&2
        exit 2
        ;;
esac

export PAPER_LAST_EDIT="$basedir/$target"
cd "$PAPER_LAST_EDIT"
paperstash
$gitcmd rebase -i upstream/upstream
paperunstash

printf '%s\n' "$PAPER_LAST_EDIT" > "$basedir/.paper-last-edit"

