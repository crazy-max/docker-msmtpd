#!/usr/bin/with-contenv sh
# shellcheck shell=sh

mkdir -p /etc/services.d/msmtpd

echo USER $USER
echo USER_FILE $USER_FILE
echo PASSWORD $PASSWORD
echo PASSWORD_FILE $PASSWORD_FILE

if [ -n "$USER_FILE" ]; then
    USER=$(cat "$USER_FILE")
fi

PASSWORD_CMD=""
if [ -n "$PASSWORD" ]; then
    PASSWORD_CMD="\"echo \\\"$PASSWORD\\\"\""
fi
if [ -n "$PASSWORD_FILE" ]; then
    PASSWORD_CMD="\"cat \\\"$PASSWORD_FILE\\\"\""
fi

AUTH_CMD=""
if [ -n "$USER" ] && [ -n "$PASSWORD_CMD" ]; then
    AUTH_CMD=" --auth=${USER},${PASSWORD_CMD}"
fi

cat > /etc/services.d/msmtpd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
msmtpd --interface=0.0.0.0 --port=2500 --command="/usr/bin/msmtp -f %F" ${AUTH_CMD}
EOL
chmod +x /etc/services.d/msmtpd/run
