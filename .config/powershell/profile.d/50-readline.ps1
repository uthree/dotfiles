# PSReadLine tuned to behave like the zsh setup in ~/.zshrc.d/zinit.zsh :
# emacs keys, substring history search, autosuggestions and a completion menu.

if (-not (Get-Module -Name PSReadLine)) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
}

if (Get-Module -Name PSReadLine) {
    $psrlVersion = (Get-Module -Name PSReadLine).Version

    Set-PSReadLineOption -EditMode Emacs
    Set-PSReadLineOption -BellStyle None
    Set-PSReadLineOption -HistoryNoDuplicates          # OMZL::history.zsh
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    Set-PSReadLineOption -MaximumHistoryCount 10000
    Set-PSReadLineOption -HistorySaveStyle SaveIncrementally

    # zsh-autosuggestions (PSReadLine 2.1+)
    if ($psrlVersion -ge [version]'2.1.0') {
        try { Set-PSReadLineOption -PredictionSource History } catch {}
    }
    if ($psrlVersion -ge [version]'2.2.0') {
        try { Set-PSReadLineOption -PredictionViewStyle InlineView } catch {}
    }

    # zsh-history-substring-search
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

    # history-search-multi-word is bound to ^R in zsh; ^R here is the closest thing
    # (PSFzf takes this over in 80-fzf.ps1 when fzf is installed)
    Set-PSReadLineKeyHandler -Key 'Ctrl+r' -Function ReverseSearchHistory

    # fzf-tab / zsh completion menu
    Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
    Set-PSReadLineKeyHandler -Key 'Shift+Tab' -Function TabCompletePrevious

    # zsh-style word movement and editing
    Set-PSReadLineKeyHandler -Key 'Ctrl+LeftArrow' -Function BackwardWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+RightArrow' -Function ForwardWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+w' -Function BackwardKillWord
    Set-PSReadLineKeyHandler -Key 'Alt+d' -Function KillWord
    Set-PSReadLineKeyHandler -Key 'Ctrl+u' -Function BackwardDeleteLine
    Set-PSReadLineKeyHandler -Key 'Ctrl+k' -Function ForwardDeleteLine
    Set-PSReadLineKeyHandler -Key 'Ctrl+l' -Function ClearScreen

    # fast-syntax-highlighting equivalent (PSReadLine colours the input itself)
    try {
        Set-PSReadLineOption -Colors @{
            Command   = 'Green'
            Parameter = 'DarkGray'
            String    = 'Yellow'
            Operator  = 'Magenta'
            Variable  = 'Cyan'
            Number    = 'Blue'
            Comment   = 'DarkGreen'
            Error     = 'Red'
        }
    } catch {}
}

# Bash-style completion for arguments, closest thing to zsh's completion menu
Set-PSReadLineOption -CompletionQueryItems 100 -ErrorAction SilentlyContinue
