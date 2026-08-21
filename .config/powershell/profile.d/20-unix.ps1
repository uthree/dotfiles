# Unix-shaped commands that Windows does not ship, so muscle memory from the
# zsh side keeps working. Only commands that are missing (or that behave
# differently enough to be surprising) are defined here.

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

# `which git` -> path of the executable, like the Unix tool
function which {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Name)
    foreach ($n in $Name) {
        $cmd = Get-Command -Name $n -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $cmd) { Write-Error "which: $n not found"; continue }
        if ($cmd.Path) { $cmd.Path } else { "$($cmd.CommandType): $($cmd.Name)" }
    }
}

# `touch file...` : create when missing, bump the timestamp when it exists
function touch {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Path)
    foreach ($p in $Path) {
        if (Test-Path -LiteralPath $p) {
            (Get-Item -LiteralPath $p).LastWriteTime = Get-Date
        } else {
            $parent = Split-Path -Parent $p
            if ($parent -and -not (Test-Path -LiteralPath $parent)) {
                New-Item -ItemType Directory -Path $parent -Force | Out-Null
            }
            New-Item -ItemType File -Path $p | Out-Null
        }
    }
}

# PowerShell's own mkdir chokes on `-p`; swallow it and always act like mkdir -p
function mkdir {
    $dirs = @()
    foreach ($a in $args) {
        if ([string]$a -like '-*') { continue }
        $dirs += [string]$a
    }
    foreach ($d in $dirs) {
        if (-not (Test-Path -LiteralPath $d)) {
            New-Item -ItemType Directory -Path $d -Force | Out-Null
        }
    }
}

# `head [-n N] [file...]`, also works in a pipeline
function head {
    $n = 10
    $files = @()
    for ($i = 0; $i -lt $args.Count; $i++) {
        $a = [string]$args[$i]
        if ($a -eq '-n') { $i++; $n = [int]$args[$i] }
        elseif ($a -match '^-(\d+)$') { $n = [int]$Matches[1] }
        elseif ($a -like '-*') { continue }
        else { $files += $a }
    }
    if ($files.Count -gt 0) { Get-Content -LiteralPath $files -TotalCount $n }
    else { $input | Select-Object -First $n }
}

# `tail [-n N] [-f] [file...]`, also works in a pipeline
function tail {
    $n = 10
    $follow = $false
    $files = @()
    for ($i = 0; $i -lt $args.Count; $i++) {
        $a = [string]$args[$i]
        if ($a -eq '-n') { $i++; $n = [int]$args[$i] }
        elseif ($a -match '^-(\d+)$') { $n = [int]$Matches[1] }
        elseif ($a -eq '-f' -or $a -eq '-F') { $follow = $true }
        elseif ($a -like '-*') { continue }
        else { $files += $a }
    }
    if ($files.Count -gt 0) {
        if ($follow) { Get-Content -LiteralPath $files -Tail $n -Wait }
        else { Get-Content -LiteralPath $files -Tail $n }
    } else {
        $input | Select-Object -Last $n
    }
}

# ripgrep when it is installed, a small Select-String shim otherwise
function grep {
    $stdin = @($input)

    if (Test-Command 'rg') {
        if ($stdin.Count -gt 0) { $stdin | & rg @args } else { & rg @args }
        return
    }

    $pattern = $null
    $files = @()
    $caseInsensitive = $false
    $recurse = $false
    foreach ($a in $args) {
        $s = [string]$a
        if ($s -like '-*') {
            if ($s -cmatch 'i') { $caseInsensitive = $true }
            if ($s -match 'r|R') { $recurse = $true }
            continue
        }
        if ($null -eq $pattern) { $pattern = $s } else { $files += $s }
    }
    if ($null -eq $pattern) { Write-Error 'grep: no pattern given'; return }

    if ($files.Count -eq 0) {
        $stdin | Select-String -Pattern $pattern -CaseSensitive:(-not $caseInsensitive)
    } elseif ($recurse) {
        Get-ChildItem -LiteralPath $files -Recurse -File |
            Select-String -Pattern $pattern -CaseSensitive:(-not $caseInsensitive)
    } else {
        Select-String -Path $files -Pattern $pattern -CaseSensitive:(-not $caseInsensitive)
    }
}

