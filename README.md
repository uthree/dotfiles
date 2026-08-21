# dotfiles
configuration files and install script  

### screenshot (iTerm2)
![screenshot](./assets/image/iterm2_screenshot.png)

## Features
- [zsh](https://ja.wikipedia.org/wiki/Z_Shell): shell (Linux / macOS)
- [PowerShell](https://learn.microsoft.com/powershell/): shell (Windows)
- [zed](https://zed.dev/): text editor
- [helix](https://github.com/helix-editor/helix): text editor
- [eza](https://github.com/eza-community/eza): ls alternative
- [zellij](https://github.com/zellij-org/zellij): tmux alternative (Linux / macOS only)
- [alacritty](https://github.com/alacritty/alacritty): terminal
- [starship](https://starship.rs/ja-jp/): improve prompt
- [vim](https://github.com/vim/vim): text editor
- [zoxide](https://github.com/ajeetdsouza/zoxide): cd alternative
- [fzf](https://github.com/junegunn/fzf): fuzzy finder
- [fcp](https://github.com/Svetlitski/fcp): cp alternative

- Trash
    - replace `rm` command to moving `~/.Trash/` directory.
    - run `clear-trash` to delete old trash files.
    - run `clear-trash-all` to delete all trash files.
- command aliases
- global instructions for [Claude Code](https://claude.com/claude-code) (`~/.claude/CLAUDE.md`)

## Requirements
- zsh (Linux / macOS)
- Windows PowerShell 5.1 or PowerShell 7 (Windows)

## Installation

### Linux / macOS
- run `auto_install.sh`

### Windows
```powershell
# clone into ~/.dotfiles and link everything
powershell -ExecutionPolicy Bypass -File .\auto_install.ps1

# or, from a clone you already have
powershell -ExecutionPolicy Bypass -File .\install.ps1
.\install.bat            # same thing, for double-clicking

# see what would happen first
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
```

Then install the tools the config wraps (winget):

```powershell
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1 -IncludeOptional  # pwsh 7, alacritty, gsudo, nerd font
```

## Windows notes

`install.ps1` links this repository into the places Windows applications
actually read:

| repository | Windows destination |
| --- | --- |
| `.config/powershell` | `~/.config/powershell` + a stub in `$PROFILE` (5.1 and 7) |
| `.config/starship.toml` | `~/.config/starship.toml` |
| `.config/git/ignore` | `~/.config/git/ignore` |
| `.claude/CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `.vimrc` | `~/.vimrc` and `~/_vimrc` |
| `.config/helix` | `~/.config/helix` + `%APPDATA%\helix` |
| `.config/alacritty` | `~/.config/alacritty` + `%APPDATA%\alacritty` |
| `.config/zed/*.json` | `~/.config/zed` + `%APPDATA%\Zed` |
| `.zshrc`, `.zprofile`, `.zshrc.d` | linked only when zsh exists (MSYS2), or with `-IncludeZsh` |

`zellij` has no Windows build, so its config is not linked.

Symlinks need **Developer Mode** (Settings > System > For developers) or an
elevated shell. Without either, directories fall back to junctions and files to
hard links — both work unprivileged. A plain copy is the last resort and is
reported at the end of the run, because a copy no longer follows the repository.
Anything that gets replaced is renamed to `<name>.bak-<timestamp>` first.

### PowerShell profile

`.config/powershell/profile.ps1` is the counterpart of `.zshrc`: it loads every
`*.ps1` in `.config/powershell/profile.d/`, then `~/.specific.ps1` (the
counterpart of `~/.specific.zsh`).

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
partially installed machine still gets a working shell.

### interactive shells only

zsh reads `.zshrc` only for interactive shells, but PowerShell runs `$PROFILE`
for `-Command` / `-File` runs as well — which is exactly how coding agents,
scripts and CI invoke it. Left alone, they would get `rm` as "move to `~/.Trash`",
`ls` as eza text instead of objects (so `ls | Measure-Object` counts 0), `mkdir`
returning nothing, `cd` as zoxide, plus the loading banner on stdout.

So `profile.ps1` decides once whether the session is interactive
(`Test-DotfilesInteractiveSession`) and `profile.d/10-*` .. `80-*` bail out when
it is not — the equivalent of `[[ -o interactive ]] || return`. A session counts
as non-interactive when `CLAUDECODE`, `AI_AGENT` or `CI` is set, when the command
line has `-Command` / `-File` / `-EncodedCommand` / `-NonInteractive`, or when
the process is not user-interactive. `00-options.ps1` (PATH, UTF-8, XDG,
`$EDITOR`) still loads, since it changes no command's meaning.

The zsh side has the same guards: `.zshrc` returns early for `CLAUDECODE` /
`AI_AGENT` / `CI` (Claude Code already runs `unalias -a` over its shell snapshot,
but other agents use `zsh -ic`), and `.zprofile` only initialises zoxide for
interactive shells, so `zsh -lc 'cd ...'` keeps the real `cd`.

Notes:
- `rm` moves to `~/.Trash`. Use `Remove-Item` or `command rm` to really delete.
- inline autosuggestions need PSReadLine 2.1+ (`Install-Module PSReadLine`);
  Windows PowerShell 5.1 ships 2.0.
- <kbd>Ctrl</kbd>+<kbd>T</kbd> / <kbd>Ctrl</kbd>+<kbd>R</kbd> through fzf need
  `Install-Module PSFzf`.
- eza and starship icons need a nerd font in the terminal.
- set `DOTFILES_QUIET=1` to silence the loading banner.
