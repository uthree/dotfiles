# fzf, mirroring the fzf block in ~/.zshrc.d/alias.zsh .
# Ctrl+T (files) and Ctrl+R (history) need the PSFzf module:
#   Install-Module PSFzf -Scope CurrentUser

if (Test-Command 'fzf') {
    if (Test-Command 'bat') {
        $fzfPreview = '--preview "bat --color=always --style=header,grid --line-range :100 {}"'
        if (-not $env:FZF_DEFAULT_OPTS) { $env:FZF_DEFAULT_OPTS = $fzfPreview }
        if (-not $env:FZF_CTRL_T_OPTS) { $env:FZF_CTRL_T_OPTS = $fzfPreview }
    }
    if (Test-Command 'fd') {
        $env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    }

    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf -ErrorAction SilentlyContinue
        try {
            Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        } catch {}
    }
}
