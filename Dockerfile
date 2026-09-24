FROM alpine:3.24

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.1.2'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='40df2224d410f72ae425c3371873b078bbdbda3b8b612be9571f0e6751f3acc8' ;; \
		aarch64) arch='arm64';   sha256='09d26f88d2c0f161bd1b8bfc6c123571cc3d291dcca8af5477b3cacc4ec95e73' ;; \
		armhf)   arch='armv6';   sha256='4a2e24eb4862e89efa7fc37a2ee2428d07783b70f7a810b1c51495c97c338b4c' ;; \
		armv7)   arch='armv7';   sha256='5227ce1aae578c9df6b6e736d44d6b5bcb244d942bdaf0c8bdfe800c08a0067d' ;; \
		ppc64le) arch='ppc64le'; sha256='3bee3e9fac37fb182a56f1dba0fc9fa059e598b1ec31049a69c48ed610ff14ca' ;; \
		s390x)   arch='s390x';   sha256='907d384ac0b181a84f61aacfc32ed26f6af0e9a7d7877a708a29945f959c81de' ;; \
		riscv64) arch='riscv64'; sha256='9bd0f9e3e29ac2429a59729adb866faa0137fca1194a7e0c5eb409dea567cca7' ;; \
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
