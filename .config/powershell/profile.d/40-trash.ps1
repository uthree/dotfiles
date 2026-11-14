# `rm` sends its arguments to the Windows recycle bin, so Explorer can restore
# them. Use `Remove-Item` (or `command rm`) when you really mean delete.
#
# zsh keeps its own ~/.Trash (see ~/.zshrc.d/trash.zsh) because macOS and Linux
# have no shared trash to hand a path to. Windows has one, with its own
# retention, so there is nothing for this file to mirror.

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

# 10-os.ps1 sets this; re-derive it in case this file is loaded on its own.
if ($null -eq $DotfilesOnWindows) {
    $DotfilesOnWindows = ($PSVersionTable.PSVersion.Major -lt 6) -or $IsWindows
}
# install.sh does not install this profile, so this only guards a hand-made
# setup. Without a recycle bin, `rm` stays PowerShell's own Remove-Item alias.
if (-not $DotfilesOnWindows) { return }

# Microsoft.VisualBasic.FileIO is the shortest way to the recycle bin, and ships
# with both Windows PowerShell 5.1 and PowerShell 7 on Windows.
try {
    Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction Stop
} catch {
    Write-Host 'Microsoft.VisualBasic is unavailable; rm stays Remove-Item.' -ForegroundColor Yellow
    return
}

function Move-ItemToTrash {
    $targets = @()
    foreach ($a in $args) {
        $s = [string]$a
        # -r / -f / -rf are meaningless here, but they arrive out of habit
        if ($s -like '-*') { continue }
        $targets += $s
    }
    if ($targets.Count -eq 0) { Write-Error 'rm: missing operand'; return }

    foreach ($t in $targets) {
        $items = @(Get-Item -Path $t -Force -ErrorAction SilentlyContinue)
        if ($items.Count -eq 0) {
            Write-Error "rm: $t : No such file or directory"
            continue
        }
        foreach ($item in $items) {
            $path = $item.FullName
            try {
                if ($item.PSIsContainer) {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory(
                        $path, 'OnlyErrorDialogs', 'SendToRecycleBin')
                } else {
                    [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile(
                        $path, 'OnlyErrorDialogs', 'SendToRecycleBin')
                }
            } catch {
                # A network share, a drive with the recycle bin switched off, or
                # a path the shell API will not take. Deleting it anyway cannot
                # be undone, so report it and leave the path alone.
                Write-Error "rm: $path : cannot go to the recycle bin ($($_.Exception.Message)). use Remove-Item to delete it"
            }
        }
    }
}
Set-DotAlias -Name rm -Value 'Move-ItemToTrash'
Set-DotAlias -Name del -Value 'Move-ItemToTrash'
Set-DotAlias -Name erase -Value 'Move-ItemToTrash'

# Windows ages the recycle bin itself (Storage Sense), so there is no 30-day
# sweep to mirror.
function clear-trash-all {
    Clear-RecycleBin -Force
}
