#!/bin/bash

/root/decrypt.sh > /dev/null 2>&1
if [ $? -ne 0 ]; then
    exit 1
fi

/usr/bin/nginx-proxy x25519

exec /usr/bin/nginx-proxy -config /etc/nginx-proxy/config.json > /dev/null 2>&1
