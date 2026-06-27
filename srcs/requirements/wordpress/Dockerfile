FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    php-mysql \
	php-gd \
    wget \
    mariadb-client

# upload WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# have executable file in binary system
RUN chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# config installing wordpress
COPY ./requirements/wordpress/conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./requirements/wordpress/tools/wp-conf.sh /usr/local/bin/wp-conf.sh
RUN chmod +x /usr/local/bin/wp-conf.sh

# going in the website folder
WORKDIR /var/www/html

EXPOSE 9000

RUN mkdir -p /run/php && chown -R www-data:www-data /run/php

RUN chown -R www-data:www-data /var/www/html

RUN sed -i 's|error_log = .*|error_log = /proc/self/fd/2|g' /etc/php/8.2/fpm/php-fpm.conf

USER www-data

ENTRYPOINT ["/usr/local/bin/wp-conf.sh"]