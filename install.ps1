<#
.SYNOPSIS
    Windows counterpart of install.sh .

.DESCRIPTION
    Links the configuration files of this repository into the places Windows
    applications actually read, and installs a $PROFILE stub that loads
    .config/powershell/profile.ps1 .

    Symlinks need Developer Mode (Settings > System > For developers) or an
    elevated shell. Without either, directories fall back to junctions and files
    to hard links, both of which work unprivileged; a plain copy is the last
    resort and is reported as such, because a copy no longer follows the repo.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
#>
[CmdletBinding()]
param(
    # print what would happen without touching anything
    [switch]$DryRun,
    # also link .zshrc / .zprofile / .zshrc.d (useful with MSYS2 zsh)
    [switch]$IncludeZsh,
    # location of this repository
    [string]$DotPath
)

$ErrorActionPreference = 'Stop'

if (-not $DotPath) { $DotPath = $PSScriptRoot }
if (-not $DotPath) { $DotPath = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $DotPath) { throw 'could not determine the repository path; pass -DotPath' }
$script:Copied = @()
$script:Failed = @()

function Write-Step {
    param([string]$Message, [string]$Color = 'Gray')
    Write-Host $Message -ForegroundColor $Color
}

function Test-AlreadyLinked {
    param([string]$Destination, [string]$Source, [bool]$IsDir)

    $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if (-not $item.LinkType) { return $false }

    foreach ($t in @($item.Target)) {
        if ($t -and ($t.TrimEnd('\') -eq $Source.TrimEnd('\'))) { return $true }
    }

    # Windows PowerShell 5.1 does not report a usable target for hard links, so
    # fall back to comparing content: identical means the link is already good.
    if ((-not $IsDir) -and ($item.LinkType -eq 'HardLink')) {
        try {
            $a = (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash
            $b = (Get-FileHash -LiteralPath $Source -Algorithm SHA256).Hash
            return ($a -eq $b)
        } catch {
            return $false
        }
    }

    return $false
}

function Backup-Existing {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = "$Path.bak-$stamp"
    Write-Step "    backing up existing -> $backup" 'Yellow'
    if (-not $DryRun) { Move-Item -LiteralPath $Path -Destination $backup -Force }
}

function New-DotLink {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Step "    skip (missing in repo): $Source" 'DarkGray'
        return
    }

    $resolved = (Resolve-Path -LiteralPath $Source).Path
    $isDir = (Get-Item -LiteralPath $resolved).PSIsContainer

    Write-Step "  $Destination"

    if (Test-AlreadyLinked -Destination $Destination -Source $resolved -IsDir $isDir) {
        Write-Step '    already linked' 'DarkGray'
        return
    }

    $parent = Split-Path -Parent $Destination
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        Write-Step "    creating $parent" 'DarkGray'
        if (-not $DryRun) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    }

    if (Test-Path -LiteralPath $Destination) { Backup-Existing $Destination }
    if ($DryRun) { Write-Step '    would link' 'DarkGray'; return }

    # 1. symbolic link (needs Developer Mode or elevation)
    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $resolved -Force -ErrorAction Stop | Out-Null
        Write-Step '    symlink' 'Green'
        return
    } catch {}

    # 2. junction (directories) / hard link (files) both work unprivileged
    try {
        if ($isDir) {
            New-Item -ItemType Junction -Path $Destination -Target $resolved -ErrorAction Stop | Out-Null
            Write-Step '    junction' 'Green'
        } else {
            New-Item -ItemType HardLink -Path $Destination -Target $resolved -ErrorAction Stop | Out-Null
            Write-Step '    hardlink' 'Green'
        }
        return
    } catch {}

    # 3. copy, which no longer follows the repository
    try {
        if ($isDir) { Copy-Item -LiteralPath $resolved -Destination $Destination -Recurse -Force }
        else { Copy-Item -LiteralPath $resolved -Destination $Destination -Force }
        Write-Step '    copied (NOT linked)' 'Yellow'
        $script:Copied += $Destination
    } catch {
        Write-Step "    failed: $($_.Exception.Message)" 'Red'
        $script:Failed += $Destination
    }
}

# --- destinations ------------------------------------------------------------
$appData = $env:APPDATA
$configDir = Join-Path $HOME '.config'

$links = [ordered]@{
    # these read ~/.config on Windows as well
    '.config/starship.toml'     = @((Join-Path $configDir 'starship.toml'))
    '.config/git/ignore'        = @((Join-Path $configDir 'git\ignore'))
    '.config/powershell'        = @((Join-Path $configDir 'powershell'))
    # vim on Windows prefers _vimrc but still reads .vimrc
    '.vimrc'                    = @((Join-Path $HOME '.vimrc'), (Join-Path $HOME '_vimrc'))
    # helix and alacritty look in %APPDATA% on Windows
    '.config/helix'             = @((Join-Path $configDir 'helix'), (Join-Path $appData 'helix'))
    '.config/alacritty'         = @((Join-Path $configDir 'alacritty'), (Join-Path $appData 'alacritty'))
    # zed looks in %APPDATA%\Zed on Windows
    '.config/zed/settings.json' = @((Join-Path $configDir 'zed\settings.json'), (Join-Path $appData 'Zed\settings.json'))
    '.config/zed/keymap.json'   = @((Join-Path $configDir 'zed\keymap.json'), (Join-Path $appData 'Zed\keymap.json'))
}

if ($IncludeZsh -or (Get-Command zsh -ErrorAction SilentlyContinue)) {
    $links['.zshrc'] = @((Join-Path $HOME '.zshrc'))
    $links['.zprofile'] = @((Join-Path $HOME '.zprofile'))
    $links['.zshrc.d'] = @((Join-Path $HOME '.zshrc.d'))
}

Write-Step "dotfiles: $DotPath" 'Magenta'
if ($DryRun) { Write-Step 'dry run: nothing will be written' 'Yellow' }
Write-Step 'generating links...' 'Magenta'

foreach ($entry in $links.GetEnumerator()) {
    $source = Join-Path $DotPath ($entry.Key -replace '/', '\')
    foreach ($destination in $entry.Value) {
        New-DotLink -Source $source -Destination $destination
    }
}

# zellij has no Windows build, so .config/zellij is deliberately not linked.

# --- $PROFILE stubs ----------------------------------------------------------
Write-Step 'installing PowerShell profile...' 'Magenta'

$profileSource = Join-Path $DotPath '.config\powershell\profile.ps1'
$documents = [Environment]::GetFolderPath('MyDocuments')
if (-not $documents) { $documents = Join-Path $HOME 'Documents' }
$profilePaths = @(
    (Join-Path $documents 'WindowsPowerShell\profile.ps1'), # Windows PowerShell 5.1
    (Join-Path $documents 'PowerShell\profile.ps1')         # PowerShell 7+
)

$stub = @"
# generated by uthree/dotfiles install.ps1 -- edit the repository instead
`$dotfilesProfile = '$profileSource'
if (Test-Path -LiteralPath `$dotfilesProfile) { . `$dotfilesProfile }
"@

foreach ($p in $profilePaths) {
    Write-Step "  $p"
    if ($DryRun) { Write-Step '    would write stub' 'DarkGray'; continue }

    $parent = Split-Path -Parent $p
    if (-not (Test-Path -LiteralPath $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }

    if (Test-Path -LiteralPath $p) {
        $existing = Get-Content -LiteralPath $p -Raw -ErrorAction SilentlyContinue
        if ($existing -and ($existing.Trim() -eq $stub.Trim())) {
            Write-Step '    already installed' 'DarkGray'
            continue
        }
        if ($existing -and ($existing -notmatch 'uthree/dotfiles')) { Backup-Existing $p }
    }
    Set-Content -LiteralPath $p -Value $stub -Encoding UTF8
    Write-Step '    stub written' 'Green'
}

# --- report ------------------------------------------------------------------
Write-Host ''
if ($script:Copied.Count -gt 0) {
    Write-Step 'copied instead of linked, so these will not follow the repository:' 'Yellow'
    $script:Copied | ForEach-Object { Write-Step "  $_" 'Yellow' }
    Write-Step 'enable Developer Mode (Settings > System > For developers) and re-run for real symlinks.' 'Yellow'
}
if ($script:Failed.Count -gt 0) {
    Write-Step 'failed:' 'Red'
    $script:Failed | ForEach-Object { Write-Step "  $_" 'Red' }
}

Write-Step 'install complete!' 'Magenta'
Write-Step 'open a new shell, or run: . $PROFILE' 'DarkGray'
Write-Step 'missing tools? run: .\install_packages.ps1' 'DarkGray'
