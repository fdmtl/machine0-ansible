#!/usr/bin/env bash
set -euo pipefail

# --- Usage -----------------------------------------------------------
usage() { echo "Usage: $0 <playbook> <size> [suffix]"; exit 1; }
[[ $# -lt 2 ]] && usage

playbook="$1"
size="$2"
suffix="${3:-$(date +%y%m%d-%H%M)}"

# --- Validate ---------------------------------------------------------
[[ ! -f "$playbook" ]] && echo "Error: playbook '$playbook' not found" && exit 1

# --- Derive names -----------------------------------------------------
name=$(basename -- "${playbook%.yml}")
name="${name%.yaml}"
image="${name}-${suffix}"
vm="$image"                    # VM and image share the same name

# --- Cleanup trap -----------------------------------------------------
vm_created=false
cleanup() {
  if [[ "$vm_created" == "true" ]]; then
    echo "Cleaning up VM '$vm'..."
    machine0 stop "$vm" 2>/dev/null || true
    machine0 rm "$vm" -y 2>/dev/null || true
  fi
}
trap cleanup EXIT

# --- Pipeline ---------------------------------------------------------
echo "==> Creating VM '$vm' (size: $size)..."
machine0 new "$vm" --size "$size"
vm_created=true

echo "==> Provisioning '$playbook'..."
machine0 provision "$vm" "$playbook"

echo "==> Stopping VM..."
machine0 stop "$vm"

echo "==> Creating image '$image'..."
machine0 images new "$vm" "$image"

echo "==> Removing VM..."
machine0 rm "$vm" -y
vm_created=false               # Prevent trap from double-removing

echo "==> Done! Image '$image' is ready."
