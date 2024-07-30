#!/usr/bin/env bash
set -x

/var/www/entrypoint.py

/usr/bin/envsubst < /config/config-docker-compose.ttl > /config/config.ttl

ln -s /config/config.ttl /var/www/html/config.ttl
cat /var/www/html/config.ttl

/usr/sbin/apache2ctl -D FOREGROUND
