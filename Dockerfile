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

FROM alpine:3.24.2

RUN apk add --no-cache --upgrade --no-progress \
        'ca-certificates>=20260909' \
        bash~=5.3 \
        git~=2.54 \
        openssh~=10.3

COPY --from=opentofu /usr/local/bin/tofu /usr/local/bin/tofu
COPY --from=terramate /usr/local/bin/terramate /usr/local/bin/terramate

WORKDIR /workspace

CMD ["/bin/bash"]
