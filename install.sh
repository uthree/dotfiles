#!/bin/bash
DOTPATH=~/.dotfiles

entries="\
	.zshrc \
	.zshrc.d \
	.tmux.conf \
	.config/nvim \
	.config/alacritty \
	.config/helix \
	.vimrc \
"

# install colorscheme
cd ~
echo "\e[35;1mInstalling color scheme...\e[0m"
mkdir ~/.vim
cd ~/.vim
mkdir colors

echo "  \e[35;1mDownloading color scheme...\e[0m"
git clone https://github.com/w0ng/vim-hybrid
mv vim-hybrid/colors/hybrid.vim ~/.vim/colors
echo "  \e[35;1mDone!\e[0m"
echo "\e[35;1mDone!\e[0m"

for f in $entries; do
	parent_dir=$(dirname $HOME/$f)
	if [[ ! -e $parent_dir ]]; then
		mkdir -p $parent_dir
	fi
	ln -snfv "$DOTPATH/$f" "$HOME"/"$f"
done
