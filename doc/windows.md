# Windows

## Installing

```powershell
# clone into ~/.dotfiles and link everything
irm https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.ps1 | iex

# same thing from a clone you already have
powershell -ExecutionPolicy Bypass -File .\auto_install.ps1

# link only, from a clone you already have
powershell -ExecutionPolicy Bypass -File .\install.ps1
.\install.bat            # same thing, for double-clicking

# see what would happen first
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
```

Then install the tools the configuration wraps (winget). Already installed tools
are skipped:

```powershell
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1 -IncludeOptional  # pwsh 7, alacritty, gsudo, nerd font
```

## What gets linked where

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

## Symlinks, junctions and hard links

Symlinks need **Developer Mode** (Settings > System > For developers) or an
elevated shell. Without either, directories fall back to junctions and files to
hard links — both work unprivileged, and `install.ps1` reports which files ended
up as hard links.

A hard link breaks silently when an application saves by replacing the file
rather than writing in place, and the file then stops following the repository.
Enable Developer Mode and re-run `install.ps1` to convert everything to real
symlinks.

A plain copy is the last resort and is reported at the end of the run for the
same reason. Anything that gets replaced is renamed to `<name>.bak-<timestamp>`
first.

## Notes

- inline autosuggestions need PSReadLine 2.1+ (`Install-Module PSReadLine`);
  Windows PowerShell 5.1 ships 2.0.
- <kbd>Ctrl</kbd>+<kbd>T</kbd> / <kbd>Ctrl</kbd>+<kbd>R</kbd> through fzf need
  `Install-Module PSFzf`.
- eza and starship icons need a nerd font in the terminal.
