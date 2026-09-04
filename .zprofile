# .zprofile runs for every login shell, including the non-interactive ones that
# coding agents and scripts spawn (`zsh -lc ...`). zoxide replaces `cd` with a
# function, so a scripted `cd /missing/path` would silently land somewhere else
# instead of failing. Keep it to interactive shells.
if [[ -z "${RUSTC_WRAPPER:-}" ]] && command -v sccache > /dev/null 2>&1; then
	export RUSTC_WRAPPER=sccache
fi

[[ -o interactive ]] || return

# zoxide
if type zoxide &> /dev/null; then
    eval "$(zoxide init zsh --cmd cd)"
fi
