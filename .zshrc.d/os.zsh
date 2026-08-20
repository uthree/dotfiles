if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ ${DISTRIB} = "Ubuntu"* ]]; then
    if uname -a | grep -q 'WSL'; then
      # ubuntu via WSL Windows Subsystem for Linux
      echo "\e[35;1mDetected WSL...\e[0m"
      # CUDA
      export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH
      # interop with the Windows side
      alias open='explorer.exe'
      if type clip.exe &> /dev/null; then
        alias pbcopy='clip.exe'
      fi
      if type powershell.exe &> /dev/null; then
        alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
      fi
    else
      # native ubuntu
    fi
  elif [[ ${DISTRIB} = "Debian"* ]]; then
    # debian
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS OSX
elif [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
  # zsh under MSYS2 / Cygwin / Git for Windows.
  # PowerShell is configured separately in .config/powershell/ .
  echo "\e[35;1mDetected Windows (${OSTYPE})...\e[0m"
  alias open='start'
  if type clip.exe &> /dev/null; then
    alias pbcopy='clip.exe'
  fi
  if type powershell.exe &> /dev/null; then
    alias pbpaste='powershell.exe -NoProfile -Command Get-Clipboard'
  fi
fi
