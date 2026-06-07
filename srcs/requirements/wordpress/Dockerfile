FROM debian:13.0

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    php-fpm \
    php-mysql \
    curl \
    mariadb-client

# COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# conf fig installing wordpress
# COPY ./tools/wp-conf.sh /usr/local/bin/wp-conf.sh
# RUN chmod +x /usr/local/bin/wp-conf.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wp-conf.sh"]