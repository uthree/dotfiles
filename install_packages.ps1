<#
.SYNOPSIS
    Install the tools this repository configures, using winget.

.DESCRIPTION
    The aliases in .config/powershell/profile.d only turn themselves on when the
    tool they wrap exists, so a fresh Windows box behaves like a very plain
    PowerShell until these are installed.

    Already installed tools are skipped. Nothing here is required; run it with
    -DryRun first if you want to see the list.

    It also asks uv for a default Python, so that tools which shell out to
    python3 find a real interpreter rather than the Microsoft Store stub.

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
    # python package manager; the agent instructions assume uv for Python work
    'uv'       = 'astral-sh.uv'
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

# A Python on PATH. Anything that shells out to python3 (the yomiyasu skill, for
# one) finds only the Microsoft Store stub otherwise. uv holds the interpreter;
# --default adds the bare python and python3 shims beside it, in a directory that
# comes before WindowsApps on PATH. --default is experimental in uv and prints a
# warning; the shims are what matters.
$uvPath = (Get-Command uv -ErrorAction SilentlyContinue).Source
if (-not $uvPath) {
    # winget's shim directory, which this shell may not have on PATH yet
    $candidate = Join-Path $env:LOCALAPPDATA 'Microsoft\WinGet\Links\uv.exe'
    if (Test-Path $candidate) { $uvPath = $candidate }
}
if ($uvPath) {
    Write-Host 'installing the default Python (uv)...' -ForegroundColor Magenta
    if (-not $DryRun) {
        & $uvPath python install --default
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  uv python install failed with exit code $LASTEXITCODE" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host 'uv is not on PATH yet. run "uv python install --default" in a new shell.' -ForegroundColor Yellow
}

# PowerShell modules used by the profile
Write-Host 'installing PowerShell modules...' -ForegroundColor Magenta

# Windows PowerShell 5.1 asks for the NuGet provider on the first Install-Module,
# which a non-interactive run cannot answer.
if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
    if (-not $DryRun) {
        try {
            Install-PackageProvider -Name NuGet -Scope CurrentUser -Force -ErrorAction Stop | Out-Null
        } catch {
            Write-Host "  NuGet provider: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}
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
