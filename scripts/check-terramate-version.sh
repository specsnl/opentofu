#!/usr/bin/env bash
#
# Checks whether a newer Terramate release exists than the version pinned in the Dockerfile.
# See check-github-release.sh for the exit codes.
set -euo pipefail

scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current="$(sed -n 's/^ARG TERRAMATE_VERSION=//p' "${scripts_dir}/../Dockerfile")"

exec "${scripts_dir}/check-github-release.sh" terramate-io/terramate "${current}"
