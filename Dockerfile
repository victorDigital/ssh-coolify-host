FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y nginx openssh-server sudo

# Configure SSH for password authentication only
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Create Nginx configuration with only the server block
RUN mkdir -p /data/www
RUN mkdir -p /data/images
RUN echo 'server { \
        listen 80; \
        location / { \
            root /data/www; \
        } \
        location /images/ { \
            root /data; \
        } \
    }' > /etc/nginx/conf.d/default.conf

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]