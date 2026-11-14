<#
.SYNOPSIS
    Windows counterpart of install.sh .

.DESCRIPTION
    Points Windows applications at the configuration files in this repository.

    Directories are linked: a symlink, or a junction when Developer Mode is
    off. Both follow the repository, and nothing that happens to the files
    inside it can break them.

    Single files are not linked at all. Each one gets a pointer the application
    reads by itself: a $PROFILE stub, a `source` line, a CLAUDE.md import, an
    environment variable, a git setting. Linking a file on Windows means a hard
    link whenever Developer Mode is off, and a hard link breaks the moment
    anything replaces the file -- an editor saving it, `git checkout`, a
    `cherry-pick`. What is left behind is a stale copy with nothing to say so.
    A pointer holds a path, so it cannot go stale.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -DryRun
#>
[CmdletBinding()]
param(
    # print what would happen without touching anything
    [switch]$DryRun,
    # also set up .zshrc / .zprofile / .zshrc.d (useful with MSYS2 zsh)
    [switch]$IncludeZsh,
    # location of this repository
    [string]$DotPath
)

$ErrorActionPreference = 'Stop'

if (-not $DotPath) { $DotPath = $PSScriptRoot }
if (-not $DotPath) { $DotPath = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $DotPath) { throw 'could not determine the repository path; pass -DotPath' }
$script:Failed = @()
$script:Notes = @()

function Write-Step {
    param([string]$Message, [string]$Color = 'Gray')
    Write-Host $Message -ForegroundColor $Color
}

# Windows applications take a forward-slash path, and it needs no escaping
# inside a configuration file.
function Get-PointerPath {
    param([string]$Path)
    return ($Path -replace '\\', '/')
}

function Backup-Existing {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $backup = "$Path.bak-$stamp"
    Write-Step "    backing up existing -> $backup" 'Yellow'
    if (-not $DryRun) { Move-Item -LiteralPath $Path -Destination $backup -Force }
}

# A destination left over from when this script linked files holds no content of
# its own, so it is replaced without leaving a .bak behind. Removing one name of
# a hard link does not touch the file in the repository.
function Remove-StaleLink {
    param([string]$Path)
    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if (-not $item.LinkType) { return $false }
    Write-Step "    removing the old $($item.LinkType.ToLowerInvariant())" 'DarkGray'
    if (-not $DryRun) { Remove-Item -LiteralPath $Path -Force -Recurse }
    return $true
}

