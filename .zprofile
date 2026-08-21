# .zprofile runs for every login shell, including the non-interactive ones that
# coding agents and scripts spawn (`zsh -lc ...`). zoxide replaces `cd` with a
# function, so a scripted `cd /missing/path` would silently land somewhere else
# instead of failing. Keep it to interactive shells.
[[ -o interactive ]] || return

# zoxide
if type zoxide &> /dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
