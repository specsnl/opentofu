#!/usr/bin/env bash

set -euo pipefail

scripts_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

current="$(sed -n 's/^ARG TOFU_AGE_VERSION=//p' "${scripts_dir}/../Dockerfile")"

exec "${scripts_dir}/check-github-release.sh" specsnl/tofu-age "${current}"
