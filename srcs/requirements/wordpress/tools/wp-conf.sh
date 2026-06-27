#!/bin/bash
set -e

# operate in the shared folder
cd /var/www/wordpress

# creating php-fpm folder
mkdir -p /run/php

echo "checking WordPress files..."

# check if wordpress already installed
if [ ! -f "wp-config.php" ]; then

    echo "WordPress not installed. Downloading..."
    # Docker need root power since he exec in root by default
    wp core download --allow-root

    echo "Creating wp-config.php file..."
    # using .env environment variables
    wp config create --allow-root \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    echo "WordPress installation..."
    # website and admin set up 
    wp core install --allow-root \
        --url="${WP_URL}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}"

    echo "secondary user creation..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --allow-root

    echo "WordPress successfully installed !"
else
    echo "WordPress already installed."
fi

echo "launching PHP-FPM 8.2..."

chown -R www-data:www-data /var/www/wordpress

# make it turn in front (php-fpm)
exec php-fpm8.2 -F