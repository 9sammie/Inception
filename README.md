# 42 project: Inception

*This project has been created as part of the 42 curriculum by maballet.*

---

## Description

**Inception** is a system administration project aimed at deepening knowledge about virtualization and containerization. The main goal is to build a complete, secure, and isolated infrastructure composed of multiple Docker containers, all running under a specific network. 

Every service (NGINX, WordPress, MariaDB) runs inside its own dedicated container. To ensure maximum understanding of building environments, the use of pre-made Docker images from Docker Hub is strictly forbidden. Every single container image is built from scratch using custom `Dockerfiles` based on a stable Debian/Alpine OS distribution.

---

## Technical Choices & Conceptual Comparisons

### Virtual Machines vs Docker
*   **Virtual Machines (VMs)**: Hypervisors emulate entire hardware systems. Each VM runs its own full guest operating system, including its own kernel. This provides strong isolation but consumes massive amounts of RAM, CPU, and storage space, leading to slow boot times (like the VirtualBox environment running this project).
*   **Docker Containers**: Containers share the host system's OS kernel and isolate the application processes from each other. They are lightweight, start almost instantly, and consume minimal resources since they do not require an entire guest OS layer.

### Secrets vs Environment Variables
*   **Environment Variables**: Perfect for non-sensitive configuration data (like database names, domain paths such as `maballet.42.fr`, or port numbers). However, they can be easily leaked via process listings (`ps`), logs, or docker inspections.
*   **Secrets**: Designed specifically to store sensitive data (passwords, SSL keys). Secrets are encrypted at rest, transmitted securely, and only injected into the container's in-memory filesystem (`/run/secrets/`) when explicitly required at runtime, preventing hardcoded credentials.

### Docker Network vs Host Network
*   **Host Network**: The container shares the host’s network stack directly. A service on port 443 inside the container binds directly to port 443 of the host. This offers slight performance benefits but provides zero network isolation, risking port conflicts.
*   **Docker Network (Bridge)**: Creates an isolated, private virtual network layer. Containers can securely talk to each other using their container names as hostnames (e.g., WordPress connecting to `mariadb`). External traffic can only reach the containers if ports are explicitly published (`ports:` directive in Docker Compose), ensuring strong network security.

### Docker Volumes vs Bind Mounts
*   **Bind Mounts**: Maps a specific, absolute path from the host machine directly into the container (e.g., syncing a local code folder). It depends heavily on the host’s file system structure and permissions.
*   **Docker Volumes**: Managed entirely by Docker within a dedicated storage area on the host. They are isolated from the host's direct file system structure, safer to share between multiple containers, and highly optimized for database performances (used in this project for `/home/maballet/data`).

---

## Instructions

### Execution Commands
The `Makefile` at the root of the repository automates the entire process:

*   **`make` / `make all`**: Prepares the host storage directories, builds the custom images, and launches the infrastructure in detached mode.
*   **`make down`**: Safely stops and removes the containers without losing persistent data.
*   **`make clean`**: Stops the infrastructure and removes unused Docker images to save space.
*   **`make fclean`**: Performs a full reset. Removes all containers, networks, images, and physically purges the data volumes on the host system (`/home/maballet/data`).

---

## Resources & AI Use Description

### Documentation & References
*	[Overall guide for this project](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)
*   [Docker Documentation](https://docs.docker.com/)
*   [NGINX Server Administration Guide](https://nginx.org/en/docs/)
*   [WordPress Command Line Interface (WP-CLI)](https://wp-cli.org/)
*   [MariaDB Security Best Practices](https://mariadb.com/kb/en/documentation/)

### Use of Artificial Intelligence (AI)
In accordance with academic integrity guidelines, AI assistance was integrated into this project for the following specific tasks:
1.  **Debugging Permissions**: AI was used to resolve complex `403 Forbidden` errors related to Linux ownership mapping (`chown`/`chmod`) between the host file system and the NGINX user inside the Docker container.
2.  **Concept Clarification**: Used to quickly compare core architectural paradigms such as Bind Mounts vs Docker Volumes during the research phase.
3.  **project architecture**: In order to have a global overview of the structure and clear guideline begin with.