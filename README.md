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

## Provisioning

Using the machine0 CLI:

```bash
$ machine0 provision my-vm base.yml
```

Or directly with Ansible:

```bash
$ ansible-playbook -i "<IP>," -u ubuntu base.yml
```

## What's Installed

| Category | Packages |
|---|---|
| **Runtimes** | Node (LTS), Bun, Python, Rust, Go — managed by [mise](https://mise.jdx.dev) |
| **Python Tools** | uv, pipx |
| **Docker** | docker-ce, docker-compose, docker-buildx |
| **AI Agents** | [Claude Code](https://docs.anthropic.com/en/docs/claude-code), and optionally: [OpenClaw](https://github.com/openclawai/OpenClaw), [NemoClaw](https://github.com/NVIDIA/NemoClaw), [NanoClaw](https://github.com/qwibitai/nanoclaw), [MetaClaw](https://github.com/aiming-lab/MetaClaw), [ZeroClaw](https://crates.io/crates/zeroclaw) |
| **Build Tools** | build-essential, cmake, pkg-config |
| **CLI Essentials** | git, vim, curl, wget, jq, htop, btop, fzf, ripgrep, unzip, p7zip |
| **Shell** | Zsh with [Starship](https://starship.rs) prompt, eza, zoxide, autosuggestions, syntax highlighting |
| **Other** | Ansible, PostgreSQL client, screen, fastfetch |
