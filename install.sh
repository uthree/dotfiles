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

# install starship
f ! command -v starship >/dev/null 2>&1; then
	curl -sS https://starship.rs/install.sh | sh
end

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
