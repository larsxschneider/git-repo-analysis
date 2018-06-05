#!/usr/bin/env bash
#
# git-find-ignored-files.sh
#
# Find all files present in the index and working tree ignored by .gitignore
#
# Usage: git-find-ignored-files [-s | --sort-by-size] [--help]
#
# Author: Patrick Lühne, https://www.luehne.de/
#

function print_help
{
	grep "^# Usage" < "$0" | cut -c 3-
}

if [[ $# -gt 1 ]]
then
	print_help
	exit 1
fi

command="git ls-files --ignored --exclude-standard -z | xargs -0r du -sh"

case "$1" in
	-h|--help)
		print_help
		exit 0
		;;
	-s|--sort-by-size)
		command="$command | sort -h"
		;;
	*)
		if [[ $# -gt 0 ]]
		then
			(>&2 echo "error: unknown option “$1”")
			print_help
			exit 1
		fi
		;;
esac

eval "$command"
