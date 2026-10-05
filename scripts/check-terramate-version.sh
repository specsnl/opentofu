#!/usr/bin/env bash

set -euo pipefail

scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current="$(sed -n 's/^ARG TERRAMATE_VERSION=//p' "${scripts_dir}/../Dockerfile")"

exec "${scripts_dir}/check-github-release.sh" terramate-io/terramate "${current}"
