FROM --platform=${TARGETPLATFORM:-linux/amd64} crazymax/alpine-s6:3.12 as builder

RUN apk --update --no-cache add \
    autoconf \
    automake \
    binutils \
    build-base \
    curl \
    git \
    gettext-dev \
    gnutls-dev \
    libidn2-dev \
    libgsasl-dev \
    libsecret-dev \
    openssl-dev \
    tar \
  && rm -rf /tmp/*

ENV MSMTP_VERSION="1.8.14"

WORKDIR /tmp/msmtp
RUN curl -sSL "https://marlam.de/msmtp/releases/msmtp-$MSMTP_VERSION.tar.xz" | tar xJv --strip 1 \
  && ./configure \
    --prefix=/usr \
    --sysconfdir=/etc \
    --mandir=/usr/share/man \
    --localstatedir=/var \
  && make -j$(nproc) \
  && make install \
  && msmtp --version

ARG TARGETPLATFORM
FROM --platform=${TARGETPLATFORM:-linux/amd64} crazymax/alpine-s6:3.12

LABEL maintainer="CrazyMax"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS="2" \
  TZ="UTC" \
  PUID="1500" \
  PGID="1500"

COPY --from=builder /usr/bin/msmtp* /usr/bin/
COPY rootfs /

RUN apk --update --no-cache add \
    bash \
    ca-certificates \
    gettext \
    gnutls \
    libidn2 \
    libgsasl \
    libsecret \
    mailx \
    openssl \
    shadow \
    su-exec \
    tzdata \
  && ln -sf /usr/bin/msmtp /usr/sbin/sendmail \
  && addgroup -g ${PGID} msmtpd \
  && adduser -D -H -u ${PUID} -G msmtpd -s /bin/sh msmtpd \
  && rm -rf /tmp/* /var/cache/apk/*

EXPOSE 2500

ENTRYPOINT [ "/init" ]

HEALTHCHECK --interval=10s --timeout=5s \
  CMD echo EHLO localhost | nc 127.0.0.1 2500 | grep 250 || exit 1
