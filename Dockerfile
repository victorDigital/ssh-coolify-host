FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y nginx openssh-server

# Configure SSH for password authentication only
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Remove any existing default.conf and create a new one
RUN rm -f /etc/nginx/conf.d/default.conf
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html; }' > /etc/nginx/conf.d/default.conf

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]