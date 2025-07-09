FROM alpine:3.21

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='61c9a2c0d5981a78482025b6b69728521fbc78506d68b223d4a2eb825de5ca3d' ;; \
		aarch64) arch='arm64';   sha256='6c2ee1d135626fa42e0d6fb66a0e0f42e22439e5050087d04f4c5ff53655892e' ;; \
		armhf)   arch='armv6';   sha256='e038bba14c573628407d9f5dfa6b6f9d782acda62abf52dbf24ab257bbeedfe7' ;; \
		armv7)   arch='armv7';   sha256='147d617e604e2e7d11b055484493c6a20731f6ce252d2bc47c716d8c48258719' ;; \
		ppc64le) arch='ppc64le'; sha256='5386e9811790616d5b3c4d5de2f449e6da99f03dd45f33ee3e3464e81a264e6e' ;; \
		s390x)   arch='s390x';   sha256='c8645e6fcebde5a441e1050c673b3ffa38572f61c1d1b1605d2bf333d3760328' ;; \
		riscv64) arch='riscv64'; sha256='99bfeef7c553bf7b9861435e6b55fa584ecca73704f4a71418e482cc2d9e013d' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz"; \
	echo "$sha256 *registry.tar.gz" | sha256sum -c -; \
	tar --extract --verbose --file registry.tar.gz --directory /bin/ registry; \
	rm registry.tar.gz; \
	registry --version

COPY ./config-example.yml /etc/distribution/config.yml

ENV OTEL_TRACES_EXPORTER=none

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/distribution/config.yml"]
