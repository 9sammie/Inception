# Inception - User guide

## Prerequisites

Before launching the project, ensure your host system has:
* Docker (v20.10+) & Docker Compose installed.
* Make utility installed.
* Add `127.0.0.1 maballet.42.fr` to your local `/etc/hosts` file.

## Managing the Stack (Start & Stop)

Use the command `make` and wait for all the servicies to be up.

### 1. Start the project

To build images, create networks/volumes, and launch all services in the background, run `make`.

_Note: The first launch might take a few minutes as it downloads base images, sets up WordPress, and initializes the database._

### 2. Stop the project

To safely stop and shut down all active containers without deleting persistent data use `make down`.

### 3. Deep clean (Reset)

To stop the containers and completely wipe out all data, configurations, and persistent volumes (useful for a fresh installation test) use `make fclean`.

## Locating and managing Credencials

All sensitive information, including database names, usernames, and passwords, is kept out of Git.

* Environment Variables: Stored in `srcs/.env` (ignored by Git).
* Secrets: Stored in the local `secrets/` directory (ignored by Git).
	* `secrets/db_password.txt` — Password for the WordPress database user.
	* `secrets/db_root_password.txt` — Root password for MariaDB.
	* `secrets/credentials.txt` — WordPress admin credentials.

To change a password, modify the corresponding file in `secrets/` or variable in `srcs/.env` and recreate the stack using `make re`.

## Accessing the Site

Once the stack is up and running, you can open your browser and navigate to:

*   **Main Website**: `https://maballet.42.fr`
*   **Admin Dashboard**: `https://maballet.42.fr/wp-login.php`

## Checking Services Health

You can verify that your services are running properly using these diagnostics:

### 1. Check Containers Status
Run this inside `srcs/` folder: `docker compose ps`.

_All containers (nginx, wordpress, mariadb) must display the status Up (e.g., Up 5 minutes)._

### 2. Monitor Live Logs
To see real-time output and debug issues (useful to check database connections or PHP executions), run `docker compose logs -f`.

### 3. Test TLS Connection
Verify Nginx is correctly serving HTTPS via TLSv1.2/TLSv1.3 with `echo | openssl s_client -connect maballet.42.fr:443 2>/dev/null | grep -i protocol`.

_It should display either Protocol: TLSv1.2 or Protocol: TLSv1.3._