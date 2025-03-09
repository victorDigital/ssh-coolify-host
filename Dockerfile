FROM ubuntu:latest

# Install necessary packages, including sudo
RUN apt-get update && apt-get install -y nginx openssh-server sudo

# Configure SSH for password authentication only
RUN echo "PubkeyAuthentication no" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Generate SSH host keys
RUN ssh-keygen -A

# Set up a basic Nginx configuration
RUN rm -f /etc/nginx/conf.d/default.conf

# Get form environment variable
ENV DEPLOYER_USERNAME=${DEPLOYER_USERNAME}
RUN echo 'server { listen 80; root /home/'${DEPLOYER_USERNAME}'/web; index index.html; }' > /etc/nginx/conf.d/default.conf

# Copy the startup script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Set the startup command
CMD ["/start.sh"]