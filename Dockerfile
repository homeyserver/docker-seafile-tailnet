# Use LinuxServer.io Ubuntu base image for docker-mod support
FROM lsiobase/ubuntu:jammy

# Set labels
LABEL maintainer="electblake"
LABEL org.opencontainers.image.source="https://github.com/electblake/homey-seafile-server"
LABEL org.opencontainers.image.description="Seafile server based on LinuxServer.io base with Tailscale support"

# Set environment variables
ARG SEAFILE_VERSION=11.0.12
ENV SEAFILE_VERSION=${SEAFILE_VERSION}

# Install dependencies
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-ldap \
    python3-urllib3 \
    python3-requests \
    python3-mysqldb \
    python3-memcache \
    python3-pil \
    python3-captcha \
    python3-openpyxl \
    python3-future \
    python3-qrcode \
    ffmpeg \
    libmemcached11 \
    libmemcached-dev \
    pwgen \
    curl \
    tzdata \
    sqlite3 && \
  echo "**** install seafile ****" && \
  mkdir -p /opt/seafile && \
  cd /opt/seafile && \
  curl -sSL https://s3.eu-central-1.amazonaws.com/download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz | tar xz -C /opt/seafile && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Copy root filesystem
COPY root/ /

# Ports and volumes
EXPOSE 80 443 8000 8082

VOLUME /config /data
