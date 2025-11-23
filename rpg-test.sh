#!/bin/sh
printf '\033c\033]0;%s\a' rpg-test
base_path="$(dirname "$(realpath "$0")")"
"$base_path/rpg-test.x86_64" "$@"
