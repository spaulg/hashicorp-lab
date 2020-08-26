#!/bin/sh
set -e

# PHP settings
if [ "$PHP_TIMEZONE" = "" ]; then
  PHP_TIMEZONE="UTC"
fi

# Write PHP config
cat << EOF > /etc/php/conf.d/zz-docker.ini
date.timezone = $PHP_TIMEZONE
EOF

exec "$@"