function Test-AlreadyLinked {
    param([string]$Destination, [string]$Source)

    $item = Get-Item -LiteralPath $Destination -Force -ErrorAction SilentlyContinue
    if (-not $item) { return $false }
    if (-not $item.LinkType) { return $false }

    foreach ($t in @($item.Target)) {
        if ($t -and ($t.TrimEnd('\') -eq $Source.TrimEnd('\'))) { return $true }
    }
    return $false
}

function New-DotDirLink {
    param(
        [Parameter(Mandatory = $true)][string]$Source,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if (-not (Test-Path -LiteralPath $Source)) {
        Write-Step "    skip (missing in repo): $Source" 'DarkGray'
        return
    }

    $resolved = (Resolve-Path -LiteralPath $Source).Path
    Write-Step "  $Destination"

    if (Test-AlreadyLinked -Destination $Destination -Source $resolved) {
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

    # a symbolic link needs Developer Mode or elevation; a junction does not,
    # and for a directory the two behave the same way here.
    try {
        New-Item -ItemType SymbolicLink -Path $Destination -Target $resolved -Force -ErrorAction Stop | Out-Null
        Write-Step '    symlink' 'Green'
        return
    } catch {}

    try {
        New-Item -ItemType Junction -Path $Destination -Target $resolved -ErrorAction Stop | Out-Null
        Write-Step '    junction' 'Green'
        return
    } catch {
        Write-Step "    failed: $($_.Exception.Message)" 'Red'
        $script:Failed += $Destination
    }
}

# A generated one-liner naming a path in the repository. It is rewritten only
# when its content changed, so re-running leaves no new .bak behind.
function Write-Pointer {
    param(
        [Parameter(Mandatory = $true)][string]$Destination,
        [Parameter(Mandatory = $true)][string]$Content,
        # Windows PowerShell reads a .ps1 as ANSI unless it starts with a BOM
        [switch]$Bom
    )

    Write-Step "  $Destination"

    $existing = $null
    if (Test-Path -LiteralPath $Destination) {
        $existing = Get-Content -LiteralPath $Destination -Raw -ErrorAction SilentlyContinue
        if ($existing -and ($existing.Trim() -eq $Content.Trim())) {
            Write-Step '    already written' 'DarkGray'
            return
        }
    }

    if ($DryRun) { Write-Step '    would write' 'DarkGray'; return }

    $parent = Split-Path -Parent $Destination
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Destination) {
        if (-not (Remove-StaleLink $Destination)) {
            # a file of your own, rather than a pointer of ours
            if ($existing -and ($existing -notmatch 'uthree/dotfiles')) { Backup-Existing $Destination }
        }
    }

    if ($Bom) {
        Set-Content -LiteralPath $Destination -Value $Content -Encoding UTF8
    } else {
        $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
        [System.IO.File]::WriteAllText($Destination, ($Content + [Environment]::NewLine), $utf8NoBom)
    }
    Write-Step '    written' 'Green'
}

# --- directories -------------------------------------------------------------
$appData = $env:APPDATA
$configDir = Join-Path $HOME '.config'
$dotRoot = (Resolve-Path -LiteralPath $DotPath).Path

$dirLinks = [ordered]@{
    # read from ~/.config on Windows as well
    '.config/powershell' = @((Join-Path $configDir 'powershell'))
    # helix and alacritty look in %APPDATA% too
    '.config/helix'      = @((Join-Path $configDir 'helix'), (Join-Path $appData 'helix'))
    '.config/alacritty'  = @((Join-Path $configDir 'alacritty'), (Join-Path $appData 'alacritty'))
}

$withZsh = [bool]($IncludeZsh -or (Get-Command zsh -ErrorAction SilentlyContinue))
if ($withZsh) { $dirLinks['.zshrc.d'] = @((Join-Path $HOME '.zshrc.d')) }

Write-Step "dotfiles: $dotRoot" 'Magenta'
if ($DryRun) { Write-Step 'dry run: nothing will be written' 'Yellow' }
Write-Step 'linking directories...' 'Magenta'

foreach ($entry in $dirLinks.GetEnumerator()) {
    $source = Join-Path $dotRoot ($entry.Key -replace '/', '\')
    foreach ($destination in $entry.Value) {
        New-DotDirLink -Source $source -Destination $destination
    }
}

# zellij has no Windows build, so .config/zellij is deliberately not linked.
#
# .config/zed/*.json and the Codex configuration are not set up by either
# installer: both applications rewrite their own files as they run.

# --- pointers ----------------------------------------------------------------
Write-Step 'writing pointers...' 'Magenta'

# $PROFILE, for Windows PowerShell 5.1 and PowerShell 7. DOTFILES_ROOT is how
# profile.d finds the repository; everything else it needs is a path inside it.
$documents = [Environment]::GetFolderPath('MyDocuments')
if (-not $documents) { $documents = Join-Path $HOME 'Documents' }
$profileSource = Join-Path $dotRoot '.config\powershell\profile.ps1'
$profileStub = @"
# generated by uthree/dotfiles install.ps1 -- edit the repository instead
`$env:DOTFILES_ROOT = '$dotRoot'
`$dotfilesProfile = '$profileSource'
if (Test-Path -LiteralPath `$dotfilesProfile) { . `$dotfilesProfile }
"@

foreach ($p in @(
    (Join-Path $documents 'WindowsPowerShell\profile.ps1'),
    (Join-Path $documents 'PowerShell\profile.ps1')
)) {
    Write-Pointer -Destination $p -Content $profileStub -Bom
}

# vim prefers _vimrc on Windows and reads .vimrc as well
$vimrcStub = @"
" generated by uthree/dotfiles install.ps1 -- edit the repository instead
source $(Get-PointerPath (Join-Path $dotRoot '.vimrc'))
"@
foreach ($p in @((Join-Path $HOME '.vimrc'), (Join-Path $HOME '_vimrc'))) {
    Write-Pointer -Destination $p -Content $vimrcStub
}

# claude code expands an `@path` import, so the global instructions are one
# line naming the file in the repository. A user-scope CLAUDE.md is trusted,
# so the import needs no approval.
$claudeStub = @"
<!-- generated by uthree/dotfiles install.ps1 -- edit the repository instead -->
The instructions below are imported from the dotfiles repository. If none
follow, the import did not resolve: run install.ps1 again.

@$(Get-PointerPath (Join-Path $dotRoot '.claude/CLAUDE.md'))
"@
Write-Pointer -Destination (Join-Path $HOME '.claude\CLAUDE.md') -Content $claudeStub

if ($withZsh) {
    # MSYS2 zsh takes a forward-slash Windows path. STARSHIP_CONFIG is set here
    # because starship.zsh is shared with Linux, where install.sh links the file
    # into ~/.config as usual.
    $zshStub = @"
# generated by uthree/dotfiles install.ps1 -- edit the repository instead
export DOTFILES_ROOT='$(Get-PointerPath $dotRoot)'
export STARSHIP_CONFIG="`$DOTFILES_ROOT/.config/starship.toml"
source "`$DOTFILES_ROOT/.zshrc"
"@
    Write-Pointer -Destination (Join-Path $HOME '.zshrc') -Content $zshStub

    $zprofileStub = @"
# generated by uthree/dotfiles install.ps1 -- edit the repository instead
source '$(Get-PointerPath (Join-Path $dotRoot '.zprofile'))'
"@
    Write-Pointer -Destination (Join-Path $HOME '.zprofile') -Content $zprofileStub
}

# --- settings ----------------------------------------------------------------
# starship and git read a setting rather than a fixed path in $HOME, so neither
# file needs anything in ~/.config. 60-starship.ps1 sets STARSHIP_CONFIG from
# $env:DOTFILES_ROOT.
Write-Step 'settings...' 'Magenta'

$ignorePath = Get-PointerPath (Join-Path $dotRoot '.config/git/ignore')
Write-Step '  git config --global core.excludesFile'
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Step '    skip: git is not installed' 'Yellow'
} else {
    # `--get` exits 1 when the key is unset, and PowerShell 7.4 turns that into
    # a terminating error under $ErrorActionPreference = 'Stop'.
    $current = $null
    try { $current = & git config --global --get core.excludesFile } catch { $current = $null }
    if ($LASTEXITCODE -ne 0) { $current = $null }
    if ($current -eq $ignorePath) {
        Write-Step '    already set' 'DarkGray'
    } elseif ($current -and ($current -notmatch 'dotfiles')) {
        Write-Step "    leaving your own setting alone: $current" 'Yellow'
        $script:Notes += "core.excludesFile points at $current, not $ignorePath"
    } elseif ($DryRun) {
        Write-Step "    would set it to $ignorePath" 'DarkGray'
    } else {
        & git config --global core.excludesFile $ignorePath
        Write-Step "    set to $ignorePath" 'Green'
    }
}

# Files this script used to link and no longer does. A leftover link is
# removed; a file of your own is left where it is.
foreach ($stale in @(
    (Join-Path $configDir 'starship.toml'),
    (Join-Path $configDir 'git\ignore')
)) {
    if (-not (Test-Path -LiteralPath $stale)) { continue }
    Write-Step "  $stale (no longer linked)"
    if (-not (Remove-StaleLink $stale)) {
        Write-Step '    left alone: not a link' 'Yellow'
        $script:Notes += "$stale is yours, and nothing reads it now"
    }
}

# --- report ------------------------------------------------------------------
Write-Host ''
if ($script:Failed.Count -gt 0) {
    Write-Step 'failed:' 'Red'
    $script:Failed | ForEach-Object { Write-Step "  $_" 'Red' }
}
if ($script:Notes.Count -gt 0) {
    Write-Step 'worth a look:' 'Yellow'
    $script:Notes | ForEach-Object { Write-Step "  $_" 'Yellow' }
}

Write-Step 'install complete!' 'Magenta'
Write-Step 'open a new shell, or run: . $PROFILE' 'DarkGray'
Write-Step 'missing tools? run: .\install_packages.ps1' 'DarkGray'
