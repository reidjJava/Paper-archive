#!/usr/bin/env bash

(
set -e
PS1="$"
basedir="$(cd "$1" && pwd -P)"
workdir="$basedir/work"
minecraftversion=$(cat "${workdir}/BuildData/info.json" | grep minecraftVersion | cut -d '"' -f 4)
minecrafthash=$(cat "${workdir}/BuildData/info.json" | grep minecraftHash | cut -d '"' -f 4)
accesstransforms="$workdir/BuildData/mappings/"$(cat "${workdir}/BuildData/info.json" | grep accessTransforms | cut -d '"' -f 4)
classmappings="$workdir/BuildData/mappings/"$(cat "${workdir}/BuildData/info.json" | grep classMappings | cut -d '"' -f 4)
membermappings="$workdir/BuildData/mappings/"$(cat "${workdir}/BuildData/info.json" | grep memberMappings | cut -d '"' -f 4)
packagemappings="$workdir/BuildData/mappings/"$(cat "${workdir}/BuildData/info.json" | grep packageMappings | cut -d '"' -f 4)
jarpath="$workdir/Minecraft/$minecraftversion/$minecraftversion"

function validJar {
    [[ -f "$1" ]] && jar tf "$1" >/dev/null 2>&1
}

function removeInvalidJar {
    if [[ -f "$1" ]] && ! validJar "$1"; then
        echo "Removing incomplete jar: $1"
        rm -f "$1"
    fi
}

function createMappedJar {
    output="$1"
    shift
    temporary="$output.tmp"
    rm -f "$temporary"
    if ! "$@" -o "$temporary"; then
        rm -f "$temporary"
        return 1
    fi
    if ! validJar "$temporary"; then
        rm -f "$temporary"
        echo "Mapping produced an invalid jar: $output" >&2
        return 1
    fi
    mv -f "$temporary" "$output"
}

echo "Downloading unmapped vanilla jar..."
removeInvalidJar "$jarpath.jar"
if [ ! -f  "$jarpath.jar" ]; then
    mkdir -p "$workdir/Minecraft/$minecraftversion"
    download="$jarpath.jar.tmp"
    rm -f "$download"
    if ! curl -fL -o "$download" "https://s3.amazonaws.com/Minecraft.Download/versions/$minecraftversion/minecraft_server.$minecraftversion.jar"; then
        rm -f "$download"
        echo "Failed to download the vanilla server jar. Check connectivity or try again later."
        exit 1
    fi
    mv -f "$download" "$jarpath.jar"
fi

# OS X & FreeBSD don't have md5sum, just md5 -r
command -v md5sum >/dev/null 2>&1 || {
    command -v md5 >/dev/null 2>&1 && {
        shopt -s expand_aliases
        alias md5sum='md5 -r'
        echo "md5sum command not found, using an alias instead"
    } || {
        echo >&2 "No md5sum or md5 command found"
        exit 1
    }
}

checksum=$(md5sum "$jarpath.jar" | cut -d ' ' -f 1)
if [ "$checksum" != "$minecrafthash" ]; then
    echo "The MD5 checksum of the downloaded server jar does not match the BuildData hash."
    rm -f "$jarpath.jar"
    exit 1
fi

echo "Applying class mappings..."
removeInvalidJar "$jarpath-cl.jar"
if [ ! -f "$jarpath-cl.jar" ]; then
    createMappedJar "$jarpath-cl.jar" java -jar "$workdir/BuildData/bin/SpecialSource-2.jar" map -i "$jarpath.jar" -m "$classmappings" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to apply class mappings."
        exit 1
    fi
fi

echo "Applying member mappings..."
removeInvalidJar "$jarpath-m.jar"
if [ ! -f "$jarpath-m.jar" ]; then
    createMappedJar "$jarpath-m.jar" java -jar "$workdir/BuildData/bin/SpecialSource-2.jar" map -i "$jarpath-cl.jar" -m "$membermappings" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to apply member mappings."
        exit 1
    fi
fi

echo "Creating remapped jar..."
removeInvalidJar "$jarpath-mapped.jar"
if [ ! -f "$jarpath-mapped.jar" ]; then
    createMappedJar "$jarpath-mapped.jar" java -jar "$workdir/BuildData/bin/SpecialSource.jar" --kill-lvt -i "$jarpath-m.jar" --access-transformer "$accesstransforms" -m "$packagemappings" 1>/dev/null
    if [ "$?" != "0" ]; then
        echo "Failed to create remapped jar."
        exit 1
    fi
fi

echo "Installing remapped jar..."
cd "$workdir/CraftBukkit" # Need to be in a directory with a valid POM at the time of install.
"$basedir/mvnw" install:install-file -q -Dfile="$jarpath-mapped.jar" -Dpackaging=jar -DgroupId=org.spigotmc -DartifactId=minecraft-server -Dversion="$minecraftversion-SNAPSHOT" -Dmaven.repo.local="$basedir/.m2-local"
if [ "$?" != "0" ]; then
    echo "Failed to install remapped jar."
    exit 1
fi
)
