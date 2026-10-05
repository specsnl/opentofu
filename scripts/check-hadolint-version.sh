#!/usr/bin/env bash

set -euo pipefail

scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current="$(sed -n 's/^ *HADOLINT_TAG_VERSION: *//p' "${scripts_dir}/../Taskfile.dist.yml")"

exec "${scripts_dir}/check-github-release.sh" hadolint/hadolint "${current}"
