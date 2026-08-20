<#
.SYNOPSIS
    Install the tools this repository configures, using winget.

.DESCRIPTION
    The aliases in .config/powershell/profile.d only turn themselves on when the
    tool they wrap exists, so a fresh Windows box behaves like a very plain
    PowerShell until these are installed.

    Already installed tools are skipped. Nothing here is required; run it with
    -DryRun first if you want to see the list.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install_packages.ps1 -DryRun
    powershell -ExecutionPolicy Bypass -File .\install_packages.ps1
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    # also install the optional extras (PowerShell 7, alacritty, nerd font, gsudo)
    [switch]$IncludeOptional
)

if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host 'winget is not available. install "App Installer" from the Microsoft Store first.' -ForegroundColor Red
    exit 1
}

# command name -> winget package id
$packages = [ordered]@{
    'git'      = 'Git.Git'
    'starship' = 'Starship.Starship'
    'eza'      = 'eza-community.eza'
    'zoxide'   = 'ajeetdsouza.zoxide'
    'fzf'      = 'junegunn.fzf'
    'bat'      = 'sharkdp.bat'
    'fd'       = 'sharkdp.fd'
    'rg'       = 'BurntSushi.ripgrep.MSVC'
    'hx'       = 'Helix.Helix'
    'vim'      = 'vim.vim'
}

$optional = [ordered]@{
    'pwsh'      = 'Microsoft.PowerShell'
    'alacritty' = 'Alacritty.Alacritty'
    'gsudo'     = 'gerardog.gsudo'
    # nerd font, needed for the icons eza and starship print
    'font'      = 'DEVCOM.JetBrainsMonoNerdFont'
}

if ($IncludeOptional) {
    foreach ($k in $optional.Keys) { $packages[$k] = $optional[$k] }
}

foreach ($entry in $packages.GetEnumerator()) {
    $command = $entry.Key
    $id = $entry.Value

    if (($command -ne 'font') -and (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Host "already installed: $command" -ForegroundColor DarkGray
        continue
    }

    Write-Host "installing $id ..." -ForegroundColor Magenta
    if ($DryRun) { continue }

    winget install --id $id --exact --silent `
        --accept-package-agreements --accept-source-agreements
}

# PowerShell modules used by the profile
Write-Host 'installing PowerShell modules...' -ForegroundColor Magenta
$modules = @(
    @{ Name = 'PSReadLine'; Reason = 'autosuggestions (PSReadLine 2.1+)' },
    @{ Name = 'PSFzf'; Reason = 'Ctrl+T / Ctrl+R fzf key bindings' }
)
foreach ($m in $modules) {
    Write-Host "  $($m.Name) - $($m.Reason)" -ForegroundColor DarkGray
    if ($DryRun) { continue }
    try {
        Install-Module -Name $m.Name -Scope CurrentUser -Force -AllowClobber -SkipPublisherCheck -ErrorAction Stop
    } catch {
        Write-Host "    failed: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'done. open a new shell so PATH and the profile pick everything up.' -ForegroundColor Magenta
if (-not $IncludeOptional) {
    Write-Host 'run with -IncludeOptional for PowerShell 7, alacritty, gsudo and a nerd font.' -ForegroundColor DarkGray
}
