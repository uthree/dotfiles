# Per-environment branches, mirroring ~/.zshrc.d/os.zsh .

# $IsWindows only exists on PowerShell 6+; on Windows PowerShell 5.1 the host is
# always Windows.
$DotfilesOnWindows = ($PSVersionTable.PSVersion.Major -lt 6) -or $IsWindows
$DotfilesPSCore = ($PSVersionTable.PSVersion.Major -ge 6)

if ($DotfilesOnWindows) {
    # Windows (Windows PowerShell 5.1 / PowerShell 7)

    # WSL is the escape hatch for anything that only exists on Linux.
    if (Test-Command 'wsl') {
        # run a single command in the default distro: `wsl-run uname -a`
        function wsl-run {
            param([Parameter(ValueFromRemainingArguments = $true)][string[]]$Arguments)
            & wsl.exe -e @Arguments
        }
    }
} elseif ($IsMacOS) {
    # macOS
} elseif ($IsLinux) {
    # Linux (PowerShell as a login shell is unusual here, but keep the branch)
}
