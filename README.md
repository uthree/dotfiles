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

- Trash: `rm` moves to `~/.Trash/` instead of deleting
- command aliases
- instructions for [Claude Code](https://claude.com/claude-code) and agents that support `AGENTS.md`

## Requirements
- zsh (Linux / macOS)
- Windows PowerShell 5.1 or PowerShell 7 (Windows)

## Installation

### Linux / macOS
```sh
curl -fsSL https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.sh | sh
```

### Windows
```powershell
irm https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.ps1 | iex
```

Both clone this repository into `~/.dotfiles` and link everything into place.
Running them again updates the clone and re-links.

See [doc/windows.md](doc/windows.md) for the other entry points and for what
gets linked where.

## Documentation
- [doc/windows.md](doc/windows.md): installing and linking on Windows
- [doc/shell.md](doc/shell.md): what the shell configuration provides
- [doc/coding-agents.md](doc/coding-agents.md): why the aliases are interactive only
