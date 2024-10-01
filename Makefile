CONTAINERS := mariadb wordpress nginx

YML_PATH = ./srcs/docker-compose.yml

VOL_DIR := /home/iortega/data

VOLUMES := mariadb wordpress

VOLUME = $(addprefix $(VOL_DIR)/,$(VOLUMES))

RM = rm -rf

# Leer el archivo .env
include srcs/.env

# Lista de nombres de administrador prohibidos
FORBIDDEN_USERS := admin Admin administrator Administrator

# Función para verificar si ADMIN_USER está en FORBIDDEN_USERS
define check_admin_user
	$(foreach forbidden,$(FORBIDDEN_USERS),\
		$(if $(findstring $(forbidden),$(ADMIN_USER)),\
			$(error "ADMIN_USER contiene un valor no permitido: $(ADMIN_USER)")))
endef

run: $(VOLUME)
	$(call check_admin_user)
	sudo docker compose -f $(YML_PATH) up --build --remove-orphans

dt: $(VOLUME)
	$(call check_admin_user)
	sudo docker compose -f $(YML_PATH) up --build -d --remove-orphans

down:
	sudo docker compose -f $(YML_PATH) down 

re:
	$(RM) $(VOL_DIR)
	make

clean:
	sudo docker compose -f $(YML_PATH) down -v --remove-orphans --rmi all
	sudo rm -rf $(VOL_DIR)

$(VOLUME):
	mkdir -p $(VOLUME) 2>/dev/null

exec-%:
	sudo docker compose -f $(YML_PATH) exec $* sh

$(foreach CONTAINER,$(CONTAINERS),$(eval $(CONTAINER): exec-$(CONTAINER)))
