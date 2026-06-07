FROM debian:13.0

RUN apt-get update && apt-get upgrade -y && apt-get install -y mariadb-server

COPY ./conf/99-server.cnf /etc/mysql/mariadb.conf.d/99-server.cnf

COPY ./tools/mdb-conf.sh /usr/local/bin/mdb-conf.sh

RUN chmod +x /usr/local/bin/mdb-conf.sh

EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mdb-conf.sh"]