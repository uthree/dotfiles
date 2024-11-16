# Remove old chache
echo "Removing old chache...\e[0m"
rm -rf ~/.dotfiles/
echo "Done"

#!/bin/bash
echo "Cloning dotfiles..."
git clone https://github.com/uthree/dotfiles ~/.dotfiles
echo "Done"

# Run install script
cd ~/.dotfiles
sh ./install.sh

echo "Install complete!"