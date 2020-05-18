#!/usr/bin/with-contenv sh

if [ -n "${PGID}" ] && [ "${PGID}" != "$(id -g msmtpd)" ]; then
  echo "Switching to PGID ${PGID}..."
  sed -i -e "s/^msmtpd:\([^:]*\):[0-9]*/msmtpd:\1:${PGID}/" /etc/group
  sed -i -e "s/^msmtpd:\([^:]*\):\([0-9]*\):[0-9]*/msmtpd:\1:\2:${PGID}/" /etc/passwd
fi
if [ -n "${PUID}" ] && [ "${PUID}" != "$(id -u msmtpd)" ]; then
  echo "Switching to PUID ${PUID}..."
  sed -i -e "s/^msmtpd:\([^:]*\):[0-9]*:\([0-9]*\)/msmtpd:\1:${PUID}:\2/" /etc/passwd
fi
