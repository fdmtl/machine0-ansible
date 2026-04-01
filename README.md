<h1 align="center">machine0-ansible</h1>
<p align="center">Ansible playbook used to provision the default machine0 VM image</p>

## Overview

This playbook installs dev tools, runtimes, Docker, AI coding agents and a modern shell environment on a fresh Ubuntu 24.04 machine. It is used to build the `base-24-04` image that ships with [machine0](https://machine0.io).

## Playbooks

| Playbook | Description |
|---|---|
| `base.yml` | Base image — dev tools, runtimes, Docker, shell, Claude Code |
| `openclaw.yml` | Base + [OpenClaw](https://github.com/openclawai/OpenClaw) agent framework |
| `claws.yml` | Base + all 5 claw agent frameworks (OpenClaw, NemoClaw, NanoClaw, MetaClaw, ZeroClaw) |
| `webserver.yml` | Base + web server setup |
| `nix.yml` | Nix provisioning — zsh, nix daemon, home-manager flake, Claude Code, Docker, SSH hardening, MOTD |

## Recommended VM Sizes

| Playbook | Minimum Size | Why |
|---|---|---|
| `base.yml` | `small` (1 GB) | Lightweight dev tools and runtimes |
| `openclaw.yml` | `small` (1 GB) | Single npm package |
| `claws.yml` | `xl` (8 GB) | NemoClaw's dependency tree needs the RAM |
| `webserver.yml` | `small` (1 GB) | Lightweight web server |
| `nix.yml` | `medium` (2 GB) | Nix builds may compile from source |

## Building Images

Build a ready-to-use image from any playbook in one command:

```bash
$ ./make-image.sh base.yml small              # → image: base-260325-1430
$ ./make-image.sh claws.yml xl v2             # → image: claws-v2
```

This creates a temporary VM, provisions it, snapshots it to an image, and cleans up the VM automatically. If anything fails, the VM is removed by a cleanup trap.

## Provisioning

To provision an existing VM (without imaging):

```bash
$ machine0 new my-vm --size xl
$ machine0 provision my-vm claws.yml
```

Or directly with Ansible:

```bash
$ ansible-playbook -i "<IP>," -u ubuntu base.yml
```

## Nix-Based Provisioning

An alternative to the Ansible-only `base.yml`, using [Nix](https://nixos.org/) flakes and [home-manager](https://github.com/nix-community/home-manager) for reproducible package management:

```bash
$ machine0 new my-vm --size medium
$ machine0 provision my-vm nix.yml
```

This installs nix, copies the home-manager flake, builds all dev tools and shell config, installs Claude Code, and sets up system services (Docker, SSH, MOTD). Builds happen on the target VM.

## What's Installed

> The table below describes `base.yml`. The nix path (`nix.yml`) installs an equivalent set of packages via [nixpkgs](https://search.nixos.org/packages) instead of mise/apt. Minor differences: `fastfetch` is still installed by the `03-motd` Ansible role; `chafa`, `powerline`, and `inetutils` are added by the nix flake.

| Category | Packages |
|---|---|
| **Runtimes** | Node (LTS), Bun, Python, Rust, Go — managed by [mise](https://mise.jdx.dev) |
| **Python Tools** | uv, pipx |
| **Docker** | docker-ce, docker-compose, docker-buildx |
| **AI Agents** | [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and optionally: [OpenClaw](https://github.com/openclawai/OpenClaw), [NemoClaw](https://github.com/NVIDIA/NemoClaw), [NanoClaw](https://github.com/qwibitai/nanoclaw), [MetaClaw](https://github.com/aiming-lab/MetaClaw), [ZeroClaw](https://crates.io/crates/zeroclaw) |
| **Build Tools** | build-essential, cmake, pkg-config |
| **CLI Essentials** | git, vim, curl, wget, jq, htop, btop, fzf, ripgrep, unzip, p7zip |
| **Shell** | Zsh with [Starship](https://starship.rs) prompt, eza, zoxide, autosuggestions, syntax highlighting |
| **Other** | screen, fastfetch |
