#!/bin/bash

if [ -z "$AWS_ACCESS_KEY_ID" ]; then
  echo "Error: AWS_ACCESS_KEY_ID is not set!"
  exit 1
fi
if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
  echo "Error: AWS_SECRET_ACCESS_KEY is not set!"
  exit 1
fi

# Define the key file name
KEY_FILE="/home/jenkins/.ssh/id_rsa"
PUB_KEY_FILE="${KEY_FILE}.pub"
AUTHORIZED_KEYS="/home/jenkins/.ssh/authorized_keys"

# Check if the private key already exists
if [ -f "$KEY_FILE" ]; then
    echo "SSH key already exists. Skipping creation."
else
    # Generate SSH key pair without passphrase
    ssh-keygen -t ed25519 -f "$KEY_FILE" -N ""
    echo "SSH key pair generated."
fi

# Display the private key
echo "Private key:"
cat "$KEY_FILE"

# Add the public key to the authorized_keys file if not already present
if ! grep -qF "$(cat "$PUB_KEY_FILE")" "$AUTHORIZED_KEYS"; then
    cat "$PUB_KEY_FILE" >> "$AUTHORIZED_KEYS"
    echo "Public key added to authorized_keys."
else
    echo "Public key already present in authorized_keys."
fi

echo "Starting SSHD..."
exec setup-sshd
