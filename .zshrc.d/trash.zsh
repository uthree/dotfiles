if [ -d ${HOME}/.Trash ]; then
    # create alias
	alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    alias cleartrash='command rm -rf ~/.Trash/*' 
else
    # create trash directory
    mkdir mkdir ${HOME}/.Trash
	echo
    echo "\e[35;1mCreated ${HOME}/.Trash directory automatically. \e[0m"
fi


TRASH_DIR="$HOME/.Trash"

# delete old file in trash
if [[ -d "$TRASH_DIR" ]]; then
  find "$TRASH_DIR" -type f -mtime +30 -exec rm -f {} \;
  find "$TRASH_DIR" -type d -mtime +30 -exec rm -rf {} \;
fi