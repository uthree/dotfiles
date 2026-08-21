# starship prompt, mirroring ~/.zshrc.d/starship.zsh .

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

if (Test-Command 'starship') {
    $starshipConfig = Join-Path $HOME '.config\starship.toml'
    if ((-not $env:STARSHIP_CONFIG) -and (Test-Path -LiteralPath $starshipConfig)) {
        $env:STARSHIP_CONFIG = $starshipConfig
    }
    Invoke-Expression (& starship init powershell)
}
