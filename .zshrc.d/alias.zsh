alias ":q"="exit"
alias ":e"="vim"
alias ":o"="hx"
alias reload="exec zsh"

if type zellij &> /dev/null; then
    alias tmux="zellij"
fi