#!/usr/bin/env bash
#
# Checks whether a newer Terramate release exists than the version pinned in the Dockerfile.
#
# Exit codes:
#   0 - the pinned version is the latest release
#   1 - a newer release is available
#   2 - the check itself failed
set -euo pipefail

repo="terramate-io/terramate"
dockerfile="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/Dockerfile"

current="$(sed -n 's/^ARG TERRAMATE_VERSION=//p' "${dockerfile}")"
if [[ -z "${current}" ]]; then
    echo "Could not find TERRAMATE_VERSION in ${dockerfile}" >&2
    exit 2
fi

# /releases/latest redirects to the tag of the latest (non-prerelease) release, which avoids the API rate limit.
if ! latest_url="$(curl -sSfL -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest")"; then
    echo "Failed to fetch the latest Terramate release" >&2
    exit 2
fi

latest="${latest_url##*/tag/v}"
if [[ ! "${latest}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Unexpected latest release URL: ${latest_url}" >&2
    exit 2
fi

if [[ "${current}" == "${latest}" ]] \
    || [[ "$(printf '%s\n%s\n' "${current}" "${latest}" | sort -V | tail -n1)" == "${current}" ]]; then
    echo "Terramate is up to date (${current})"
    exit 0
fi

echo "A newer Terramate version is available: ${current} -> ${latest}"
echo "Release: https://github.com/${repo}/releases/tag/v${latest}"
exit 1
