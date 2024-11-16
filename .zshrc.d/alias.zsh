alias ":q"="exit"
alias ":e"="vim"
alias ":o"="hx"
alias reload="exec zsh"
alias "$"="command"

# zellij
if type zellij &> /dev/null; then
    alias tmux="zellij"
fi

# eza
if type "eza" > /dev/null 2>&1; then
	alias ls="eza --icons -F"
fi

alias background="screen -d -m"


