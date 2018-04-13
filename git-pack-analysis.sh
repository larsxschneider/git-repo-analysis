#!/usr/bin/env bash
#
# git-pack-analysis.sh
#
# Benchmark different `git repack` delta chains lengths for a given repo
# based on the Peff's analysis discussed here:
# https://github.com/git/git/commit/07e7dbf0db05a550a92a6a5a8977ac47efa7b794
#
# Usage:
#   git-pack-analysis.sh <temp-dir> <repo-url>
#
# Author: Lars Schneider, http://larsxschneider.github.io/
#

TEMP_DIR=$1
REPO_URL=$2

function best-of {
    { for i in 1 2 3; do time $1 >/dev/null; done; } 2>&1 |
        grep real |
        cut -c 6- |
        sort -n |
        head -n1
}

function run {
    DEPTH=$1
    REPO_DIR=depth-$DEPTH

    printf "\n### TEST RUN ###\n"
    printf "Start:     $(date)\n";
    printf "Depth:     $DEPTH\n";

    if test -d "$REPO_DIR"; then
        echo "$(tput setaf 1)$REPO_DIR already exists - reusing! $(tput sgr0)"
    else
        cp -r base "$REPO_DIR"
        git --git-dir="$REPO_DIR" repack -a -d -f --depth=$DEPTH --window=250 >/dev/null 2>&1
    fi

    pushd "$REPO_DIR" >/dev/null
        printf "Size:      "; du -sh .
        printf "rev-list:  "; best-of "git rev-list --objects --all"
        printf "log -Sfoo: "; best-of "git log -Sfoo"
        printf "\n"
    popd >/dev/null
}

mkdir -p "$TEMP_DIR"
pushd "$TEMP_DIR"
    printf "\n#### REPO PACK BENCHMARK ###\n"
    git --version
    printf "System:    "; uname;
    printf "Repo URL:  $REPO_URL\n"

    if test -d base; then
        printf "$(tput setaf 1)Repo already exists - reusing! Delete $TEMP_DIR for a clean run!$(tput sgr0)\n"
    else
        git clone --bare $REPO_URL base
    fi
    run 250
    run 100
    run 50
    run 10
popd
