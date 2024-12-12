# Use an official PHP 5.6 image as the base
FROM php:5.6-apache

# Install necessary dependencies
RUN apt-get update && \
    apt-get install -y \
    software-properties-common \
    curl \
    unzip \
    iptables-persistent \
    && apt-get clean

# Add PHP extensions
RUN docker-php-ext-install \
    mysql \
    curl \
    mcrypt

# Enable mcrypt extension
RUN phpenmod mcrypt

# Add the necessary repository for PHP packages (if needed)
RUN add-apt-repository ppa:ondrej/php && \
    apt-get update

# Download and extract Xtream Codes and IPTV panel
WORKDIR /tmp
RUN wget https://github.com/amin015/xtream-codes-nulled/raw/refs/heads/master/iptv_panel_pro.zip -O /tmp/iptv_panel_pro.zip
RUN wget https://github.com/amin015/xtream-codes-nulled/raw/refs/heads/master/install_iptv_pro.php -O /tmp/install_iptv_pro.php

# Extract the www_dir.tar.gz to the Apache directory
RUN if [ -d /var/www/html ]; then \
        tar -zxvf /tmp/www_dir.tar.gz -C /var/www/html/; \
    else \
        echo "No /var/www/html directory"; \
    fi

# Copy IPTV panel files to the web root directory and install it
RUN unzip /tmp/iptv_panel_pro.zip -d /var/www/html
RUN php /tmp/install_iptv_pro.php

# Configure iptables to redirect specific IP addresses to localhost (127.0.0.1)
RUN echo 1 > /proc/sys/net/ipv4/ip_forward && \
    /sbin/iptables -t nat -I OUTPUT --dest 149.202.206.51/28 -j DNAT --to-destination 127.0.0.1 && \
    /sbin/iptables -t nat -I OUTPUT --dest 123.103.255.80/28 -j DNAT --to-destination 127.0.0.1 && \
    /sbin/iptables -t nat -I OUTPUT --dest 62.210.244.112/28 -j DNAT --to-destination 127.0.0.1 && \
    /sbin/iptables -t nat -I OUTPUT --dest 185.73.239.0/28 -j DNAT --to-destination 127.0.0.1

# Expose necessary ports
EXPOSE 80

# Start the Apache service
CMD ["apache2-foreground"]
