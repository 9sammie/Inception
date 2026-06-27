FROM debian:bookworm

# rm to empty the cache and lighten the image
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

# auto signed SSL certificate generation 
RUN openssl req -x509 -nodes -days 365 -newkey rsa:4096 \
    -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42Paris/CN=maballet.42.fr/UID=maballet"

COPY ./requirements/nginx/conf/nginx.conf /etc/nginx/conf.d/default.conf

# root folder creation
RUN mkdir -p /var/www/wordpress
RUN chown -R www-data:www-data /var/www/wordpress

EXPOSE 443

# front launch of NGINX
CMD ["nginx", "-g", "daemon off;"]