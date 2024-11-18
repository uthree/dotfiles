#!/bin/bash
DOTPATH=~/.dotfiles

entries="\
	.zshrc \
	.zshrc.d \
	.config/alacritty \
	.config/helix \
	.config/starship.toml \
	.config/zellij \
	.vimrc \
"

# generate symlinks
echo "generating symlinks..."
for f in $entries; do
	echo "	$f"
	parent_dir=$(dirname $HOME/$f)
	if [[ ! -e $parent_dir ]]; then
		mkdir -p $parent_dir
	fi
	ln -snfv "$DOTPATH/$f" "$HOME"/"$f"
done