# Coding agents (claude code and friends) run their commands through this shell,
# and the aliases below would change what those commands mean: `rm` moves to
# ~/.Trash instead of deleting, `ls` becomes eza, `cd` becomes zoxide.
# Claude Code already runs `unalias -a` over its shell snapshot, but other agents
# use `zsh -ic`, so bail out explicitly.
if [[ -z "${RUSTC_WRAPPER:-}" ]] && command -v sccache > /dev/null 2>&1; then
	export RUSTC_WRAPPER=sccache
fi

if [[ -n "$CLAUDECODE" || -n "$AI_AGENT" || -n "$CI" ]]; then
	return
fi

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
