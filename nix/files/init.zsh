#
# Zsh Configuration (nix-managed)
# Portable across macOS and Linux
#

#
# Platform Detection
#
IS_MACOS=false
IS_LINUX=false
[[ "$OSTYPE" == "darwin"* ]] && IS_MACOS=true
[[ "$OSTYPE" == "linux"* ]] && IS_LINUX=true


#
# Homebrew (macOS only, or Linux if installed)
#
if [[ "$IS_MACOS" == true ]]; then
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
elif [[ -f /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

#
# History
#
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

#
# Completions
#
autoload -Uz compinit && compinit

#
# Terminal
#
export TERM=xterm-256color

# Keybindings for word navigation (Ctrl+Left/Right)
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# History search with Up/Down (matches prefix of current input)
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

#
# Aliases - General
#
alias json='python3 -m json.tool'
alias cd='z'
alias l='eza -l --icons'
alias ll='ls -lGh'
alias reload='source ~/.zshrc'
alias myip='curl http://jsonip.com/ | cut -d\" -f4'
alias key='cat ~/.ssh/id_rsa.pub'
alias webserver='python3 -m http.server'
alias docker-ps='docker ps -a --format "table {{.ID}}\t{{.Status}}\t{{.Names}}"'
alias gen-passwd='openssl rand -base64 12 | tr -d "/+=" | head -c 16 && echo'

#
# git
#
alias gpl='git pull'
alias gpu='git push'
alias gs='git status'
alias ga='git add'
alias gb='git switch -c'
alias gco='git checkout'
alias gm='git checkout main'


#
# MCP
#
alias mcp-inspector='npx @modelcontextprotocol/inspector'


#
# Aliases - Linux specific
#
if [[ "$IS_LINUX" == true ]]; then
  alias i='ip addr show'
  alias wifi='impala'
  alias bluetooth='bluetui'
  alias h='hyprland'
  alias xremap-restart='systemctl --user restart xremap'

  # Snapshots (timeshift)
  alias snapshot-restore='sudo timeshift --restore --scripted --yes && sudo reboot'
  alias snapshot-list='sudo timeshift --list'
  alias snapshot-delete='sudo timeshift --delete'
fi

#
# Utilities - General
#
killport() { lsof -ti tcp:$1 | xargs kill; }
listport() { lsof -i :$1; }

alias decompress="tar -xzf"
compress() { tar -czf "${1%/}.tar.gz" "${1%/}"; }

gc() { git commit -a -m "$1"; }

spc() {
  for i in {1..30}; do
    echo
  done
}

#
# Functions - Linux specific
#
if [[ "$IS_LINUX" == true ]]; then
  snapshot-create() { sudo timeshift --create --comments "${1%/}"; }

  luks-list() {
    lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT | grep -E '(NAME|crypt|crypto_LUKS)'
  }

  passwd-luks() {
    local device="${1:-/dev/sda3}"
    if [[ ! -b "$device" ]]; then
      echo "Error: $device is not a block device"
      echo "Use 'luks-list' to find LUKS devices"
      return 1
    fi
    echo "Changing LUKS password for $device"
    echo "You will be prompted for the current password, then the new password twice."
    sudo cryptsetup luksChangeKey "$device"
  }

  printer-discover() {
    echo "Discovering printers via Bonjour..."
    avahi-browse -t _ipp._tcp --resolve 2>/dev/null | \
      awk '/^=.*IPv4/ { name=""; for(i=4;i<=NF;i++) { if($i=="local") break; name=name" "$i }; gsub(/^ /, "", name) }
           /address = \[/ { gsub(/.*\[|\].*/, ""); addr=$0 }
           /txt =.*rp=/ { match($0, /rp=([^"]+)/, m); rp=m[1]; if(addr && rp) print name " -> ipp://" addr "/" rp }'
  }

  printer-add() {
    if [[ -z "$1" || -z "$2" ]]; then
      echo "Usage: printer-add <name> <ipp-uri>"
      echo "Example: printer-add HP_ENVY ipp://192.168.68.60/ipp/print"
      echo ""
      echo "Use 'printer-discover' to find available printers"
      return 1
    fi
    sudo lpadmin -p "$1" -E -v "$2" -m everywhere && \
      echo "Printer '$1' added. Set as default with: lpoptions -d $1"
  }

  last-screenshot() {
    local screenshot_dir=~/Screenshots
    local latest=$(ls -t "$screenshot_dir"/*.png 2>/dev/null | head -1)
    if [[ -z "$latest" ]]; then
      echo "No screenshots found in $screenshot_dir"
      return 1
    fi
    chafa "$latest"
    local full_path=$(realpath "$latest")
    echo "$full_path" | wl-copy
    echo "\nPath copied: $full_path"
  }
fi

#
# Tools
#
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Eza completion (use ls completion for eza and aliases)
compdef eza=ls 2>/dev/null
compdef l=ls 2>/dev/null

#
# Prompt (Starship)
#
export STARSHIP_CONFIG=~/.config/starship/starship.toml
command -v starship &>/dev/null && eval "$(starship init zsh)"
