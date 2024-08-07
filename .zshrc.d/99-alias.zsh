alias ":q"=exit
alias ":e"=vim
alias ":o"=hx
alias reload="exec zsh"
alias ll=la
alias nf="neofetch"
alias cls=clear
alias clsls="clear && ls"
alias cb="xsel --clipboard --input"
type docker-compose > /dev/null && alias dc=docker-compose || alias dc="docker compose"
alias downrm="docker-compose down --rmi all --volumes --remove-orphans"
alias less="less -r"
alias tree="tree -C"
alias tl="tree | less"
alias tal="tree -a |less"
alias gdc="git diff --compact-summary --diff-filter=d"
alias grep="grep --color=auto"

for i in {1..99}; do
  alias "awk$i=awk '{print \$$i}'"
done

sudo=sudo
if type doas > /dev/null; then
  sudo=doas
fi

if [[ -r /etc/arch-release ]]; then
  aur_helpers=(aurman aurutils pakku pikaur trizen yay paru bauerbill pkgbuilder aura repofish wrapaur aurget pacman)

  for helper in $aur_helpers; do    
    if type $helper > /dev/null; then
      aur=$helper
      break
    fi
  done
  if [[ $aur = pacman ]]; then
    if [[ ! -e ~/.aurignore ]] && read -q "REPLY?No AUR helper was found, do you want to install paru-bin from AUR? [y/N]: "; then
      echo
      echo '\n\e[30;1mCloning `\e[0mhttps://aur.archlinux.org/paru-bin.git\e[30;1m` into `\e[0m/tmp/paru\e[30;1m` ...\e[0m\n'
      git clone https://aur.archlinux.org/paru-bin.git /tmp/paru
      cd /tmp/paru
      echo '\n\e[30;1mRunning `\e[0mmakepkg -si --noconfirm\e[30;1m` ...\e[0m\n'
      makepkg -si --noconfirm
      cd ~
      echo '\n\e[30;1mRemoving `\e[0m/tmp/paru\e[30;1m` ...\e[0m'
      rm -rf /tmp/paru
      echo '\e[32;1mSuccess!\e[0m\n'
      aur=paru
    else
      touch ~/.aurignore
      aur="$sudo $aur"
    fi
  fi

  alias u="${aur} -Syyu"
  alias i="${aur} -S"
  alias p="${aur} -R"
  alias s="${aur}"
elif [[ -r /etc/os-release ]] && grep -q debian /etc/os-release; then
  alias u="$sudo apt update && $sudo apt upgrade -y"
  alias i="$sudo apt install -y"
  alias p="$sudo apt purge --autoremove -y"
  alias s="$sudo apt search"
elif [[ -r /etc/os-release ]] && grep -q fedora /etc/os-release; then
  alias u="$sudo dnf update -y"
  alias i="$sudo dnf install -y"
  alias p="$sudo dnf erase -y"
  alias s="$sudo dnf search"
fi

alias t="zellij"

alias background="screen -d -m"

# exa
if type "eza" > /dev/null 2>&1; then
	alias ls="eza --icons -F"
fi
