#!/usr/bin/env bash
#
# git-find-dirs-many-files.sh [file count threshold]
#
# Print directories with the number of files underneath them.
#
# A directory with a lot of files indicates a 3rd party component. These
# are usually good candidates for exclusions in repository migrations to
# Git.
#
# The script must be called in the Git root directory.
#
# Author: Lars Schneider, http://larsxschneider.github.io/
#

if [ -z "$1" ]; then
    FILE_COUNT=100
else
    FILE_COUNT=$1
fi

IFS=$'\n';
DIRS=$(find . -type d -not -path "./.git/*" -exec bash -c 'COUNT=$(find "$0" -type f | wc -l); echo "$COUNT $0"' {} \; | sort -nr)

for DIR in $DIRS; do
    if [ $(($(echo $DIR | sed 's/\..*//'))) -le $FILE_COUNT ]; then
        break
    fi
    echo $DIR
done
