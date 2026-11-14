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
| `40-trash.ps1` | `trash.zsh` (`rm` goes to the recycle bin, `clear-trash-all`) |
| `50-readline.ps1` | `zinit.zsh` (emacs keys, history substring search, autosuggestions, completion menu) |
| `60-starship.ps1` | `starship.zsh` |
| `70-zoxide.ps1` | `.zprofile` |
| `80-fzf.ps1` | the fzf block of `alias.zsh` |

Each block only turns itself on when the tool it wraps is installed, so a
partially installed machine still gets a working shell. Every block from `10-`
onwards is skipped in non-interactive sessions, see
[coding-agents.md](coding-agents.md).

## Trash

`rm` puts its arguments somewhere they can be restored from, instead of
deleting them.

On Windows that is the recycle bin, so Explorer restores a file to where it
came from and Windows decides how long to keep it. `clear-trash-all` empties
the bin.

zsh has no shared trash to hand a path to, so it moves the arguments to
`~/.Trash/` and gives a name that already exists there a numbered suffix rather
than overwriting it. `clear-trash` deletes entries older than 30 days and
`clear-trash-all` empties the directory.

To really delete something: `command rm` (zsh) or `Remove-Item` (PowerShell).

## Miscellaneous

- `DOTFILES_QUIET=1` silences the loading banner.

