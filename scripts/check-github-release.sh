#!/usr/bin/env bash
#
# Checks whether a GitHub repository has a newer release than the given version.
#
# Usage: check-github-release.sh <owner/repo> <current-version>
#
# Exit codes:
#   0 - the current version is the latest release
#   1 - a newer release is available
#   2 - the check itself failed
set -euo pipefail

if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <owner/repo> <current-version>" >&2
    exit 2
fi

repo="$1"
current="${2#v}"
name="${repo##*/}"

if [[ ! "${current}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid current ${name} version: '$2'" >&2
    exit 2
fi

# /releases/latest redirects to the tag of the latest (non-prerelease) release, which avoids the API rate limit.
if ! latest_url="$(curl -sSfL -o /dev/null -w '%{url_effective}' "https://github.com/${repo}/releases/latest")"; then
    echo "Failed to fetch the latest ${name} release" >&2
    exit 2
fi

latest="${latest_url##*/tag/}"
latest="${latest#v}"
if [[ ! "${latest}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Unexpected latest release URL: ${latest_url}" >&2
    exit 2
fi

if [[ "${current}" == "${latest}" ]] \
    || [[ "$(printf '%s\n%s\n' "${current}" "${latest}" | sort -V | tail -n1)" == "${current}" ]]; then
    echo "${name} is up to date (${current})"
    exit 0
fi

echo "A newer ${name} version is available: ${current} -> ${latest}"
echo "Release: ${latest_url}"
exit 1
