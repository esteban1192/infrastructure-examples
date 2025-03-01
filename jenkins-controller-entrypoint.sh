#!/bin/bash
set -e

AGENT_HOST="jenkins-agent"
SSH_PORT=22

echo "Waiting for Jenkins agent SSH to be ready..."
while ! nc -z $AGENT_HOST $SSH_PORT; do
  sleep 2
done

echo "Jenkins agent is ready. Adding SSH key..."
mkdir -p /var/jenkins_home/.ssh
ssh-keyscan -H $AGENT_HOST > /var/jenkins_home/.ssh/known_hosts

echo "SSH key added successfully."

# Start Jenkins normally
exec /usr/bin/tini -- /usr/local/bin/jenkins.sh
