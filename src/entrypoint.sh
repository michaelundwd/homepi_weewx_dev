#!/bin/bash

# all code below here to the final fi is skipped for testing a highly compact entrypoint.sh
#if [[ ]]; then

set -o nounset
set -o errexit
set -o pipefail

CONF_FILE="/data/weewx.conf"

# echo version before starting syslog so we don't confound our tests
if [ "$1" = "--version" ]; then
  gosu weewx:weewx ./bin/weewxd --version
  exit 0
fi

if [ "$(id -u)" = 0 ]; then
  echo set timezone using environment
  ln -snf /usr/share/zoneinfo/"${TIMEZONE:-UTC}" /etc/localtime
  # start the syslog daemon as root
  /sbin/syslogd -n -S -O - &
  if [ "${WEEWX_UID:-weewx}" != 0 ]; then
    echo drop privileges and restart this script
    echo "Switching uid:gid to ${WEEWX_UID:-weewx}:${WEEWX_GID:-weewx}"
    gosu "${WEEWX_UID:-weewx}:${WEEWX_GID:-weewx}" "$(readlink -f "$0")" "$@"
    exit 0
  fi
fi

# default config

#fi
# this is the end of the code to be skipped

#	copy belchertown.py from /data/bin/user to /home/weewx/bin/user/belchertown.py
#	means all Belchertown skin configuration is external to the container where they can be modified

#chmod 777 ./bin/user
cp -f /data/bin/user/belchertown.py ./bin/user/
#chmod 775 ./bin/user

./bin/weewxd "$@"
