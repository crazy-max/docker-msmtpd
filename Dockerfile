# syntax=docker/dockerfile:1

ARG MSMTP_VERSION=1.8.34
ARG ALPINE_VERSION=3.24
ARG XX_VERSION=1.9.0

FROM --platform=$BUILDPLATFORM tonistiigi/xx:${XX_VERSION} AS xx
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS base
COPY --from=xx / /
RUN apk --update --no-cache add clang curl file lld make musl-dev pkgconfig tar xz
ARG MSMTP_VERSION
WORKDIR /src
RUN <<EOT
  set -ex
  curl -fsSL --retry 5 --retry-all-errors --connect-timeout 20 --max-time 120 -o /tmp/msmtp.tar.xz "https://marlam.de/msmtp/releases/msmtp-$MSMTP_VERSION.tar.xz"
  tar xJvf /tmp/msmtp.tar.xz --strip 1
EOT

FROM base AS builder
ARG TARGETPLATFORM
RUN xx-apk --no-cache --no-scripts add g++ gettext-dev gnutls-dev libidn2-dev
RUN <<EOT
  set -ex
  CC=xx-clang CXX=xx-clang++ ./configure --host=$(xx-clang --print-target-triple) --prefix=/usr --sysconfdir=/etc --localstatedir=/var
  make -j$(nproc)
  make install
  xx-verify /usr/bin/msmtp
  xx-verify /usr/bin/msmtpd
  file /usr/bin/msmtpd
EOT

FROM alpine:${ALPINE_VERSION}

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  TZ="UTC" \
  PUID="1500" \
  PGID="1500" \
  LISTEN_PORT="2500"

RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    gettext \
    gnutls \
    libidn2 \
    libgsasl \
    libsecret \
    mailx \
    s6-overlay \
    shadow \
    tzdata \
  && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
  && addgroup -g ${PGID} msmtpd \
  && adduser -D -H -u ${PUID} -G msmtpd -s /bin/sh msmtpd \
  && rm -rf /tmp/*

COPY --from=builder /usr/bin/msmtp* /usr/bin/
COPY rootfs /

EXPOSE 2500

ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD netstat -ltn | grep -q ":${LISTEN_PORT}[[:space:]].*LISTEN" || exit 1
