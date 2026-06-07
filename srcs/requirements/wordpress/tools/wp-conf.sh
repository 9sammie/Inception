sleep 5

# creating a folder for wordpress files
mkdir -p /var/www/html
cd /var/www/html

# downloading wp-cli to install wordpress
if [ ! -f /usr/local/bin/wp ]; then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
fi

# installing wordpress
if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root

	# creating wp-config.php file with variable env
    wp config create \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306" \
        --allow-root

	# installing wordpress and conf the website and the admin account
    wp core install \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --allow-root
fi

# create php exec folder
mkdir -p /run/php

# Run php-fpm in front (required so the container doesn't stop)
echo "WordPress initialisé avec succès et PHP-FPM démarre !"
exec /usr/sbin/php-fpm* -F