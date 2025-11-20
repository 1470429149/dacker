#!/bin/bash

ENCRYPTION_KEY="my_secret_key_2025"
ENCRYPTED_CONFIG="/etc/nginx-proxy/config.json.enc"
DECRYPTED_CONFIG="/etc/nginx-proxy/config.json"

if [ ! -f "$ENCRYPTED_CONFIG" ]; then
    exit 1
fi

openssl enc -aes-256-cbc -d -pbkdf2 -iter 100000 \
    -in "$ENCRYPTED_CONFIG" \
    -out "$DECRYPTED_CONFIG" \
    -k "$ENCRYPTION_KEY" 2>/dev/null

if [ $? -ne 0 ]; then
    exit 1
fi

if ! command -v jq &> /dev/null; then
    if ! grep -q '{' "$DECRYPTED_CONFIG" || ! grep -q '}' "$DECRYPTED_CONFIG"; then
        rm -f "$DECRYPTED_CONFIG"
        exit 1
    fi
else
    if ! jq empty "$DECRYPTED_CONFIG" 2>/dev/null; then
        rm -f "$DECRYPTED_CONFIG"
        exit 1
    fi
fi

chmod 600 "$DECRYPTED_CONFIG"
