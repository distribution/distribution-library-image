FROM alpine:3.23

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.1.1'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='6f330a3ba9ea1d23a6ee189f449d792595240585bb2f159123d76ac594f70dd8' ;; \
		aarch64) arch='arm64';   sha256='8167316d2b4a57e10d44f8c8a3c75fea5f3ec1c71872760bb903e5e8e52e9ad6' ;; \
		armhf)   arch='armv6';   sha256='8cf93e43dfddb195f46dcf3e643d021f29c689a2662d1edb1e70f536f380e3ba' ;; \
		armv7)   arch='armv7';   sha256='23bfb562d2b41dc6cb800fc7a2ea682071999ebb4c6e7c8162988bc49eb10ec3' ;; \
		ppc64le) arch='ppc64le'; sha256='7f7e126b18b3deb1eecf14824bd80215cda6a10bb07a47c7c42268319cf5b305' ;; \
		s390x)   arch='s390x';   sha256='27f5f3237a6332b129d7383066eee99f15759f9add9304fbf283cef1e3803041' ;; \
		riscv64) arch='riscv64'; sha256='a64bb17c994885382c977d73695a3f000e884c25b8e5aa14857fedaa096619bb' ;; \
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
