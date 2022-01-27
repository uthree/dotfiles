#!/bin/bash
echo "\e[35;1mCloning dotfiles...\e[0m"
git clone https://github.com/uthree/dotfiles ~/.dotfiles
echo "\e[35;1mDone!\e[0m"
cd ~/.dotfiles
./install.sh

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


echo "Type 'exec zsh' to reload your shell and have fun!"
echo "Note: 'source .zshrc' is deprecated. for more info, visit:"
echo "https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html"
