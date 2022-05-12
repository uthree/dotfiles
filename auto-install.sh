# Remove old chache
echo "\e[35;1mRemoving old chache...\e[0m"
rm -rf ~/.dotfiles/
echo "\e[35;1mDone!\e[0m"

#!/bin/bash
echo "\e[35;1mCloning dotfiles...\e[0m"
git clone https://github.com/uthree/dotfiles ~/.dotfiles
echo "\e[35;1mDone!\e[0m"
cd ~/.dotfiles
./install.sh

echo "Type 'exec zsh' to reload your shell and have fun!"
echo "Note: 'source .zshrc' is deprecated. for more info, visit:"
echo "https://blog.mattclemente.com/2020/06/26/oh-my-zsh-slow-to-load.html"
