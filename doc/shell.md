# Shell configuration

The zsh and PowerShell configurations are deliberately kept in step: the same
aliases, the same trash behaviour, the same prompt.

## Layout

| zsh | PowerShell |
| --- | --- |
| `.zshrc` (loads `~/.zshrc.d/*.zsh`) | `.config/powershell/profile.ps1` (loads `profile.d/*.ps1`) |
| `~/.specific.zsh` | `~/.specific.ps1` |

`~/.specific.zsh` / `~/.specific.ps1` are per-machine and are not tracked here.

| profile.d | zsh counterpart |
| --- | --- |
| `00-options.ps1` | UTF-8 console, XDG variables, `$EDITOR`, PATH |
| `10-os.ps1` | `os.zsh` |
| `20-unix.ps1` | `which` `touch` `mkdir -p` `head` `tail` `grep` `ln -s` `open` `pbcopy` `export` ... |
| `30-alias.ps1` | `alias.zsh` (`:q` `:e` `:o` `reload` `command` `ls` `background`, some git aliases) |
| `40-trash.ps1` | `trash.zsh` (`rm` moves to `~/.Trash`, `clear-trash`, `clear-trash-all`) |
| `50-readline.ps1` | `zinit.zsh` (emacs keys, history substring search, autosuggestions, completion menu) |
| `60-starship.ps1` | `starship.zsh` |
| `70-zoxide.ps1` | `.zprofile` |
| `80-fzf.ps1` | the fzf block of `alias.zsh` |

Each block only turns itself on when the tool it wraps is installed, so a
partially installed machine still gets a working shell. Every block from `10-`
onwards is skipped in non-interactive sessions, see
[coding-agents.md](coding-agents.md).

## Trash

`rm` moves its arguments to `~/.Trash/` instead of deleting them, and a name
that already exists there gets a numbered suffix rather than overwriting.

- `clear-trash` deletes trash entries older than 30 days
- `clear-trash-all` empties the trash
- to really delete something: `command rm` (zsh) or `Remove-Item` (PowerShell)

## Miscellaneous

- `DOTFILES_QUIET=1` silences the loading banner.
