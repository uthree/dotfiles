#!/bin/bash
git clone https://github.com/uthree/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install.sh

# install colorscheme
mkdir ~/.vim
cd ~/.vim
mkdir colors

git clone https://github.com/w0ng/vim-hybrid
mv vim-hybrid/colors/hybrid.vim ~/.vim/colors

echo "Type 'exec zsh' to reload your shell and have fun!"
echo "Note: 'source .zshrc' is deprecated. for more info, visit:"
echo "https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html"
