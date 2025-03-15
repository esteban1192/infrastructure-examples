#!/bin/bash
KEY_FILE="/home/jenkins/.ssh/id_rsa"
PUB_KEY_FILE="${KEY_FILE}.pub"
AUTHORIZED_KEYS="/home/jenkins/.ssh/authorized_keys"

if [ -f "$KEY_FILE" ]; then
    echo "SSH key already exists. Skipping creation."
else
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N ""
    echo "SSH key pair generated."
fi

echo "Private key:"
cat "$KEY_FILE"

if ! grep -qF "$(cat "$PUB_KEY_FILE")" "$AUTHORIZED_KEYS"; then
    cat "$PUB_KEY_FILE" >> "$AUTHORIZED_KEYS"
    echo "Public key added to authorized_keys."
else
    echo "Public key already present in authorized_keys."
fi

echo "Starting SSHD..."
exec setup-sshd
