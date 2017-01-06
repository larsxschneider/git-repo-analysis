#!/usr/bin/env bash
#
# git-find-dirs-deleted-files.sh
#
# Print the number of deleted files per directory. The output indicates
# if the directory is present in the HEAD revision.
#
# A deleted directory with a lot of files indicates a 3rd party component
# that has been deleted. These are usually good candidates for exclusions
# in repository migrations to Git.
#
# The script must be called in the Git root directory.
#
# Output: [deleted file count] [directory still in HEAD revision?] [directory]
#
# Author: Lars Schneider, http://larsxschneider.github.io/
#

git -c diff.renameLimit=10000 log --diff-filter=D --summary |
    grep ' delete mode ...... ' |
    sed 's/ delete mode ...... //' |
    while read -r F ; do
        D=$(dirname "$F");
        if ! [ -d "$D" ]; then
            while ! [ -d "$(dirname "$D")" ] ; do D=$(dirname "$D"); done;
            echo "deleted $D";
        else
            echo "present $D";
        fi;
    done |
    sort |
    uniq -c |
    sort -k 2,2 -r
