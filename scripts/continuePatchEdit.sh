#!/usr/bin/env bash

set -e

basedir="$(cd "$1" && pwd -P)"
statefile="$basedir/.paper-last-edit"
gitcmd="git -c commit.gpgsign=false"

if [[ ! -f "$statefile" ]]; then
    echo "No patch edit is active. Run editApiPatch or editServerPatch first." >&2
    exit 1
fi

target="$(cat "$statefile")"
case "$target" in
    "$basedir/Paper-API"|"$basedir/Paper-Server") ;;
    *)
        echo "Invalid patch edit state: $target" >&2
        exit 1
        ;;
esac

cd "$target"
$gitcmd add .
$gitcmd commit --amend
$gitcmd rebase --continue

rm -f "$statefile"
"$basedir/scripts/rebuildPatches.sh" "$basedir"

