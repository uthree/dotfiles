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

# bat
if type "bat" > /dev/null 2>&1; then
    alias cat="bat"
fi

if type zoxide &> /dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi

# fzf
if type fzf &> /dev/null; then
    source <(fzf --zsh)

    # bat integration
    if type "bat" > /dev/null 2>&1; then
        export FZF_CTRL_T_OPTS='--preview "bat  --color=always --style=header,grid --line-range :100 {}"'
    fi
fi