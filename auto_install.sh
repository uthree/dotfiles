#!/bin/sh
# Clone (or update) this repository in ~/.dotfiles, then run install.sh .
#
#   curl -fsSL https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.sh | sh
#
# DOTPATH and DOTFILES_REPOSITORY override where it is cloned from and to.
set -e

DOTPATH="${DOTPATH:-$HOME/.dotfiles}"
DOTFILES_REPOSITORY="${DOTFILES_REPOSITORY:-https://github.com/uthree/dotfiles}"
export DOTPATH

if ! command -v git > /dev/null 2>&1; then
	echo "git is required." >&2
	exit 1
fi

if [ -d "$DOTPATH/.git" ]; then
	echo "Updating dotfiles in $DOTPATH ..."
	git -C "$DOTPATH" pull --ff-only
else
	if [ -e "$DOTPATH" ]; then
		backup="$DOTPATH.bak-$(date +%Y%m%d-%H%M%S)"
		echo "$DOTPATH exists and is not a clone; moving it to $backup"
		mv "$DOTPATH" "$backup"
	fi
	echo "Cloning dotfiles..."
	git clone "$DOTFILES_REPOSITORY" "$DOTPATH"
fi
echo "Done"

# Run install script
sh "$DOTPATH/install.sh"

echo "Install complete!"
