# zoxide as a `cd` replacement, mirroring ~/.zprofile .

if (Test-Command 'zoxide') {
    Invoke-Expression (& { (zoxide init powershell --cmd cd | Out-String) })
}
