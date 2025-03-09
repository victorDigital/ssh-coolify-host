#!/bin/sh

# Check if DEPLOYER_USERNAME is set
if [ -z "$DEPLOYER_USERNAME" ]; then
  echo "Error: DEPLOYER_USERNAME environment variable is not set."
  exit 1
fi

# Create user if it doesn’t exist
if ! id "$DEPLOYER_USERNAME" &>/dev/null; then
  adduser --disabled-password --gecos "" "$DEPLOYER_USERNAME"
fi

# Create web directory if it doesn’t exist
if [ ! -d "/home/$DEPLOYER_USERNAME/web" ]; then
  mkdir -p "/home/$DEPLOYER_USERNAME/web"
  chown "$DEPLOYER_USERNAME:$DEPLOYER_USERNAME" "/home/$DEPLOYER_USERNAME/web"
  chmod 755 "/home/$DEPLOYER_USERNAME/web"
fi

# Set password if DEPLOYER_PASSWORD is provided (optional)
if [ -n "$DEPLOYER_PASSWORD" ]; then
  echo "$DEPLOYER_USERNAME:$DEPLOYER_PASSWORD" | chpasswd
fi

# Add user to sudoers with no password required
echo "$DEPLOYER_USERNAME ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEPLOYER_USERNAME
chmod 0440 /etc/sudoers.d/$DEPLOYER_USERNAME

# Update Nginx to serve from the user's web directory
sed -i "s|root /usr/share/nginx/html;|root /home/$DEPLOYER_USERNAME/web;|" /etc/nginx/conf.d/default.conf

# Create privilege separation directory for SSH
mkdir -p /run/sshd

# Start SSH service in the background
/usr/sbin/sshd

# Start Nginx in the foreground
nginx -g 'daemon off;'