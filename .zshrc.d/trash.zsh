if [ -d ${HOME}/.Trash ]; then
    # create alias
    if [[ "$(uname)" != "Darwin" ]] then;

        alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    else
        if type trash &> /dev/null; then
            alias rm='trash'
        else
            echo "\e[35;1mWarning: trash command is not installed.\e[0m"
        fi
    fi
else
    # create trash directory
    mkdir -p ${HOME}/.Trash
    echo "\e[35;1mCreated ${HOME}/.Trash directory automatically. \e[0m"
fi

TRASH_DIR="$HOME/.Trash"
alias "clear-trash"='find "$TRASH_DIR" -type d -mtime +30 -exec command rm -rf {} +'
alias "clear-trash-all"='command rm -rf ~/.Trash/*'