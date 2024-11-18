if [ -d ${HOME}/.Trash ]; then
    # create alias
    if [[ "$(uname)" != "Darwin" ]];
        alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
        alias cleartrash='command rm -rf ~/.Trash/*' 
    else
        if type "trash" > /dev/null 2>&1; then
            alias rm='trash'
        else
            echo "\e[35;1mWarning: trash command is not installed.\e[0m"
        end
    end
else
    # create trash directory
    mkdir ${HOME}/.Trash
    echo "\e[35;1mCreated ${HOME}/.Trash directory automatically. \e[0m"
fi


TRASH_DIR="$HOME/.Trash"

# delete old file in trash
if [[ -d "$TRASH_DIR" ]]; then
    if [[ "$(uname)" != "Darwin" ]]; then
        find "$TRASH_DIR" -type f -mtime +30 -exec rm -f {} \;
        find "$TRASH_DIR" -type d -mtime +30 -exec rm -rf {} \;
    fi
fi