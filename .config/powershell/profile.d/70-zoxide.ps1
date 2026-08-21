# zoxide as a `cd` replacement, mirroring ~/.zprofile .

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

if (Test-Command 'zoxide') {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}
