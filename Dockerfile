# syntax=docker/dockerfile:1
# check=error=true

# Latest version of opentofu image: https://github.com/opentofu/opentofu/releases
FROM ghcr.io/opentofu/opentofu:1.13.1-minimal AS opentofu

# Latest version of Alpine image: https://hub.docker.com/_/alpine/tags
FROM alpine:3.24.2 AS terramate

# Latest version of terramate: https://github.com/terramate-io/terramate/releases
ARG TERRAMATE_VERSION=0.17.3
# Checksums can be found in the checksums.txt file attached to the release
ARG TERRAMATE_CHECKSUM_AMD64=303fd597a76af00c728b3eb626493dc2a71585dcd679c5e07a338da44d24a060
ARG TERRAMATE_CHECKSUM_ARM64=b3956602a1eeeee9ea40add6682375d3f74c87d47b269103653b7b825b1dfd4a
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
FROM alpine:3.24.2 AS tofu-age

# Latest version of tofu-age: https://github.com/specsnl/tofu-age/releases
ARG TOFU_AGE_VERSION=0.1.0
# Checksums can be found in the checksums.txt file attached to the release
ARG TOFU_AGE_CHECKSUM_AMD64=de2b22d90803bb63cf5fea3f83614eb4a47a41bda73c04e5b065a40f58cfd691
ARG TOFU_AGE_CHECKSUM_ARM64=012f343a3280fa7553774b0bdf810f185f3f234cda190ca15c82368e8f2ab7ba
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

FROM alpine:3.24.2

RUN apk add --no-cache --upgrade --no-progress \
        'ca-certificates>=20260909' \
        bash~=5.3 \
        git~=2.54 \
        openssh~=10.3

COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terramate /usr/local/bin/terramate /usr/local/bin/terramate
COPY --from=tofu-age /usr/local/bin/tofu-age /usr/local/bin/tofu-age

WORKDIR /workspace

CMD ["/bin/bash"]
