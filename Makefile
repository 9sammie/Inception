NAME = inception

COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/maballet/data


#------- colors -------#
GREEN = \033[0;32m]
BLUE  = \033[0;34m]
STD = \033[0m]
#----------------------#


all: setup
	@echo "$(BLUE)Lancement des conteneurs Docker...$(STD)"
	@docker compose -f $(COMPOSE_FILE) up -d --build
	@echo "$(GREEN)Inception est opérationnel ! https://maballet.42.fr$(STD)"

setup:
	@echo "$(BLUE)Vérification et création des dossiers de volumes...$(STD)"
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress

down:
	@echo "$(BLUE)Arrêt des conteneurs...$(STD)"
	@docker compose -f $(COMPOSE_FILE) down

clean: down
	@echo "$(BLUE)Nettoyage des images inutilisées...$(STD)"
	@docker system prune -a -f

fclean: down
	@echo "$(BLUE)Nettoyage total (Docker + Volumes physiques)...$(STD)"
	@docker system prune -a --volumes -f
	@sudo rm -rf $(DATA_DIR)/mariadb
	@sudo rm -rf $(DATA_DIR)/wordpress
	@sudo chmod 777 $(DATA_DIR)
	@echo "$(GREEN)Tout a été réinitialisé !$(STD)"

re: fclean all

.PHONY: all setup down clean fclean re