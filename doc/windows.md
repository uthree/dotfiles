# Windows

## Installing

```powershell
# clone into ~/.dotfiles and set everything up
irm https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.ps1 | iex

# same thing from a clone you already have
powershell -ExecutionPolicy Bypass -File .\auto_install.ps1

# set up only, from a clone you already have
powershell -ExecutionPolicy Bypass -File .\install.ps1
.\install.bat            # same thing, for double-clicking

# see what would happen first
powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
```

`auto_install.ps1` updates `~/.dotfiles` to the latest commit on GitHub
before setting things up: it fetches, stashes anything changed in that clone (reporting
it, with the `git stash pop` that brings it back) and moves the clone to the
remote default branch. A failing git stops the run, so a stale clone is never
installed. Treat `~/.dotfiles` as a deployment copy and work in a clone of your
own.

Then install the tools the configuration wraps (winget). Already installed tools
are skipped:

```powershell
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1
powershell -ExecutionPolicy Bypass -File .\install_packages.ps1 -IncludeOptional  # pwsh 7, alacritty, gsudo, nerd font
```

That run also asks uv for a default Python (`uv python install --default`),
which puts `python` and `python3` shims in uv's bin directory. Without them
`python3` resolves to the Microsoft Store stub, and anything that shells out to
it fails. When uv is installed in the same run it may not be on PATH yet; the
script says so, and the command can be run again in a new shell.

## How each file is reached

`install.ps1` links directories, and points applications at single files
instead of linking them:

| repository | how Windows reaches it |
| --- | --- |
| `.config/powershell` | junction at `~/.config/powershell`, plus a stub in `$PROFILE` (5.1 and 7) that dot-sources `profile.ps1` and sets `DOTFILES_ROOT` |
| `.config/helix` | junction at `~/.config/helix` + `%APPDATA%\helix` |
| `.config/alacritty` | junction at `~/.config/alacritty` + `%APPDATA%\alacritty` |
| `.config/starship.toml` | `STARSHIP_CONFIG`, set by `60-starship.ps1` from `DOTFILES_ROOT` |
| `.config/git/ignore` | `git config --global core.excludesFile` |
| `.claude/CLAUDE.md` | an `@path` import in `~/.claude/CLAUDE.md` |
| `.vimrc` | a `source` line in `~/.vimrc` and `~/_vimrc` |
| `.zshrc`, `.zprofile` | a `source` line, written only when zsh exists (MSYS2) or with `-IncludeZsh` |
| `.zshrc.d` | junction, under the same condition |

`zellij` has no Windows build, so its config is not linked.

`.config/zed/*.json` and the Codex configuration are not linked by either
installer. Zed and the Codex app rewrite their own configuration files as they
run, so a link to this repository is either broken by them or overwrites what
they wrote. The Zed files kept here are a starting point to copy by hand on a
new machine; the Codex settings are listed in
[coding-agents.md](coding-agents.md).

## Why single files are not linked

Symlinks need **Developer Mode** (Settings > System > For developers) or an
elevated shell. Without either, a file can only be hard-linked, and a hard link
breaks the moment anything replaces the file rather than writing in place: an
editor saving it, `git checkout`, a `cherry-pick`. What is left behind is a
stale copy, and nothing says so — the link count still reads 2 and the file is
still there.

So single files are not linked at all. Each one is reached through a pointer the
application reads by itself: an environment variable, a git setting, an import,
a `source` line. A pointer holds a path, so there is nothing to go stale, and
the generated one-liners are rewritten only when their content changes.

Directories are still linked, as a symlink or a junction. Both follow the
repository, and nothing that happens to the files inside it can break them.

Anything replaced on the way is renamed to `<name>.bak-<timestamp>` first. A
leftover link from an earlier run is removed instead, since it holds no content
of its own.

## Notes

- inline autosuggestions need PSReadLine 2.1+ (`Install-Module PSReadLine`);
  Windows PowerShell 5.1 ships 2.0.
- <kbd>Ctrl</kbd>+<kbd>T</kbd> / <kbd>Ctrl</kbd>+<kbd>R</kbd> through fzf need
  `Install-Module PSFzf`.
- eza and starship icons need a nerd font in the terminal.
