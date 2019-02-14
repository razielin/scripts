#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" # script dir

#unzip "$DIR/dotfiles"
cp -r "$DIR/dotfiles/." ~
#rm "$DIR/dotfiles"bi011irid
