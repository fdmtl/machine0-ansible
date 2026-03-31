# TODOs

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
