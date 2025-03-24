FROM alpine:3.21

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0-rc.4'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='bdd57a6c9fa802bb72407936045b323aadc61abfd7fac6e55364dee8a1d18d50' ;; \
		aarch64) arch='arm64';   sha256='94bdf16a7813a7a501cc23bf7c8a40625456cbe1b9863b4626caddc801b7071b' ;; \
		armhf)   arch='armv6';   sha256='f9d7928264c05d4d5b55e270d9f49eca1376d7aeade34ea80513f82bac4ea3ae' ;; \
		armv7)   arch='armv7';   sha256='ce384d85cfd260245e7845d9512a89fe1d790d5b6c09c5fc6907326251cd2db2' ;; \
		ppc64le) arch='ppc64le'; sha256='e15a7883883bc054f04c88e99ea8b80e7bb36eed86bc5dc3a5604e138339fa08' ;; \
		s390x)   arch='s390x';   sha256='7d3879657f7184bd4315fcf05154dd87f3045ce256380fdfd6a9bc34a094296b' ;; \
		riscv64) arch='riscv64'; sha256='94cc989b4e16b86abe221c2cc8adc67199d824dbff891d7da87f981dd9353409' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget -O registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz"; \
	echo "$sha256 *registry.tar.gz" | sha256sum -c -; \
	tar --extract --verbose --file registry.tar.gz --directory /bin/ registry; \
	rm registry.tar.gz; \
	registry --version

COPY ./config-example.yml /etc/distribution/config.yml

VOLUME ["/var/lib/registry"]
EXPOSE 5000

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/etc/distribution/config.yml"]
