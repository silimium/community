.PHONY: up
up:
	docker-compose up -d
	docker-compose run --rm php bin/console doctrine:schema:update --force
	@echo -e "\e[30m\e[42m\n"
	@echo -e " Application is up and running at http://localhost:8080"
	@echo -e "\e[49m\e[39m\n"

.PHONY: setup
setup:
	git config submodule.recurse true
	git submodule init
	git submodule update
