#!/bin/sh

# Check if DEPLOYER_USERNAME is set
if [ -z "$DEPLOYER_USERNAME" ]; then
  echo "Error: DEPLOYER_USERNAME environment variable is not set."
  exit 1
fi

# Create user if it doesn't exist
if ! id "$DEPLOYER_USERNAME" &>/dev/null; then
  adduser --disabled-password --gecos "" "$DEPLOYER_USERNAME"
fi

# Set up data/www directory for deployment
chown -R www-data:www-data /data/www
chmod -R 755 /data/www

# Set password if DEPLOYER_PASSWORD is provided (optional)
if [ -n "$DEPLOYER_PASSWORD" ]; then
  echo "$DEPLOYER_USERNAME:$DEPLOYER_PASSWORD" | chpasswd
fi

# Add user to sudoers with no password required
echo "$DEPLOYER_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEPLOYER_USERNAME
chmod 0440 /etc/sudoers.d/$DEPLOYER_USERNAME

# Create privilege separation directory for SSH
mkdir -p /run/sshd

# Start SSH service in the background
/usr/sbin/sshd

# Test Nginx configuration and log any errors
echo "Testing Nginx configuration..."
nginx -t

# Start Nginx in the foreground
echo "Starting Nginx..."
nginx -g 'daemon off;'