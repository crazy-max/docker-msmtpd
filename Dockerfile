# syntax=docker/dockerfile:1

ARG MSMTP_VERSION=1.8.32
ARG ALPINE_VERSION=3.22
ARG XX_VERSION=1.8.0

FROM --platform=$BUILDPLATFORM tonistiigi/xx:${XX_VERSION} AS xx
FROM --platform=$BUILDPLATFORM alpine:${ALPINE_VERSION} AS base
COPY --from=xx / /
RUN apk --update --no-cache add clang curl file lld make musl-dev pkgconfig tar xz
ARG MSMTP_VERSION
WORKDIR /src
RUN curl -sSL "https://marlam.de/msmtp/releases/msmtp-$MSMTP_VERSION.tar.xz" | tar xJv --strip 1

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
ENV TZ=UTC

RUN apk --update --no-cache add \
    ca-certificates \
    gettext \
    gnutls \
    libidn2 \
    libgsasl \
    libsecret \
    mailx \
    shadow \
    tzdata \
  && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
  && addgroup -g 1500 msmtpd \
  && adduser -D -H -u 1500 -G msmtpd -s /bin/sh msmtpd \
  && touch /etc/msmtprc \
  && chown msmtpd:msmtpd /etc/msmtprc

COPY --from=builder /usr/bin/msmtp* /usr/bin/
COPY rootfs /

EXPOSE 2500

USER msmtpd

CMD ["sh", "/entrypoint.sh"]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD echo EHLO localhost | nc 127.0.0.1 2500 | grep 250 || exit 1
