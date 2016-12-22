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

git log --diff-filter=D --summary |
    grep 'delete mode ...... ' |
    sed 's/delete mode ...... //' |
    # Ignore paths with a ' as xargs trips over this.
    # c.f. http://stackoverflow.com/questions/11649872/getting-error-xargs-unterminated-quote-when-tried-to-print-the-number-of-lines
    grep -v "'" |
    grep -v '"' |
    xargs -n 1 dirname | \
    xargs -I % sh -c 'D="%"; if ! [ -d "$D" ]; then while ! test -d $(dirname "$D"); do D=$(dirname "$D"); done; echo "deleted $D"; else echo "present $D"; fi;' | \
    sort | \
    uniq -c | \
    sort -n -r
