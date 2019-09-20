#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )" # script dir

if [[ ! -d "$DIR/dotfiles" ]]; then
    unzip "$DIR/dotfiles"
fi
cp -r "$DIR/dotfiles/." ~
#rm -fr "$DIR/dotfiles"

# disable kwallet keyring
cd ~/.local/share/keyrings
rm -fr ./*
cd $(kde4-config --localprefix)share/apps/kwallet
rm -fr ./*
