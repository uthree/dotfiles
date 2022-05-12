#!/bin/bash
DOTPATH=~/.dotfiles

entries="\
	.zshrc \
	.zshrc.d \
	.tmux.conf \
	.config/nvim \
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

# install code-minimap https://github.com/wfxr/code-minimap
echo "\e[35;1mInstalling code minimap for vim ...\e[0m"
if command -v yay &> /dev/null
then
	echo "installing code-minimap from AUR ..."
    	yay -S code-minimap
elif command -v cargo &> /dev/null
then
	echo "installing code-minimap from crates.io ..."
    	cargo install --locked code-minimap
elif command -v brew &> /dev/null
then
	echo "installing code-minimap from homebrew ..."
	brew install code-minimap
fi
