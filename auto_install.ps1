<#
.SYNOPSIS
    Windows counterpart of auto_install.sh : clone (or update) the repository in
    ~/.dotfiles and run install.ps1 .

.DESCRIPTION
    The clone in ~/.dotfiles is a deployment copy of what is on GitHub, not a
    place to work in: every run moves it to the latest commit of the remote's
    default branch, so the machine always gets the current configuration. Local
    changes found there are stashed and reported first, never discarded, and any
    git failure stops the run before install.ps1 links a stale tree.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/uthree/dotfiles/main/auto_install.ps1 | iex"
#>
[CmdletBinding()]
param(
    [string]$DotPath = (Join-Path $HOME '.dotfiles'),
    [string]$Repository = 'https://github.com/uthree/dotfiles'
)

$ErrorActionPreference = 'Stop'

# $ErrorActionPreference does not cover native commands: a failing git would
# otherwise leave the clone behind and still link it.
function Invoke-Git {
    param([string[]]$Arguments)
    & git @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

function Get-DefaultRef {
    param([string]$Path)
    $ref = & git -C $Path symbolic-ref --quiet --short refs/remotes/origin/HEAD
    if ($LASTEXITCODE -ne 0 -or -not $ref) {
        & git -C $Path remote set-head origin --auto | Out-Null
        $ref = & git -C $Path symbolic-ref --quiet --short refs/remotes/origin/HEAD
    }
    if ($LASTEXITCODE -ne 0 -or -not $ref) { return 'origin/main' }
    return $ref
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host 'git is required. install it first: winget install --id Git.Git' -ForegroundColor Red
    exit 1
}

if (Test-Path -LiteralPath (Join-Path $DotPath '.git')) {
    Write-Host "Updating dotfiles in $DotPath ..." -ForegroundColor Magenta
    Invoke-Git @('-C', $DotPath, 'fetch', '--prune', 'origin')

    $dirty = & git -C $DotPath status --porcelain
    if ($LASTEXITCODE -ne 0) { throw "git status failed in $DotPath" }
    if ($dirty) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        Write-Host '  this clone has local changes; stashing them:' -ForegroundColor Yellow
        $dirty | ForEach-Object { Write-Host "    $_" -ForegroundColor Yellow }
        Invoke-Git @('-C', $DotPath, 'stash', 'push', '--include-untracked', '--message', "auto_install-$stamp")
        Write-Host "    get them back with: git -C $DotPath stash pop" -ForegroundColor Yellow
    }

    $ref = Get-DefaultRef -Path $DotPath
    $branch = $ref -replace '^origin/', ''
    Invoke-Git @('-C', $DotPath, 'checkout', '-B', $branch, $ref)
} else {
    if (Test-Path -LiteralPath $DotPath) {
        $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
        Write-Host "$DotPath exists and is not a clone; moving it to $DotPath.bak-$stamp" -ForegroundColor Yellow
        Move-Item -LiteralPath $DotPath -Destination "$DotPath.bak-$stamp"
    }
    Write-Host 'Cloning dotfiles...' -ForegroundColor Magenta
    Invoke-Git @('clone', $Repository, $DotPath)
}

$head = & git -C $DotPath log --oneline -1
Write-Host "Now at $head" -ForegroundColor Green

& (Join-Path $DotPath 'install.ps1') -DotPath $DotPath

Write-Host 'Install complete!' -ForegroundColor Magenta
