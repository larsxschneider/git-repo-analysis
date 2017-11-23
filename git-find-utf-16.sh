#!/usr/bin/env bash
#
# git-find-utf-16.sh
#
# Find and print files that are encoded with UTF-16
#
# Author: Lars Schneider, http://larsxschneider.github.io/
#

find . -type f -not -path "./.git/*" -exec file {} \; | grep --ignore-case utf-16
