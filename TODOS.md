# TODOs

## Extend nix flake to other playbooks

Extend the nix flake approach to cover `openclaw.yml`, `claws.yml`, and `webserver.yml`
playbooks. Each would get a home-manager module that adds its specific packages on top
of the base `home.nix`.

**Context:** The current nix setup only reproduces the base role. The claws playbook
installs 5 agent frameworks (OpenClaw, NemoClaw, NanoClaw, MetaClaw, ZeroClaw) with
diverse install methods (npm, git+bun, pip, cargo). NemoClaw requires xl (8 GB) VMs.
The webserver/fileserver playbooks use the docker-app role which would need a nix
equivalent for container management.

**Depends on:** nix.yml provisioning being stable (consolidated in single command as of this PR).

## Evaluate system-manager to replace ansible root tasks

[system-manager](https://github.com/numtide/system-manager) (numtide, v1.1, Jan 2026) can
manage `/etc` files, systemd services, users/groups, and system packages on non-NixOS Linux
using Nix. This could replace all remaining ansible root tasks for the nix path:

- Docker daemon + CLI + compose + buildx via `environment.systemPackages` + `systemd.services`
- SSH hardening via `environment.etc."ssh/sshd_config.d/..."`
- MOTD via `environment.etc."update-motd.d/..."` + `environment.systemPackages = [ pkgs.fastfetch ]`
- Login shell + docker group via `users.users` / `users.groups` (powered by userborn)

**Result:** Eliminate ansible entirely for the nix path. One flake, one language (nix),
declarative rollback via generations.

**Trade-offs:** system-manager is v1.1 (young vs battle-tested ansible). Requires manually
defining Docker's systemd service (~40 lines) rather than `apt install docker-ce`. Kernel
settings (sysctl, modules-load) written to `/etc/` but need reboot to take effect. No
`virtualisation.docker.enable = true` convenience module yet.

**Depends on:** nix.yml provisioning being stable.

## Supply Chain: Pin remaining unpinned dependencies

### Pin MetaClaw to specific commit SHA
- **File:** `roles/04-claws/tasks/metaclaw.yml`
- **Current:** `pip install "metaclaw @ git+https://github.com/aiming-lab/MetaClaw.git"` (unpinned HEAD)
- **Fix:** `pip install "metaclaw @ git+https://github.com/aiming-lab/MetaClaw.git@COMMIT_SHA"`

### Pin NanoClaw to specific commit SHA
- **File:** `roles/04-claws/tasks/nanoclaw.yml`
- **Current:** `version: main` (unpinned)
- **Fix:** `version: COMMIT_SHA`

### Pin NemoClaw to specific commit SHA
- **File:** `roles/04-claws/tasks/nemoclaw.yml`
- **Current:** `version: main` (unpinned)
- **Fix:** `version: COMMIT_SHA`

### Pin nginx Docker image tag
- **File:** `webserver.yml`
- **Current:** `docker_app_image: nginx:alpine` (mutable tag)
- **Fix:** Pin to versioned tag or digest (e.g., `nginx:1.27-alpine` or `nginx@sha256:...`)
