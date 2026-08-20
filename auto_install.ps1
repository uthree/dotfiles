<#
.SYNOPSIS
    Windows counterpart of auto_install.sh : clone (or update) the repository in
    ~/.dotfiles and run install.ps1 .

.EXAMPLE
    powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.ps1 | iex"
#>
[CmdletBinding()]
param(
    [string]$DotPath = (Join-Path $HOME '.dotfiles'),
    [string]$Repository = 'https://github.com/uthree/dotfiles'
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'git is required. install it first: winget install --id Git.Git' -ForegroundColor Red
    exit 1
}

if (Test-Path -LiteralPath (Join-Path $DotPath '.git')) {
    Write-Host "Updating dotfiles in $DotPath ..." -ForegroundColor Magenta
    git -C $DotPath pull --ff-only
} else {
    if (Test-Path -LiteralPath $DotPath) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        Write-Host "$DotPath exists and is not a clone; moving it to $DotPath.bak-$stamp" -ForegroundColor Yellow
        Move-Item -LiteralPath $DotPath -Destination "$DotPath.bak-$stamp"
    }
    Write-Host 'Cloning dotfiles...' -ForegroundColor Magenta
    git clone $Repository $DotPath
}

Write-Host 'Done' -ForegroundColor Magenta

& (Join-Path $DotPath 'install.ps1') -DotPath $DotPath

Write-Host 'Install complete!' -ForegroundColor Magenta
