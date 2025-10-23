Invoke-Expression (&starship init powershell)

if (Get-Command "eza.exe" -ErrorAction SilentlyContinue) {
    function _ls { eza.exe --icons -F $args }
    Set-Alias -name ls -Value _ls
}