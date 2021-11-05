FROM docker.io/golang:1.13-alpine AS builder

ENV DISTRIBUTION_DIR /go/src/github.com/distribution/distribution
ENV DISTRIBUTION_URL https://github.com/distribution/distribution.git
ENV DISTRIBUTION_TAG v2.7.1
ENV BUILDTAGS include_oss include_gcs

RUN set -ex \
    && apk add --no-cache make git file

WORKDIR ${DISTRIBUTION_DIR}
RUN git clone -b ${DISTRIBUTION_TAG} ${DISTRIBUTION_URL} ${DISTRIBUTION_DIR} \
    && CGO_ENABLED=0 make clean binaries \
    && file ./bin/registry | grep "statically linked"

FROM docker.io/alpine:latest

RUN set -ex \
    && apk add --no-cache ca-certificates

COPY --from=builder /go/src/github.com/distribution/distribution/bin/registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
