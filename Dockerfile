FROM alpine:3.20

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0-rc.1'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='ca7a81752601dcfbc6e6c00fb5b87fd117ac35553e3025b40033e03945077bb0' ;; \
		aarch64) arch='arm64';   sha256='47b45df09919e89091c7e9225b92b75b41fe6bdf5767793a26de011c046f88e3' ;; \
		armhf)   arch='armv6';   sha256='6cbf67de5f0e2927f0a4e0863bbc88f8831aaf94348c2f930a411aebcb6ca694' ;; \
		armv7)   arch='armv7';   sha256='4819de376733af19427ce4f5b0944db195f0e5f8bfd93e46e6c5784ad50d53b6' ;; \
		ppc64le) arch='ppc64le'; sha256='3289e9012133947f28a85c29f667755f6ad63856dd3b8891aa5a46443813a3f7' ;; \
		s390x)   arch='s390x';   sha256='2d0026e09fec4b0bd4dafddf6ab1b22c6ea19ab49c866ec0ec8dd8fe12f6ef21' ;; \
                riscv64) arch='riscv64'; sha256='32ae070e57596dab3b23dd48877069792a70fe13e9b429c498cfee6b56be860a' ;; \
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
