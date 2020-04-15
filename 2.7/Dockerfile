# Building Registry Binary
ARG GO_VERSION=1.13.8
ARG ALPINE_VERSION=3.8

FROM golang:${GO_VERSION}-alpine3.11 AS build

ENV DISTRIBUTION_DIR ${GOPATH}/src/github.com/docker/distribution
ENV BUILDTAGS include_oss include_gcs

ARG REGISTRY_VERSION=v2.7.1
ENV REGISTRY_VERSION=${REGISTRY_VERSION}

RUN apk add --no-cache git make file \
    && rm -rf /tmp/*.apk /var/cache/apk/*

RUN mkdir -p ${DISTRIBUTION_DIR} \
    && git clone -b ${REGISTRY_VERSION} https://github.com/docker/distribution.git ${DISTRIBUTION_DIR} \
    && cd ${DISTRIBUTION_DIR}; \
    CGO_ENABLED=0 make clean binaries \
    && file ${DISTRIBUTION_DIR}/bin/registry | grep "statically linked" \
    && mv ${DISTRIBUTION_DIR}/bin/registry /bin/

# Build a minimal distribution container
FROM alpine:${ALPINE_VERSION}

RUN set -ex \
    && apk add --no-cache ca-certificates apache2-utils \
    && rm -rf /tmp/*.apk /var/cache/apk/*

COPY --from=build /bin/registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
