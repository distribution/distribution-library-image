FROM alpine:3.15

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='2.8.0-beta.1'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='d69d68406a30466070d8e47c21fafaadae5c048239df41b50b28a79fa12945ab' ;; \
		aarch64) arch='arm64';   sha256='2a080694ae2528a628245cf5177d4d2e55d430c5dd76cbbf61e5aee08e75abf6' ;; \
		armhf)   arch='armv6';   sha256='b5092556fd196f59c7d2a8d4e4460c193588d9f7f39d825d17f299d7fc856ca1' ;; \
		armv7)   arch='armv7';   sha256='f479d7d42a4c6086ee9a51f605386fcfb953198bf9ab48c515ffdde33ad46e5d' ;; \
		ppc64le) arch='ppc64le'; sha256='dc0444e672511b4f8dc19fcec1624a33fdaf49a72ff3c1a69bae9bd3399cd074' ;; \
		s390x)   arch='s390x';   sha256='4b814d1cb60ee7881e59c1ee52635755c2279196861892cface92e58aa6ac749' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz"; \
	echo "$sha256 *registry.tar.gz" | sha256sum -c -; \
	tar --extract --verbose --file registry.tar.gz --directory /bin/ registry; \
	rm registry.tar.gz; \
	registry --version

COPY ./config-example.yml /etc/docker/registry/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/docker/registry/config.yml"]
