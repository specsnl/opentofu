# Docker OpenTofu

[![Build Images](https://github.com/specsnl/opentofu/actions/workflows/main.yml/badge.svg)](https://github.com/specsnl/opentofu/actions/workflows/main.yml)

An OpenTofu image with Terramate and [tofu-age](https://github.com/specsnl/tofu-age).

The image ships the `tofu-age` binary only, never an age identity: inject `TOFU_AGE_IDENTITY` at runtime to
decrypt state and plan files:

```bash
docker run -it -v $(pwd):/workspace -e TOFU_AGE_IDENTITY --rm ghcr.io/specsnl/opentofu:latest
```

Pulling image from GitHub Container Registry:

```bash
docker pull ghcr.io/specsnl/opentofu:latest
```

Interactive shell and mounting the current directory:

```bash
docker run -it -v $(pwd):/workspace --rm ghcr.io/specsnl/opentofu:latest
```

Default workspace: `/workspace`

## Task

This project uses [Task](https://taskfile.dev) (a task runner / build tool).

Available tasks for this project:

```sh
* build:               Build the OpenTofu image
* check-updates:       Check for newer versions of the pinned tools
* lint:                Apply a Dockerfile linter (https://github.com/hadolint/hadolint)
* shell:               Interactive shell
```
