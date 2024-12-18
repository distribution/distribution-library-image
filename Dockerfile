FROM alpine:3.21

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0-rc.2'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='79d16fec004780982d65f190c97a8e0f1516bf619bfbbc44975db916a21fa08d' ;; \
		aarch64) arch='arm64';   sha256='5564b3aed056bcaf08aac7d696c5643bbc43ddbd3b55a7e129bccda94ae02053' ;; \
		armhf)   arch='armv6';   sha256='72ac41a85f45f1e2a5df9bf976a1ee4bf36e9bce9628e9d0f1ee9cef9465f5f7' ;; \
		armv7)   arch='armv7';   sha256='e652f8174a7079941826409d86d073e40d49e70ab4519540501cfef770cdfe3e' ;; \
		ppc64le) arch='ppc64le'; sha256='c02248db69dbdc0dac1d9b44801198101a19defdfd78223050ab68c0d66d0056' ;; \
		s390x)   arch='s390x';   sha256='92163ab2b308a0431fd607bc93df699ec64286725ed7f77925971c30ab965054' ;; \
                riscv64) arch='riscv64'; sha256='ac471747ae01c218166265bbb73b4416f8fad5d84dda855ee422804dab71a584' ;; \
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
