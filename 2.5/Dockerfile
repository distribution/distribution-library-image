# Build a minimal distribution container

FROM alpine:3.7

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils

# https://github.com/docker/distribution/releases
ENV REGISTRY_VERSION 2.5.2

# see https://github.com/docker/distribution/blob/v2.5.2/Dockerfile
RUN set -eux; \
    apk add --no-cache --virtual .build-deps git go libc-dev make; \
    export GOPATH='/go'; \
    export DISTRIBUTION_DIR="$GOPATH/src/github.com/docker/distribution"; \
    export DOCKER_BUILDTAGS='include_oss include_gcs'; \
    mkdir -p "$DISTRIBUTION_DIR"; \
    git clone -b "v$REGISTRY_VERSION" --depth 1 https://github.com/docker/distribution.git "$DISTRIBUTION_DIR"; \
    cd "$DISTRIBUTION_DIR"; \
    make PREFIX="$GOPATH" clean binaries; \
    cp "$GOPATH/bin/registry" /bin/registry; \
    mkdir -p /etc/docker/registry; \
    cp cmd/registry/config-example.yml /etc/docker/registry/config.yml; \
    cd /; \
    rm -rf "$GOPATH"; \
    apk del .build-deps; \
# smoke test
    registry --version

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
