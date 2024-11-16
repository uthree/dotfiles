if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  local DISTRIB=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ ${DISTRIB} = "Ubuntu"* ]]; then
    if uname -a | grep -q 'WSL'; then
      # ubuntu via WSL Windows Subsystem for Linux
      echo "\e[35;1mDetected WSL...\e[0m"
      # CUDA
      export LD_LIBRARY_PATH=/usr/lib/wsl/lib:$LD_LIBRARY_PATH
    else
      # native ubuntu
    fi
  elif [[ ${DISTRIB} = "Debian"* ]]; then
    # debian
  fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS OSX
fi