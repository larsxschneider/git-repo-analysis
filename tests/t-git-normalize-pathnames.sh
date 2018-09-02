#!/usr/bin/env bash

function die {
    echo "$1"
    exit 1
}

CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")">/dev/null && pwd)"
TEST_DIR="$CURRENT_DIR/tmp"

rm -rf "$TEST_DIR"
mkdir "$TEST_DIR"
pushd "$TEST_DIR"

    git init . >/dev/null

    echo "a" > foo
    git add foo >/dev/null
    git commit -m "add file" >/dev/null

    rm foo
    git add foo
    echo "b" > Foo
    git add Foo >/dev/null
    git commit -m "change case of file" >/dev/null

    ../../git-normalize-pathnames

    rm Foo
    git reset --hard HEAD

    [ -f Foo ] || die "FAIL"
    [ $(git log --numstat -- Foo | grep Foo | wc -l) -eq 2 ] || die "FAIL"
popd
