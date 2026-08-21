# `rm` moves to ~/.Trash instead of deleting, mirroring ~/.zshrc.d/trash.zsh .
# Use `Remove-Item` (or `command rm`) when you really mean delete.

# interactive shells only, the zsh equivalent of `[[ -o interactive ]] || return`.
# see Test-DotfilesInteractiveSession in ../profile.ps1
if ($global:DotfilesInteractive -eq $false) { return }

$TRASH_DIR = Join-Path $HOME '.Trash'
if (-not (Test-Path -LiteralPath $TRASH_DIR)) {
    New-Item -ItemType Directory -Path $TRASH_DIR -Force | Out-Null
    Write-Host "Created $TRASH_DIR directory automatically." -ForegroundColor Magenta
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
            $dest = Join-Path $TRASH_DIR $item.Name
            # same idea as `mv --backup=numbered`
            if (Test-Path -LiteralPath $dest) {
                $i = 1
                while (Test-Path -LiteralPath "$dest.~$i~") { $i++ }
                $dest = "$dest.~$i~"
            }
            Move-Item -LiteralPath $item.FullName -Destination $dest -Force
        }
    }
}
Set-DotAlias -Name rm -Value 'Move-ItemToTrash'
Set-DotAlias -Name del -Value 'Move-ItemToTrash'
Set-DotAlias -Name erase -Value 'Move-ItemToTrash'

function clear-trash {
    if (-not (Test-Path -LiteralPath $TRASH_DIR)) { return }
    $limit = (Get-Date).AddDays(-30)
    Get-ChildItem -LiteralPath $TRASH_DIR -Force |
        Where-Object { $_.LastWriteTime -lt $limit } |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
}

function clear-trash-all {
    if (-not (Test-Path -LiteralPath $TRASH_DIR)) { return }
    Get-ChildItem -LiteralPath $TRASH_DIR -Force |
        ForEach-Object { Remove-Item -LiteralPath $_.FullName -Recurse -Force }
}
