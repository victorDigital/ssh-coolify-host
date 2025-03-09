FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y nginx openssh-server

# Configure SSH for password authentication only
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Remove default Nginx site to avoid conflicts
RUN rm -f /etc/nginx/sites-enabled/default

# Create directory for custom Nginx configurations
RUN mkdir -p /etc/nginx/conf.d

# Create default Nginx configuration with a placeholder root
RUN echo 'server { listen 80; root /usr/share/nginx/html; index index.html; }' > /etc/nginx/conf.d/default.conf

# Append include directive to nginx.conf to load custom configurations
RUN echo 'include /etc/nginx/conf.d/*.conf;' >> /etc/nginx/nginx.conf

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]