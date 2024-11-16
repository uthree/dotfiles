# load all files
echo
echo "\e[35;1mLoading ~/.zshrc.d ...\e[0m"
for config in $HOME/.zshrc.d/*.zsh; do
        echo "\e[90m- $config\e[0m"
        echo -n "\e[0m"
        source $config
done
echo "\e[35;1mDone.\e[0m"
echo