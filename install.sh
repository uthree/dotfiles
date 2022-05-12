#!/bin/bash
DOTPATH=~/.dotfiles

entries="\
	.zshrc \
	.zshrc.d \
	.tmux.conf \
	.config/nvim \
	.vimrc \
"

for f in $entries; do
	parent_dir=$(dirname $HOME/$f)
	if [[ ! -e $parent_dir ]]; then
		mkdir -p $parent_dir
	fi
	ln -snfv "$DOTPATH/$f" "$HOME"/"$f"
done

# install code-minimap https://github.com/wfxr/code-minimap
if ! command -v <cargo> &> /dev/null
then
	echo "installing code-minimap from crates.io ..."
    	cargo install --locked code-minimap
fi

if ! command -v <yay> &> /dev/null
then
	echo "installing code-minimap from AUR ..."
    	yay -S code-minimap
fi

if ! command -v <brew> &> /dev/null
then
	echo "installing code-minimap from homebrew ..."
	brew install code-minimap
fi
