# syntax=docker/dockerfile:1
# check=error=true

# Latest version of opentofu image: https://github.com/opentofu/opentofu/releases
FROM ghcr.io/opentofu/opentofu:1.13.9-minimal AS opentofu

# Latest version of Alpine image: https://hub.docker.com/_/alpine/tags
FROM alpine:3.24.4 AS terramate

# Latest version of terramate: https://github.com/terramate-io/terramate/releases
ARG TERRAMATE_VERSION=0.17.4
# Checksums can be found in the checksums.txt file attached to the release
ARG TERRAMATE_CHECKSUM_AMD64=4bd2bcaebf2e6366fa68cb8f89108ed6d2d67ce2b6ff944236cc94e67e12f2a2
ARG TERRAMATE_CHECKSUM_ARM64=a63930f2691dc3ef970fe97bc5f79ddfcb62daa38c68ca4f6bb994364a30e046
ARG TARGETARCH

WORKDIR /tmp/terramate

RUN case "${TARGETARCH}" in \
            amd64) arch=x86_64; checksum="${TERRAMATE_CHECKSUM_AMD64}" ;; \
            arm64) arch=arm64; checksum="${TERRAMATE_CHECKSUM_ARM64}" ;; \
            *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
        esac \
    && archive="terramate_${TERRAMATE_VERSION}_linux_${arch}.tar.gz" \
    && wget -q "https://github.com/terramate-io/terramate/releases/download/v${TERRAMATE_VERSION}/${archive}" \
    && echo "${checksum}  ${archive}" > checksum.txt \
    && sha256sum -c checksum.txt \
    && tar -xzf "${archive}" terramate \
    && install -m 0755 terramate /usr/local/bin/terramate

# Latest version of Alpine image: https://hub.docker.com/_/alpine/tags
FROM alpine:3.24.4 AS tofu-age

# Latest version of tofu-age: https://github.com/specsnl/tofu-age/releases
ARG TOFU_AGE_VERSION=0.1.1
# Checksums can be found in the checksums.txt file attached to the release
ARG TOFU_AGE_CHECKSUM_AMD64=2ef4934f37cab97a149d8f10d6837f16f93c1966b3dfdcb0b6a5632996a0ed49
ARG TOFU_AGE_CHECKSUM_ARM64=197a1aeafe96af2b86018110cbd94d676b4fbbc074bc333648c2f55425f442d7
ARG TARGETARCH

WORKDIR /tmp/tofu-age

RUN case "${TARGETARCH}" in \
            amd64) checksum="${TOFU_AGE_CHECKSUM_AMD64}" ;; \
            arm64) checksum="${TOFU_AGE_CHECKSUM_ARM64}" ;; \
            *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
        esac \
    && archive="tofu-age_linux_${TARGETARCH}.tar.gz" \
    && wget -q "https://github.com/specsnl/tofu-age/releases/download/v${TOFU_AGE_VERSION}/${archive}" \
    && echo "${checksum}  ${archive}" > checksum.txt \
    && sha256sum -c checksum.txt \
    && tar -xzf "${archive}" tofu-age \
    && install -m 0755 tofu-age /usr/local/bin/tofu-age \
    && tofu-age --version

# Latest version of yq: https://hub.docker.com/r/mikefarah/yq/tags
FROM mikefarah/yq:4.54.3 AS yq

# Latest version of Alpine image: https://hub.docker.com/_/alpine/tags
FROM alpine:3.24.4 AS upcloud-cli

# Latest version of upctl: https://github.com/UpCloudLtd/upcloud-cli/releases
ARG UPCTL_VERSION=3.37.0
# Checksums can be found in the checksums.txt file attached to the release
ARG UPCTL_CHECKSUM_AMD64=ce2d381bdf49ce74a74582f390490542c49957079d7e606303e1426138b7e3d6
ARG UPCTL_CHECKSUM_ARM64=33c0d4b87631d5f4fdfd3bb63dd6564452e807a5dbbd95ea126d1ed121e77268
ARG TARGETARCH

WORKDIR /tmp/upctl

RUN case "${TARGETARCH}" in \
            amd64) arch=x86_64; checksum="${UPCTL_CHECKSUM_AMD64}" ;; \
            arm64) arch=arm64; checksum="${UPCTL_CHECKSUM_ARM64}" ;; \
            *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
        esac \
    && archive="upcloud-cli_${UPCTL_VERSION}_linux_${arch}.tar.gz" \
    && wget -q "https://github.com/UpCloudLtd/upcloud-cli/releases/download/v${UPCTL_VERSION}/${archive}" \
    && echo "${checksum}  ${archive}" > checksum.txt \
    && sha256sum -c checksum.txt \
    && tar -xzf "${archive}" upctl \
    && install -m 0755 upctl /usr/local/bin/upctl

FROM alpine:3.24.4 AS base

RUN apk add --no-cache --upgrade --no-progress \
        'ca-certificates>=20261020' \
        bash~=5.3 \
        git~=2.54 \
        openssh~=10.3

COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terramate /usr/local/bin/terramate /usr/local/bin/terramate
COPY --from=tofu-age /usr/local/bin/tofu-age /usr/local/bin/tofu-age

WORKDIR /workspace

CMD ["/bin/bash"]

FROM base AS upctl

RUN apk add --no-cache --upgrade --no-progress \
        curl~=8.23 \
        jq~=1.8 \
        openssl~=3.5

COPY --from=upcloud-cli /usr/local/bin/upctl /usr/local/bin/upctl
COPY --from=yq /usr/bin/yq /usr/local/bin/yq
