# starship prompt, mirroring ~/.zshrc.d/starship.zsh .

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

if (Test-Command 'starship') {
    # The config is read straight out of the repository: $env:DOTFILES_ROOT
    # comes from the $PROFILE stub install.ps1 writes, so nothing has to be
    # linked into ~/.config for starship to find it.
    if (-not $env:STARSHIP_CONFIG) {
        $starshipConfig = $null
        if ($env:DOTFILES_ROOT) {
            $starshipConfig = Join-Path $env:DOTFILES_ROOT '.config\starship.toml'
        }
        # a hand-made setup without the stub
        if ((-not $starshipConfig) -or (-not (Test-Path -LiteralPath $starshipConfig))) {
            $starshipConfig = Join-Path $HOME '.config\starship.toml'
        }
        if (Test-Path -LiteralPath $starshipConfig) {
            $env:STARSHIP_CONFIG = $starshipConfig
        }
    }
    Invoke-Expression (& starship init powershell)
}
