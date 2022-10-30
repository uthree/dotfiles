if [ -d ${HOME}/.Trash ]
then
    alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    alias cleartrash='commmand rm -rf ~/.Trash/*' 
else
    echo
    echo "\e[35;1mTrash Directory is not detected. Run mkdir ${HOME}/.Trash if you need trash directory.\e[0m"
fi
