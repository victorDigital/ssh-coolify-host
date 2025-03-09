FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y nginx openssh-server sudo

# Configure SSH for password authentication only
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Create directories for our content
RUN mkdir -p /data/www
RUN mkdir -p /data/images

# Remove ALL default nginx configurations
RUN rm -rf /etc/nginx/sites-available/default
RUN rm -rf /etc/nginx/sites-enabled/default
RUN rm -rf /etc/nginx/conf.d/default.conf
RUN rm -rf /var/www/html/*

# Create our custom configuration directly in the main nginx.conf
RUN echo 'user www-data;\n\
worker_processes auto;\n\
pid /run/nginx.pid;\n\
include /etc/nginx/modules-enabled/*.conf;\n\
\n\
events {\n\
    worker_connections 768;\n\
}\n\
\n\
http {\n\
    sendfile on;\n\
    tcp_nopush on;\n\
    tcp_nodelay on;\n\
    keepalive_timeout 65;\n\
    types_hash_max_size 2048;\n\
    \n\
    include /etc/nginx/mime.types;\n\
    default_type application/octet-stream;\n\
    \n\
    access_log /var/log/nginx/access.log;\n\
    error_log /var/log/nginx/error.log;\n\
    \n\
    server {\n\
        listen 80 default_server;\n\
        listen [::]:80 default_server;\n\
        server_name _;\n\
        \n\
        location / {\n\
            root /data/www;\n\
            index index.html index.htm;\n\
            try_files $uri $uri/ =404;\n\
        }\n\
        \n\
        location /images/ {\n\
            root /data;\n\
            autoindex on;\n\
        }\n\
    }\n\
}' > /etc/nginx/nginx.conf

# Create a sample index.html file to verify configuration
RUN echo '<!DOCTYPE html>\
<html>\
<head>\
    <title>My Custom Nginx Page</title>\
</head>\
<body>\
    <h1>Success! The custom nginx configuration is working.</h1>\
    <p>If you see this message, the static files from /data/www are being served correctly.</p>\
</body>\
</html>' > /data/www/index.html

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]