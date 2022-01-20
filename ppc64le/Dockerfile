FROM alpine:3.14 AS download
RUN apk add --no-cache tar wget
WORKDIR /out
RUN wget -qO- https://github.com/distribution/distribution/releases/download/v2.8.0-beta.1/registry_2.8.0-beta.1_linux_ppc64le.tar.gz | tar -zxvf - registry

FROM alpine:3.14

RUN set -ex && apk add --no-cache ca-certificates

COPY --from=download /out/registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
