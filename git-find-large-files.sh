#!/usr/bin/env bash
#
# git-find-large-files.sh [size threshold in KB]
#
# Print the largest files in a Git repository. The script must be called
# in the Git root directory. You can pass a threshold to print only files
# greater than a certain size (compressed size in Git database, default
# is 500kb).
#
# Files that have a large compressed size should usually be stored in
# Git LFS.
#
# Based on script from Antony Stubbs [1] and
# improved with ideas from Peff.
# [1] http://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
#
# Author: Lars Schneider, http://larsxschneider.github.io/
#

if [ -z "$1" ]; then
    MIN_SIZE_IN_KB=500
else
    MIN_SIZE_IN_KB=$1
fi

# set the internal field separator to line break,
# so that we can iterate easily over the verify-pack output
IFS=$'\n';

# list all objects including their size, sort by compressed size
OBJECTS=$(
    git cat-file \
        --batch-all-objects \
        --batch-check='%(objectsize:disk) %(objectname)' \
    | sort -nr
)

for OBJ in $OBJECTS; do
    # extract the compressed size in kilobytes
    COMPRESSED_SIZE=$(($(echo $OBJ | cut -f 1 -d ' ')/1024))

    if [ $COMPRESSED_SIZE -le $MIN_SIZE_IN_KB ]; then
        break
    fi

    # extract the SHA
    SHA=$(echo $OBJ | cut -f 2 -d ' ')

    # find the objects location in the repository tree
    LOCATION=$(git rev-list --all --objects | grep $SHA | sed "s/$SHA //")

    if git rev-list --all --objects --max-count=1 | grep $SHA >/dev/null; then
        # Object is in the head revision
        HEAD="Y"
    elif [ -e $LOCATION ]; then
        # Objects path is in the head revision
        HEAD="P"
    else
        # Object nor its path is in the head revision
        HEAD="N"
    fi

    OUTPUT="$OUTPUT\n$COMPRESSED_SIZE,$HEAD,$LOCATION"
done

echo -e $OUTPUT | column -t -s ','
