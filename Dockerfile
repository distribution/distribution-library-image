FROM alpine:3.21

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0-rc.3'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='e4412fbc7b010432e64dca3f02140d608912ec3aa91554ff3b67700891bb3a12' ;; \
		aarch64) arch='arm64';   sha256='393eb2fff43d93a362a3ec417ec07d4304b81bee9276d1a589951467c4a49bf3' ;; \
		armhf)   arch='armv6';   sha256='a4f25dc7eaed798523c045afbef5e9416c7810904777e92fc4797321cdfd2a24' ;; \
		armv7)   arch='armv7';   sha256='7fdf37749bf9b7692ecd419779cd0d298cc54a7b32b5cb838a71bb3c3b126272' ;; \
		ppc64le) arch='ppc64le'; sha256='7d1c58daa3ba9373d5ce12b7e235795a62951ed9afd91aad0280a1cc115bf060' ;; \
		s390x)   arch='s390x';   sha256='d99a60587451f6daa9a67ea1ebe55982f7a967834926830b7463dcdd739ab01b' ;; \
		riscv64) arch='riscv64'; sha256='46a24d55f2efbbcfbc97aee9962c61c76a3be7aa6f7b76faaa9513e8866d20d4' ;; \
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
