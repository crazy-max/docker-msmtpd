#!/usr/bin/with-contenv sh
# shellcheck shell=sh

mkdir -p /etc/services.d/msmtpd
cat > /etc/services.d/msmtpd/run <<EOL
#!/usr/bin/execlineb -P
with-contenv
s6-setuidgid ${PUID}:${PGID}
msmtpd --interface=0.0.0.0 --port=2500 --command="/usr/bin/msmtp -f %F"
EOL
chmod +x /etc/services.d/msmtpd/run