# `ln -s target link` / `ln target link`
function ln {
    $symbolic = $false
    $force = $false
    $operands = @()
    foreach ($a in $args) {
        $s = [string]$a
        if ($s -like '-*') {
            if ($s -match 's') { $symbolic = $true }
            if ($s -match 'f') { $force = $true }
            continue
        }
        $operands += $s
    }
    if ($operands.Count -lt 2) { Write-Error 'ln: usage: ln [-sf] target link'; return }
    $target = (Resolve-Path -LiteralPath $operands[0] -ErrorAction SilentlyContinue)
    if ($target) { $target = $target.Path } else { $target = $operands[0] }
    $link = $operands[1]
    if ($force -and (Test-Path -LiteralPath $link)) { Remove-Item -LiteralPath $link -Force -Recurse }

    if (-not $symbolic) {
        New-Item -ItemType HardLink -Path $link -Target $target | Out-Null
        return
    }

    # symlinks need Developer Mode or elevation; junctions (directories) and
    # hard links (files) are the unprivileged fallback
    try {
        New-Item -ItemType SymbolicLink -Path $link -Target $target -ErrorAction Stop | Out-Null
    } catch {
        $isDir = (Test-Path -LiteralPath $target) -and (Get-Item -LiteralPath $target).PSIsContainer
        $fallback = 'HardLink'
        if ($isDir) { $fallback = 'Junction' }
        Write-Host "ln: symlink needs Developer Mode or admin, falling back to $fallback" -ForegroundColor Yellow
        New-Item -ItemType $fallback -Path $link -Target $target | Out-Null
    }
}

# open a file/URL with its default application (`open` on macOS, `xdg-open` on Linux)
function open {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Path)
    if (-not $Path -or $Path.Count -eq 0) { $Path = @('.') }
    foreach ($p in $Path) { Start-Process $p }
}
Set-DotAlias -Name 'xdg-open' -Value 'open'

# oh-my-zsh clipboard.zsh equivalents
function clipcopy {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Path)
    if ($Path -and $Path.Count -gt 0) { Get-Content -LiteralPath $Path -Raw | Set-Clipboard }
    else { $input | Set-Clipboard }
}
function clippaste { Get-Clipboard }
Set-DotAlias -Name 'pbcopy' -Value 'clipcopy'
Set-DotAlias -Name 'pbpaste' -Value 'clippaste'

# `export FOO=bar` / `export FOO bar`
function export {
    foreach ($a in $args) {
        $s = [string]$a
        if ($s -match '^([^=]+)=(.*)$') {
            Set-Item -LiteralPath "Env:$($Matches[1])" -Value $Matches[2]
        }
    }
}
function unset {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Name)
    foreach ($n in $Name) { Remove-Item -LiteralPath "Env:$n" -ErrorAction SilentlyContinue }
}
function printenv {
    param([string]$Name)
    if ($Name) { (Get-Item -LiteralPath "Env:$Name" -ErrorAction SilentlyContinue).Value }
    else { Get-ChildItem Env: | ForEach-Object { "$($_.Name)=$($_.Value)" } }
}

# gsudo gives Windows a usable `sudo`; without it, say so instead of failing oddly
if (Test-Command 'gsudo') {
    Remove-BuiltinAlias 'sudo'
    Set-DotAlias -Name 'sudo' -Value 'gsudo'
} elseif (-not (Test-Command 'sudo')) {
    function sudo {
        Write-Host 'sudo is not available. install gsudo (`winget install gerardog.gsudo`) or start an elevated shell.' -ForegroundColor Yellow
    }
}
