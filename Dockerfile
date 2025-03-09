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

# Remove default nginx configuration
RUN rm -f /etc/nginx/sites-enabled/default

# Create our custom configuration
RUN echo 'server { \
        listen 80 default_server; \
        server_name _; \
        \
        location / { \
            root /data/www; \
            index index.html index.htm; \
            try_files $uri $uri/ =404; \
        } \
        \
        location /images/ { \
            root /data; \
            autoindex on; \
        } \
    }' > /etc/nginx/conf.d/default.conf

# Create a sample index.html file to verify configuration
RUN echo '<!DOCTYPE html>\
<html>\
<head>\
    <title>My Custom Nginx Page</title>\
</head>\
<body>\
    <h1>Success! The custom nginx configuration is working.</h1>\
</body>\
</html>' > /data/www/index.html

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]