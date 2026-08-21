# Aliases, mirroring ~/.zshrc.d/alias.zsh .

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

# vim/helix muscle memory
function Invoke-ExitShell { exit }
Set-DotAlias -Name ':q' -Value 'Invoke-ExitShell'

function Invoke-EditorVim {
    if (Test-Command 'vim') { & vim @args } else { & $env:EDITOR @args }
}
function Invoke-EditorHelix {
    if (Test-Command 'hx') { & hx @args } else { & $env:EDITOR @args }
}
Set-DotAlias -Name ':e' -Value 'Invoke-EditorVim'
Set-DotAlias -Name ':o' -Value 'Invoke-EditorHelix'

# zsh's `exec zsh`; PowerShell cannot exec, so nest a fresh shell and leave
function reload {
    $shell = (Get-Process -Id $PID).Path
    if (-not $shell) { $shell = 'powershell.exe' }
    & $shell -NoLogo
    exit
}

# zsh's `command`: run the real cmdlet/executable, ignoring our functions and
# aliases (`command rm foo` really deletes, `rm foo` goes to the trash)
function command {
    if ($args.Count -eq 0) { Write-Error 'command: no command given'; return }
    $name = [string]$args[0]
    $rest = @()
    if ($args.Count -gt 1) { $rest = $args[1..($args.Count - 1)] }
    $cmd = Get-Command -Name $name -CommandType Application, Cmdlet -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if (-not $cmd) { Write-Error "command: $name not found"; return }
    & $cmd @rest
}
Set-DotAlias -Name '$' -Value 'command'

# eza
if (Test-Command 'eza') {
    function Invoke-Eza { & eza --icons --classify @args }
    function Invoke-EzaLong { & eza --icons --classify --long --git @args }
    function Invoke-EzaAll { & eza --icons --classify --long --git --all @args }
    function Invoke-EzaTree { & eza --icons --tree --level=2 @args }
    Set-DotAlias -Name ls -Value 'Invoke-Eza'
    Set-DotAlias -Name ll -Value 'Invoke-EzaLong'
    Set-DotAlias -Name la -Value 'Invoke-EzaAll'
    Set-DotAlias -Name tree -Value 'Invoke-EzaTree'
} else {
    # ls stays Get-ChildItem, but add the shapes a zsh user reaches for
    function Invoke-ListLong { Get-ChildItem -Force @args }
    Set-DotAlias -Name ll -Value 'Invoke-ListLong'
    Set-DotAlias -Name la -Value 'Invoke-ListLong'
}

# fcp
if (Test-Command 'fcp') {
    Set-DotAlias -Name cp -Value 'fcp'
}

# `screen -d -m` equivalent: detach a command from this shell
function background {
    if ($args.Count -eq 0) { Write-Error 'background: no command given'; return }
    $name = [string]$args[0]
    $rest = @()
    if ($args.Count -gt 1) { $rest = $args[1..($args.Count - 1)] }
    $cmd = Get-Command -Name $name -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($cmd -and $cmd.CommandType -eq 'Application') {
        if ($rest.Count -gt 0) {
            Start-Process -FilePath $cmd.Path -ArgumentList $rest -WindowStyle Hidden
        } else {
            Start-Process -FilePath $cmd.Path -WindowStyle Hidden
        }
    } else {
        Start-Job -ScriptBlock { param($n, $a) & $n @a } -ArgumentList $name, $rest
    }
}

# a few oh-my-zsh git aliases (OMZP::git on the zsh side).
# gc / gl / gp / gm / gcm are core PowerShell aliases, so they are left alone.
if (Test-Command 'git') {
    function gst { & git status @args }
    function gd { & git diff @args }
    function ga { & git add @args }
    function gaa { & git add --all @args }
    function gcmsg { & git commit -m @args }
    function gco { & git checkout @args }
    function gb { & git branch @args }
    function glog { & git log --oneline --graph --decorate @args }
}

# zellij has no Windows build; Windows Terminal panes cover the same ground.
