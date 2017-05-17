# escape=`
FROM microsoft/windowsservercore:10.0.14393.1198

WORKDIR C:\registry
COPY ./registry/registry.exe registry.exe
COPY ./registry/config-example.yml config.yml

VOLUME ["c:\\data"]
EXPOSE 5000

ENTRYPOINT ["registry.exe", "serve"]
CMD ["config.yml"]