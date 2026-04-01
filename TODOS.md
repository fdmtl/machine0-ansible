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

**Depends on:** nix base deployment being stable and proven in production.

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
