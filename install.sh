#!/bin/bash
DOTPATH=~/.dotfiles

entries="\
	.zshrc \
	.zshrc.d \
	.tmux.conf \
	.config
	.vimrc \
"

# generate symlinks
echo "generating symlinks..."
for f in $entries; do
	parent_dir=$(dirname $HOME/$f)
	if [[ ! -e $parent_dir ]]; then
		mkdir -p $parent_dir
	fi
	ln -snfv "$DOTPATH/$f" "$HOME"/"$f"
done

# install starship
curl -sS https://starship.rs/install.sh | sh

# install vim colorscheme
if type vim &> /dev/null; then
	cd ~
	echo "Installing vim color scheme..."
	mkdir ~/.vim
	cd ~/.vim
	mkdir colors

	echo "  Downloading color scheme..."
	git clone https://github.com/w0ng/vim-hybrid
	mv vim-hybrid/colors/hybrid.vim ~/.vim/colors
	echo "  Done!"
	echo "Done!"
fi