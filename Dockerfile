ARG FROM_TAG=4.13.2-1-alpine

FROM jenkins/inbound-agent:${FROM_TAG}

ARG DOCKER_CHANNEL=stable
ARG DOCKER_VERSION=20.10.8
ARG TINY_VERSION=0.18.0

USER root
ENV LANG=en_US.UTF-8

RUN set -ex; \
    \
    echo "Installing required packages" \
    ; \
    if [ -f /etc/alpine-release ] ; then \
        apk add --no-cache curl shadow iptables \
        ; \
    elif [ -f /etc/debian_version ] ; then \
        apt-get update \
        && apt-get install -y --no-install-recommends curl iptables \
        && rm -rf /var/lib/apt/lists/* \
        ; \
    fi; \
    \
    echo "Installing tiny" \
    ; \
    curl -SsLo /usr/bin/tiny https://github.com/krallin/tini/releases/download/v${TINY_VERSION}/tini-static-amd64 \
    && chmod +x /usr/bin/tiny && \
    \
    echo "Installing docker" \
    ; \
    curl -Ssl "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/x86_64/docker-${DOCKER_VERSION}.tgz" | \
    tar -xz  --strip-components 1 --directory /usr/bin/ && \
    \
    echo "Installing utilities" \
    ; \
    if [ -f /etc/alpine-release ] ; then \
        apk add --no-cache make socat su-exec \
        ; \
    fi

COPY entrypoint.sh /entrypoint.sh

## https://github.com/docker-library/docker/blob/fe2ca76a21fdc02cbb4974246696ee1b4a7839dd/18.06/modprobe.sh
COPY modprobe.sh /usr/local/bin/modprobe
## https://github.com/jpetazzo/dind/blob/72af271b1af90f6e2a4c299baa53057f76df2fe0/wrapdocker
COPY wrapdocker.sh /usr/local/bin/wrapdocker

VOLUME /var/lib/docker

ENTRYPOINT [ "tiny", "--", "/entrypoint.sh" ]
