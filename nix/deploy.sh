#!/usr/bin/env bash
set -euo pipefail

VM="${1:?Usage: deploy.sh <vm-name-or-ip>}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SSH_USER="${SSH_USER:-ubuntu}"
REMOTE_DIR="/home/$SSH_USER/.machine0-nix"

# Resolve VM name to IP via machine0 CLI
if command -v machine0 &>/dev/null && ! [[ "$VM" =~ ^[0-9] ]]; then
  IP=$(machine0 get "$VM" 2>&1 | grep "│ IP" | awk '{print $3}')
  if [[ -z "$IP" || "$IP" == "--" ]]; then
    echo "Error: Could not resolve IP for VM '$VM'"
    exit 1
  fi
else
  IP="$VM"
fi

# Detect machine0 SSH key (prefer system key, then any machine0 key)
SSH_KEY="${SSH_KEY:-}"
if [[ -z "$SSH_KEY" ]]; then
  for key in ~/.ssh/machine0__system*; do
    [[ "$key" == *.pub ]] && continue
    [[ -f "$key" ]] && SSH_KEY="$key" && break
  done
fi
if [[ -z "$SSH_KEY" ]]; then
  for key in ~/.ssh/machine0__*; do
    [[ "$key" == *.pub ]] && continue
    [[ -f "$key" ]] && SSH_KEY="$key" && break
  done
fi

# Build SSH args as an array to avoid quoting issues
SSH_ARGS=(-o StrictHostKeyChecking=no)
[[ -n "$SSH_KEY" ]] && SSH_ARGS+=(-i "$SSH_KEY")

# Helper to run a command on the remote with nix on PATH
remote() {
  ssh "${SSH_ARGS[@]}" "$SSH_USER@$IP" \
    "source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh 2>/dev/null; $1"
}

echo "==> Deploying to $IP (user: $SSH_USER)"

echo "==> Step 1: Bootstrap (install nix, Docker, SSH hardening, MOTD)"
ANSIBLE_HOST_KEY_CHECKING=false ansible-playbook -i "$IP," -u "$SSH_USER" \
  ${SSH_KEY:+--private-key "$SSH_KEY"} \
  "$SCRIPT_DIR/../nix.yml"

echo "==> Step 2: Copy flake to remote"
rsync -avz \
  -e "ssh $(printf '%q ' "${SSH_ARGS[@]}")" \
  "$SCRIPT_DIR/" "$SSH_USER@$IP:$REMOTE_DIR/"

echo "==> Step 3: Build and activate home-manager on remote"
remote "cd ~/.machine0-nix && nix run home-manager/release-24.11 -- switch --flake .#ubuntu -b backup"

echo "==> Step 4: Install Claude Code"
remote "mkdir -p ~/.npm-global && npm install -g --prefix ~/.npm-global @anthropic-ai/claude-code@2.1.81"

echo "==> Step 5: Verify"
remote '
FAIL=0

echo "--- Nix ---"
nix --version || FAIL=1

echo "--- Packages ---"
for cmd in gcc cmake git node bun python3 uv pipx rustc cargo go; do
  path=$(command -v $cmd 2>/dev/null || echo "MISSING")
  printf "%-12s %s\n" "$cmd" "$path"
  [[ "$path" == "MISSING" ]] && FAIL=1
done

echo "--- System services ---"
path=$(command -v docker 2>/dev/null || echo "MISSING")
printf "%-12s %s\n" "docker" "$path"
[[ "$path" == "MISSING" ]] && FAIL=1

echo "--- Shell ---"
echo "Login shell: $(getent passwd $(whoami) | cut -d: -f7)"
starship --version 2>&1 | head -1
eza --version 2>&1 | head -1

echo "--- SSH hardening ---"
sudo sshd -T 2>/dev/null | grep -i passwordauthentication || echo "MISSING"

echo "--- Claude Code ---"
PATH="$HOME/.npm-global/bin:$PATH" claude --version 2>/dev/null || { echo "MISSING"; FAIL=1; }

echo "--- MOTD ---"
[ -f /etc/update-motd.d/00-machine0-header ] && echo "MOTD script present" || { echo "MISSING"; FAIL=1; }

[[ $FAIL -eq 1 ]] && echo "WARNING: Some checks failed" || echo "All checks passed"
exit 0
'

echo "==> Done. VM $VM provisioned."
