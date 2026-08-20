# starship prompt, mirroring ~/.zshrc.d/starship.zsh .

if (Test-Command 'starship') {
    $starshipConfig = Join-Path $HOME '.config\starship.toml'
    if ((-not $env:STARSHIP_CONFIG) -and (Test-Path -LiteralPath $starshipConfig)) {
        $env:STARSHIP_CONFIG = $starshipConfig
    }
    Invoke-Expression (& starship init powershell)
}
