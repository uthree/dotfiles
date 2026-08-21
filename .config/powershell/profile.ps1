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

# zsh only reads ~/.zshrc for interactive shells; PowerShell has no such rule and
# runs $PROFILE for `-Command` / `-File` runs as well. Coding agents, scripts and
# CI go through exactly that path, and would silently get `rm` as "move to
# trash", `ls` as eza text instead of objects, and `cd` as zoxide.
# So decide here, and let profile.d/10-* .. 80-* opt out.
function Test-DotfilesInteractiveSession {
    # agents / CI announce themselves
    if ($env:CLAUDECODE -or $env:AI_AGENT -or $env:CI) { return $false }

    # -Command / -File / -EncodedCommand / -NonInteractive all mean
    # "run this and exit", not "give the user a prompt".
    # PowerShell accepts any unambiguous prefix, so compare by prefix.
    $scripted = @('command', 'file', 'encodedcommand', 'noninteractive')
    foreach ($a in [Environment]::GetCommandLineArgs()) {
        if ($a -notmatch '^-') { continue }
        $name = $a.TrimStart('-').ToLowerInvariant()
        if (-not $name) { continue }
        foreach ($s in $scripted) {
            if ($s.StartsWith($name)) { return $false }
        }
    }

    if (-not [Environment]::UserInteractive) { return $false }
    return $true
}

$global:DotfilesInteractive = Test-DotfilesInteractiveSession

# `$DOTFILES_QUIET = $true` in ~/.specific.ps1 is too late to matter, so the
# environment variable is what silences the banner.
$dotfilesQuiet = ($env:DOTFILES_QUIET -eq '1') -or (-not $global:DotfilesInteractive)

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
