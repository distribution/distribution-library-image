#!/usr/bin/env bash

: "${ARCHS=amd64,armv6,armv7,arm64,ppc64le,s390x}"

set -e

if [ $# -eq 0 ] ; then
	echo "Usage: ./update.sh <distribution/distribution tag or branch>"
	exit
fi

VERSION=$1

for arch in ${ARCHS//,/ }; do
  echo "Generating distribution dockerfile $VERSION ($arch)..."
  mkdir -p "$arch"
  cp docker-entrypoint.sh config-example.yml $arch
  cat > "$arch/Dockerfile" <<EOF
FROM alpine:3.14 AS download
RUN apk add --no-cache tar wget
WORKDIR /out
RUN wget -qO- https://github.com/distribution/distribution/releases/download/${VERSION}/registry_${VERSION##v}_linux_${arch}.tar.gz | tar -zxvf - registry

FROM alpine:3.14

RUN set -ex && apk add --no-cache ca-certificates

COPY --from=download /out/registry /bin/registry
COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
EOF
done

echo "Done."
