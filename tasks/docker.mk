service ?=
user ?= root

docker/shell: ## Starts a shell session in the Apline container
	docker-compose exec $(service) login -f $(user) -p

docker/up: ## Start Docker containers
	docker-compose up --detach --remove-orphans --renew-anon-volumes $(service)

docker/up/build: ## Re-build and Start Docker containers
	docker-compose up --detach --build --force-recreate --remove-orphans --renew-anon-volumes $(service)

docker/build:
	docker-compose build --no-cache --force-rm --pull $(service)

docker/build/up: docker/build docker/up ## Re-build and Start Docker containers

docker/down: ## Stop and remove Docker containers
	docker-compose down --remove-orphans

docker/logs: ## View output from docker containers
	docker-compose logs --follow $(service)

docker/images: ## Show all docker images
	docker images --all \
		| grep --invert-match "<none>" \
			| sort

docker/system/prune: ## Remove all unused Docker images and volumes
	docker system prune --force --all --volumes

docker/system/storage: ## Show Docker storage info
	docker system df
