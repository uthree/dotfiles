if [ -d ${HOME}/.Trash ]; then
	alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    alias cleartrash='command rm -rf ~/.Trash/*' 
else
	echo
    echo "\e[35;1mTrash Directory not detected. Run mkdir ${HOME}/.Trash if you need trash directory.\e[0m"
fi