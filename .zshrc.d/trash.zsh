if [ -d ${HOME}/.Trash ]
then
    alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    alias cleartrash='commmand rm -rf ~/.Trash/*' 
fi
