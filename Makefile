NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/maballet/data
ENV_FILE= srcs/.env

#------- colors -------#
GREEN = \033[0;32m
BLUE  = \033[0;34m
STD = \033[0m
#----------------------#


all: $(ENV_FILE) setup
	@echo "$(BLUE)Launching...$(STD)"
	@docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Inception is working ! https://maballet.42.fr$(STD)"

$(ENV_FILE):
	@echo "${BLUE}Le fichier $(ENV_FILE) is missing. Creating...${STD}\n"
	@touch $(ENV_FILE)
	@echo "SQL_DATABASE=wordpress" >> $(ENV_FILE);\
	echo "SQL_USER=maballet" >> $(ENV_FILE);\
	read -p "Enter Mariadb user password (SQL_PASSWORD) : " sql_pass;\
	echo "";\
	echo "SQL_PASSWORD=$$sql_pass" >> $(ENV_FILE);\
	read -p "Enter mariadb password ROOT (SQL_ROOT_PASSWORD) : " sql_root_pass;\
	echo "";\
	echo "SQL_ROOT_PASSWORD=$$sql_root_pass" >> $(ENV_FILE);\
	echo "" >> $(ENV_FILE);\
	echo "WP_TITLE=Inception_maballet" >> $(ENV_FILE);\
	echo "WP_URL=maballet.42.fr" >> $(ENV_FILE);\
	echo "WP_ADMIN_USER=admin_maballet" >> $(ENV_FILE);\
	echo "WP_ADMIN_EMAIL=maballet@student.42.fr" >> $(ENV_FILE);\
	read -p "Enter ADMIN Wordpress password (WP_ADMIN_PASSWORD) : " wp_admin_pass;\
	echo "";\
	echo "WP_ADMIN_PASSWORD=$$wp_admin_pass" >> $(ENV_FILE);\
	echo "" >> $(ENV_FILE);\
	echo "WP_USER=tourist" >> $(ENV_FILE);\
	echo "WP_USER_EMAIL=tourist@gmail.com" >> $(ENV_FILE);\
	read -p "Enter secondary USER password (WP_USER_PASSWORD) : " wp_user_pass;\
	echo "";\
	echo "WP_USER_PASSWORD=$$wp_user_pass" >> $(ENV_FILE);\
	echo "${GREEN}Fichier $(ENV_FILE) succesfully generated !${STD}\n";

setup:
	@echo "$(BLUE)volume folder's check and creation...$(STD)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

down:
	@echo "$(BLUE)stopping containers...$(STD)"
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@echo "$(BLUE)unused images cleaning...$(STD)"
	@docker system prune -a -f

fclean: down
	@echo "$(BLUE)Deep cleaning (Docker + Volumes physiques)...$(STD)"
	@docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_DIR)/mariadb
	@sudo rm -rf $(DATA_DIR)/wordpress
	@sudo chmod 777 $(DATA_DIR)
	@rm -f $(ENV_FILE)
	@echo "$(GREEN)everything working again !$(STD)"

re: fclean all

.PHONY: all setup down clean fclean re