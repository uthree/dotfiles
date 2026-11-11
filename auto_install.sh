#!/bin/sh
# Clone (or update) this repository in ~/.dotfiles, then run install.sh .
#
#   curl -fsSL https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.sh | sh
#
# The clone in ~/.dotfiles is a deployment copy of what is on GitHub, not a
# place to work in: every run moves it to the latest commit of the remote's
# default branch. Local changes found there are stashed and reported first,
# never discarded.
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
	git -C "$DOTPATH" fetch --prune origin

	if [ -n "$(git -C "$DOTPATH" status --porcelain)" ]; then
		stamp=$(date +%Y%m%d-%H%M%S)
		echo "  this clone has local changes; stashing them:"
		git -C "$DOTPATH" status --short | sed 's/^/    /'
		git -C "$DOTPATH" stash push --include-untracked --message "auto_install-$stamp"
		echo "    get them back with: git -C $DOTPATH stash pop"
	fi

	ref=$(git -C "$DOTPATH" symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)
	if [ -z "$ref" ]; then
		git -C "$DOTPATH" remote set-head origin --auto > /dev/null 2>&1 || true
		ref=$(git -C "$DOTPATH" symbolic-ref --quiet --short refs/remotes/origin/HEAD || true)
	fi
	[ -n "$ref" ] || ref="origin/main"
	git -C "$DOTPATH" checkout -B "${ref#origin/}" "$ref"
else
	if [ -e "$DOTPATH" ]; then
		backup="$DOTPATH.bak-$(date +%Y%m%d-%H%M%S)"
		echo "$DOTPATH exists and is not a clone; moving it to $backup"
		mv "$DOTPATH" "$backup"
	fi
	echo "Cloning dotfiles..."
	git clone "$DOTFILES_REPOSITORY" "$DOTPATH"
fi

echo "Now at $(git -C "$DOTPATH" log --oneline -1)"

# Run install script
sh "$DOTPATH/install.sh"

echo "Install complete!"
