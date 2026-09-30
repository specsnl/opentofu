# Docker OpenTofu

[![Build Images](https://github.com/specsnl/opentofu/actions/workflows/main.yml/badge.svg)](https://github.com/specsnl/opentofu/actions/workflows/main.yml)

A OpenTofu and Terramate image.

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

This project uses [Task](https://taskfile.dev) (an task runner / build tool).

Available tasks for this project:

```sh
* build:       Build the OpenTofu image
* lint:        Apply a Dockerfile linter (https://github.com/hadolint/hadolint)
* shell:       Interactive shell
```
