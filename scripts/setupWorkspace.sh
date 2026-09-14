#!/usr/bin/env bash

(
set -e
basedir="$(cd "$1" && pwd -P)"
cd "$basedir"

git submodule update --init
./scripts/remap.sh "$basedir"
./scripts/decompile.sh "$basedir"

echo "External Minecraft/Spigot dependencies are ready."
echo "Paper-API and Paper-Server were not modified."
)
