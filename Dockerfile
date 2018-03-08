# Stage 1
FROM golang:1.9.4-alpine as builder1

MAINTAINER alex@openfaas.com
ENTRYPOINT []

RUN apk --no-cache add make curl \
    && curl -sL https://github.com/openfaas/faas/releases/download/0.7.1/fwatchdog > /usr/bin/fwatchdog \
    && chmod +x /usr/bin/fwatchdog

WORKDIR /go/src/github.com/openfaas/faas/sample-functions/DockerHubStats

COPY . /go/src/github.com/openfaas/faas/sample-functions/DockerHubStats

RUN make install

# Stage 2

FROM  python:rc-alpine
MAINTAINER infrastructure@dallasmakerspace.org

# Needed to reach the hub
RUN apk --no-cache add ca-certificates 

COPY --from=builder1 /usr/bin/fwatchdog  /usr/bin/fwatchdog
COPY . /data/

EXPOSE 8080
ENV VIRTUAL_PORT 8080
ENV fprocess "/data/member-storage-audit.py"
HEALTHCHECK --interval=5s CMD [ -e /tmp/.lock ] || exit 1
CMD ["/usr/bin/fwatchdog"]
