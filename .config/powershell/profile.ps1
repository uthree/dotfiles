# ~/.config/powershell/profile.ps1
#
# PowerShell counterpart of ~/.zshrc .
# `install.ps1` writes a tiny stub into $PROFILE which dot-sources this file,
# so everything defined below ends up in the global scope.

$dotfilesPowerShellRoot = $PSScriptRoot
if (-not $dotfilesPowerShellRoot) {
    $dotfilesPowerShellRoot = Join-Path $HOME '.config\powershell'
}
$dotfilesProfileD = Join-Path $dotfilesPowerShellRoot 'profile.d'

# `$DOTFILES_QUIET = $true` in ~/.specific.ps1 is too late to matter, so the
# environment variable is what silences the banner.
$dotfilesQuiet = ($env:DOTFILES_QUIET -eq '1')

if (-not $dotfilesQuiet) { Write-Host 'Loading ~/.config/powershell/profile.d ...' -ForegroundColor Magenta }

if (Test-Path -LiteralPath $dotfilesProfileD) {
    foreach ($config in @(Get-ChildItem -LiteralPath $dotfilesProfileD -Filter '*.ps1' | Sort-Object Name)) {
        if (-not $dotfilesQuiet) { Write-Host "- $($config.Name)" -ForegroundColor DarkGray }
        try {
            . $config.FullName
        } catch {
            Write-Host "  failed to load $($config.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    Write-Host "profile.d not found: $dotfilesProfileD" -ForegroundColor Red
}

if (-not $dotfilesQuiet) {
    Write-Host 'Done.' -ForegroundColor Magenta
    Write-Host ''
}

# per-machine settings, same idea as ~/.specific.zsh
$dotfilesSpecific = Join-Path $HOME '.specific.ps1'
if (Test-Path -LiteralPath $dotfilesSpecific) {
    . $dotfilesSpecific
} elseif (-not $dotfilesQuiet) {
    Write-Host ' ~/.specific.ps1 is not detected. write ~/.specific.ps1 if you need setting only this machine .' -ForegroundColor Magenta
}
