# Coding agents and scripts

zsh reads `.zshrc` only for interactive shells, but PowerShell runs `$PROFILE`
for `-Command` / `-File` runs as well — which is exactly how coding agents,
scripts and CI invoke it.

Left alone they would get `rm` as "move to `~/.Trash`", `ls` as eza text instead
of objects (so `ls | Measure-Object` counts 0), `mkdir` returning nothing, `cd`
as zoxide (a missing path stops being an error), plus the loading banner on
stdout.

## PowerShell

`profile.ps1` decides once whether the session is interactive
(`Test-DotfilesInteractiveSession`), and `profile.d/10-*` .. `80-*` bail out when
it is not — the equivalent of `[[ -o interactive ]] || return`.

A session counts as non-interactive when

- `CLAUDECODE`, `AI_AGENT` or `CI` is set, or
- the command line has `-Command` / `-File` / `-EncodedCommand` /
  `-NonInteractive`, or
- the process is not user-interactive.

`00-options.ps1` (PATH, UTF-8, XDG, `$EDITOR`) still loads, since it changes no
command's meaning.

## zsh

- `.zshrc` returns early when `CLAUDECODE`, `AI_AGENT` or `CI` is set. Claude
  Code already runs `unalias -a` over its shell snapshot, but other agents use
  `zsh -ic`.
- `.zprofile` initialises zoxide only for interactive shells, so `zsh -lc 'cd
  ...'` keeps the real `cd`.

Agents that call the shell as `sh -c` / `bash -c` / `zsh -c` were never affected:
zsh reads only `.zshenv` there, and this repository ships none.
