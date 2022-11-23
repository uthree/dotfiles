if [ -d ${HOME}/.Trash ]; then
	if [[ "$OSTYPE" == "darwin"* ]]; then
  		# macOS OSX
		if type trash > /dev/null 2>&1; then
    		alias rm='trash -F'
		else
			echo "\e[35;1mtrash is not detected.  run brew install trash  if you need trash directory.\e[0m"
		fi
	else
    	alias rm='mv --backup=numbered --target-directory=${HOME}/.Trash'
    	alias cleartrash='command rm -rf ~/.Trash/*' 
	fi
else
	echo
    echo "\e[35;1mTrash Directory not detected. Run mkdir ${HOME}/.Trash if you need trash directory.\e[0m"
fi
