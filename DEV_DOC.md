# Inception - Developer & Architecture Documentation

This document is intended for developers and system administrators who want to understand, maintain, debug, or extend the Inception infrastructure.

## Project Directory Structure
The project follows a strict structure, separating the build configurations, runtime scripts, and environmental variables.

	.
	├── docker-compose.yml
	└── requirements
	    ├── mariadb
	    │   ├── conf
	    │   │   └── 99-server.cnf
	    │   ├── Dockerfile
	    │   └── tools
	    │       └── mdb-conf.sh
	    ├── nginx
	    │   ├── conf
	    │   │   └── nginx.conf
	    │   └── Dockerfile
	    └── wordpress
	        ├── conf
	        │   └── www.conf
	        ├── Dockerfile
	        └── tools
	            └── wp-conf.sh

## Network Architecture & Security

The infrastructure utilizes a dedicated, driver-isolated network named inception_net (configured as a bridge network).

Only NGINX has its ports exposed to the host system. This ensures a strict DMZ (Demilitarized Zone) setup:

				+-----------------------------------------+
            	|               Docker Host               |
            	|                                         |
	  HTTPS    	|   +-------------+                       |
	(Port 443) ---> |    NGINX    |                       |
            	|   +------+------+                       |
            	|          |                              |
            	|          | PHP-FPM FastCGI (Port 9000)  |
            	|          v                              |
            	|   +-------------+                       |
            	|   |  WordPress  |                       |
            	|   +------+------+                       |
            	|       |                                 |
            	|       | MariaDB Connection (Port 3306)  |
            	|       v                                 |
            	|   +-------------+                       |
            	|   |   MariaDB   |                       |
            	|   +-------------+                       |
            	|                                         |
            	+-----------------------------------------+

### Key Security Policies Implemented:

* Port Isolation: MariaDB (3306) and WordPress (9000) are not mapped to any host ports. They are reachable only internally within the inception_net bridge.

* TLS Enforce: NGINX is configured to reject any unencrypted HTTP traffic, strictly using TLSv1.2 or TLSv1.3 with secure ciphers.

## Services Deep Dive

All images are built locally starting from `debian:bookworm` (Debian 12) for consistency, security, and compliance with the subject rules.

### 1. NGINX Container
* Role: Reverse proxy & SSL termination.

* Configuration Highlights:

	* Self-signed SSL certificates are generated during the build process using openssl.

	* The configuration in nginx.conf handles routing for static files and redirects .php requests to the wordpress container via fastcgi_pass wordpress:9000.

	* Daemon Mode: Set to daemon off; so NGINX runs as PID 1, preventing the container from shutting down.

### 2. WordPress & PHP-FPM Container
* Role: PHP processing engine and WP engine.

* Mechanism:

	* Instead of Apache, we use PHP-FPM to handle PHP scripts efficiently.

	* www.conf is modified to listen on 0.0.0.0:9000 instead of a local socket (127.0.0.1), allowing NGINX to reach it.

	* WP-CLI: Downloaded during build and run as root when administering but manages files using the www-data system user.

### 3. MariaDB Container
* Role: SQL Database.

* Configuration Highlights:

	* 50-server.cnf is modified: bind-address is changed from 127.0.0.1 to 0.0.0.0 to listen to external queries coming from the WordPress container.

## Understanding the Initialization Scripts (Entrypoints)
Because Docker containers should not run multiple background services, our entrypoint scripts handle bootstrap processes dynamically before transferring PID 1 to the main service.

### MariaDB Bootstrap (`mdb-conf.sh`)
Since MariaDB needs to be running to execute SQL setup commands (CREATE DATABASE, etc.), but must run in the foreground at the end:

1. It checks if the database files exist in /var/lib/mysql.

2. If empty, it runs mysql_install_db to setup basic system tables.

3. It launches a temporary MariaDB instance in the background with --skip-networking (to allow safe, password-less local execution).

4. It injects SQL commands to create the WP database, the WP database user, and secures the root account.

5. It safely shuts down the temporary server.

6. It uses exec mariadbd to replace the shell process with the official MariaDB daemon running in the foreground as PID 1.

### WordPress Bootstrap (`wp-conf.sh`)
WordPress files are downloaded and configured at runtime to support Docker volumes properly:

1. It checks if wp-config.php already exists (to avoid overwriting existing installations).

2. If not, it runs wp core download to download the code.

3. It runs wp config create using variables passed from .env.

4. It runs wp core install to automatically setup the admin user and general website parameters.

5. It configures a secondary, non-administrator user.

6. It fixes file ownership (chown -R www-data:www-data).

7. It replaces itself with PHP-FPM using exec php-fpm8.2 -F.

## Developer Toolbox: Troubleshooting & Debugging
Here are the most useful commands during development:

### 1. Accessing a Container Shell
To inspect the internal filesystem of a running container:

	docker exec -it <container_name> sh
	# Example:
	docker exec -it wordpress sh

### 2. Inspecting the Bridge Network
To verify which containers are connected to the custom network and their local IP addresses:

	docker network inspect srcs_inception_net

### 3. Inspecting Volume Bindings
To verify exactly where Docker is writing the database files on your VM:

	docker volume inspect srcs_mariadb_data

### 4. Rebuilding a single service
To modify a configuration file (like nginx.conf) and rebuild only that specific image without tearing down the entire stack:

	docker compose up -d --build nginx