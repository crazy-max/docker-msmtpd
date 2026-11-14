#!/bin/bash
set -eu

s6-rc -a list | grep -qx msmtpd
test "$(s6-svstat -o up,wantedup /run/service/msmtpd)" = "true true"

pid=$(s6-svstat -o pid /run/service/msmtpd)
grep -Eq "^Uid:[[:space:]]+${PUID}[[:space:]]" "/proc/${pid}/status"
grep -Eq "^Gid:[[:space:]]+${PGID}[[:space:]]" "/proc/${pid}/status"

exec 3<>/dev/tcp/127.0.0.1/"${LISTEN_PORT}"
read -r -t 5 reply <&3
[[ "$reply" = 220* ]]
printf 'HELO localhost\r\n' >&3
read -r -t 5 reply <&3
[[ "$reply" = 250* ]]
printf 'QUIT\r\n' >&3
read -r -t 5 reply <&3
[[ "$reply" = 221* ]]
