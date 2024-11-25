# load all files
#echo
echo "\e[35;1mLoading ~/.zshrc.d ...\e[0m"
for config in $HOME/.zshrc.d/*.zsh; do
        echo "\e[90m- $config \e[0m"
        source $config
done
echo "\e[35;1mDone.\e[0m"
echo

if [ -e $HOME/.specific.zsh ]; then
	source $HOME/.specific.zsh
else
	echo "\e[35;1m ~/.specific.zsh is not detected. write ~/.specific.zsh if you need setting only this machine .\e[0m"
fi

# zoxide
if type zoxide &> /dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi