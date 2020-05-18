#!/usr/bin/with-contenv bash

TZ=${TZ:-UTC}

#SMTP_HOST=${SMTP_HOST:-smtp.example.com}
#SMTP_PORT=${SMTP_PORT:-25}
#SMTP_TLS=${SMTP_TLS:-off}
#SMTP_STARTTLS=${SMTP_STARTTLS:-off}
#SMTP_TLS_CHECKCERT=${SMTP_TLS_CHECKCERT:-on}
#SMTP_AUTH=${SMTP_AUTH:-off}
#SMTP_USER=${SMTP_USER:-foo}
#SMTP_PASSWORD=${SMTP_PASSWORD:-bar}
#SMTP_FROM=${SMTP_FROM:-foo@example.com}

# From https://github.com/docker-library/mariadb/blob/master/docker-entrypoint.sh#L21-L41
# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

if [ -z "$SMTP_HOST" ]; then
  >&2 echo "ERROR: SMTP_HOST must be defined"
  exit 1
fi

echo "Setting timezone to ${TZ}..."
ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime
echo ${TZ} > /etc/timezone

echo "Creating configuration..."
cat > /etc/msmtprc <<EOL
account default
logfile -
syslog off
host ${SMTP_HOST}
EOL

file_env 'SMTP_USER'
file_env 'SMTP_PASSWORD'
if [ -n "$SMTP_PORT" ];           then echo "port $SMTP_PORT" >> /etc/msmtprc; fi
if [ -n "$SMTP_TLS" ];            then echo "tls $SMTP_TLS" >> /etc/msmtprc; fi
if [ -n "$SMTP_STARTTLS" ];       then echo "tls_starttls $SMTP_STARTTLS" >> /etc/msmtprc; fi
if [ -n "$SMTP_TLS_CHECKCERT" ];  then echo "tls_certcheck $SMTP_TLS_CHECKCERT" >> /etc/msmtprc; fi
if [ -n "$SMTP_AUTH" ];           then echo "auth $SMTP_AUTH" >> /etc/msmtprc; fi
if [ -n "$SMTP_USER" ];           then echo "user $SMTP_USER" >> /etc/msmtprc; fi
if [ -n "$SMTP_PASSWORD" ];       then echo "password $SMTP_PASSWORD" >> /etc/msmtprc; fi
if [ -n "$SMTP_FROM" ];           then echo "from $SMTP_FROM" >> /etc/msmtprc; fi
unset SMTP_USER
unset SMTP_PASSWORD
