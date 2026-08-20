# Encoding, XDG paths, PATH and the helpers used by the other profile.d files.

# --- UTF-8 -------------------------------------------------------------------
# The Windows console defaults to the legacy ANSI code page, which mangles nerd
# font icons (eza / starship) and non-ASCII paths.
try {
    [Console]::OutputEncoding = [System.Text.UTF8Encoding]::new($false)
    [Console]::InputEncoding = [System.Text.UTF8Encoding]::new($false)
    $OutputEncoding = [Console]::OutputEncoding
} catch {
    # some hosts (ISE, redirected stdin) refuse to change the console encoding
}
foreach ($cmdlet in 'Out-File', 'Set-Content', 'Add-Content') {
    $PSDefaultParameterValues["${cmdlet}:Encoding"] = 'utf8'
}

# --- XDG base directories ----------------------------------------------------
# Windows has no XDG spec, but starship / helix / git and this repo all assume
# ~/.config, so make the variables explicit instead of implicit.
if (-not $env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME = Join-Path $HOME '.config' }
if (-not $env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME = Join-Path $HOME '.cache' }
if (-not $env:XDG_DATA_HOME) { $env:XDG_DATA_HOME = Join-Path $HOME '.local\share' }

# --- helpers -----------------------------------------------------------------
# equivalent of `type foo &> /dev/null` in the zsh config
function Test-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# PowerShell resolves aliases before functions, so a Unix-shaped function only
# wins once the built-in alias of the same name points at it.
# Built-ins such as ls / rm / cd are ReadOnly *and* AllScope, and Set-Alias
# refuses to drop AllScope, so it has to be passed back in.
function Set-DotAlias {
    param(
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter(Mandatory = $true)][string]$Value
    )
    Set-Alias -Name $Name -Value $Value -Option AllScope -Scope Global -Force -ErrorAction SilentlyContinue
}

function Remove-BuiltinAlias {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Name)
    foreach ($n in $Name) {
        if (Test-Path -LiteralPath "Alias:$n") {
            Remove-Item -LiteralPath "Alias:$n" -Force -ErrorAction SilentlyContinue
        }
    }
}

# --- PATH --------------------------------------------------------------------
# ~/.local/bin and ~/.cargo/bin are where most of the tools in this repo land.
foreach ($dir in (Join-Path $HOME '.local\bin'), (Join-Path $HOME '.cargo\bin')) {
    if ((Test-Path -LiteralPath $dir) -and ($env:PATH -notlike "*$dir*")) {
        $env:PATH = "$dir;$env:PATH"
    }
}

# --- editor / pager ----------------------------------------------------------
foreach ($editor in 'hx', 'nvim', 'vim') {
    if (Test-Command $editor) {
        $env:EDITOR = $editor
        $env:VISUAL = $editor
        break
    }
}
if (-not $env:EDITOR) { $env:EDITOR = 'notepad' }

if (Test-Command 'less') {
    $env:PAGER = 'less'
    if (-not $env:LESS) { $env:LESS = '-R' }
}
