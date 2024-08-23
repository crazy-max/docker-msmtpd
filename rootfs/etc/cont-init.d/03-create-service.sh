#!/usr/bin/with-contenv sh
# shellcheck shell=sh

mkdir -p /etc/services.d/msmtpd

if [ -n "$MSMTP_USER_FILE" ]; then
    MSMTP_USER=$(cat "$MSMTP_USER_FILE")
fi

PASSWORD_CMD=""
if [ -n "$MSMTP_PASSWORD" ]; then
    PASSWORD_CMD="\"echo \\\"$MSMTP_PASSWORD\\\"\""
fi
if [ -n "$MSMTP_PASSWORD_FILE" ]; then
    PASSWORD_CMD="\"cat \\\"$MSMTP_PASSWORD_FILE\\\"\""
fi

AUTH_CMD=""
if [ -n "$MSMTP_USER" ] && [ -n "$PASSWORD_CMD" ]; then
    AUTH_CMD=" --auth=${MSMTP_USER},${PASSWORD_CMD}"
fi

cat > /etc/services.d/msmtpd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
msmtpd --interface=0.0.0.0 --port=2500 --command="/usr/bin/msmtp -f %F" ${AUTH_CMD}
EOL
chmod +x /etc/services.d/msmtpd/run
