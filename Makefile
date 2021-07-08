.PHONY: up
up:
	docker-compose up -d
	docker-compose run --rm composer install --no-interaction
	docker-compose run --rm php bin/console doctrine:schema:update --force
	@echo "\e[30m\e[42m\n"
	@echo " Application is up and running at http://localhost:8080"
	@echo "\e[49m\e[39m\n"

.PHONY: setup
setup:
	git config submodule.recurse true
	git submodule init
	git submodule update
