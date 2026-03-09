#!/bin/sh
set -eu

file_env() {
  var="$1"
  file_var="${var}_FILE"
  def="${2:-}"
  eval "var_value=\${$var:-}"
  eval "file_value=\${$file_var:-}"
  if [ -n "$var_value" ] && [ -n "$file_value" ]; then
    echo >&2 "error: both $var and $file_var are set (but are exclusive)"
    exit 1
  fi
  if [ -n "$var_value" ]; then
    value="$var_value"
  elif [ -n "$file_value" ]; then
    value="$(cat "$file_value")"
  else
    value="$def"
  fi
  export "$var=$value"
  unset "$file_var"
}

if [ -z "${SMTP_HOST:-}" ]; then
  echo >&2 "ERROR: SMTP_HOST must be defined"
  exit 1
fi

echo "Creating configuration..."
cat > /etc/msmtprc <<EOF
account default
logfile -
syslog off
host ${SMTP_HOST}
EOF

file_env "SMTP_USER"
file_env "SMTP_PASSWORD"
if [ -n "${SMTP_PORT:-}" ]; then echo "port ${SMTP_PORT}" >> /etc/msmtprc; fi
if [ -n "${SMTP_TLS:-}" ]; then echo "tls ${SMTP_TLS}" >> /etc/msmtprc; fi
if [ -n "${SMTP_STARTTLS:-}" ]; then echo "tls_starttls ${SMTP_STARTTLS}" >> /etc/msmtprc; fi
if [ -n "${SMTP_TLS_CHECKCERT:-}" ]; then echo "tls_certcheck ${SMTP_TLS_CHECKCERT}" >> /etc/msmtprc; fi
if [ -n "${SMTP_AUTH:-}" ]; then echo "auth ${SMTP_AUTH}" >> /etc/msmtprc; fi
if [ -n "${SMTP_USER:-}" ]; then echo "user ${SMTP_USER}" >> /etc/msmtprc; fi
if [ -n "${SMTP_PASSWORD:-}" ]; then echo "password ${SMTP_PASSWORD}" >> /etc/msmtprc; fi
if [ -n "${SMTP_DOMAIN:-}" ]; then echo "domain ${SMTP_DOMAIN}" >> /etc/msmtprc; fi
if [ -n "${SMTP_FROM:-}" ]; then echo "from ${SMTP_FROM}" >> /etc/msmtprc; fi
if [ -n "${SMTP_ALLOW_FROM_OVERRIDE:-}" ]; then echo "allow_from_override ${SMTP_ALLOW_FROM_OVERRIDE}" >> /etc/msmtprc; fi
if [ -n "${SMTP_SET_FROM_HEADER:-}" ]; then echo "set_from_header ${SMTP_SET_FROM_HEADER}" >> /etc/msmtprc; fi
if [ -n "${SMTP_SET_DATE_HEADER:-}" ]; then echo "set_date_header ${SMTP_SET_DATE_HEADER}" >> /etc/msmtprc; fi
if [ -n "${SMTP_REMOVE_BCC_HEADERS:-}" ]; then echo "remove_bcc_headers ${SMTP_REMOVE_BCC_HEADERS}" >> /etc/msmtprc; fi
if [ -n "${SMTP_UNDISCLOSED_RECIPIENTS:-}" ]; then echo "undisclosed_recipients ${SMTP_UNDISCLOSED_RECIPIENTS}" >> /etc/msmtprc; fi
if [ -n "${SMTP_DSN_NOTIFY:-}" ]; then echo "dsn_notify ${SMTP_DSN_NOTIFY}" >> /etc/msmtprc; fi
if [ -n "${SMTP_DSN_RETURN:-}" ]; then echo "dsn_return ${SMTP_DSN_RETURN}" >> /etc/msmtprc; fi
unset SMTP_USER
unset SMTP_PASSWORD

echo "Starting msmtpd..."
exec msmtpd --interface=0.0.0.0 --port=2500 --log=/proc/self/fd/2 "--command=/usr/bin/msmtp -f %F"
