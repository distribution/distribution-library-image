# Build a minimal distribution container

FROM debian:jessie

RUN apt-get update && \
    apt-get install -y ca-certificates librados2 apache2-utils && \
    rm -rf /var/lib/apt/lists/*

COPY ./registry/registry /bin/registry
COPY ./registry/config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
