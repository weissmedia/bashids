MAKEFLAGS += --warn-undefined-variables --no-print-directory
.SHELLFLAGS := -eu -o pipefail -c

all: help
.PHONY: all

# Use bash for inline if-statements
SHELL:=bash

# Artifact settings
export APP_NAME=hashid-bashids
export OWNER?=$(DOCKER_OWNER)
export DOCKER_REPOSITORY?=$(DOCKER_REPOSITORY=)

# Enable BuildKit for Docker build
export DOCKER_BUILDKIT:=1
export BUILDKIT_INLINE_CACHE:=1
export COMPOSE_DOCKER_CLI_BUILD:=1
export DOCKER_DEFAULT_PLATFORM:=linux/amd64

##@ Helpers
help: ## display this help
	@echo "$(APP_NAME)"
	@echo "====================="
	@awk 'BEGIN {FS = ":.*##"; printf "\033[36m\033[0m"} /^[a-zA-Z0-9_%\/-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@printf "\n"

docker-login: DOCKER_LOGIN_CREDENTIALS?=
docker-login: ## auto login to docker repository
	docker login $(DOCKER_LOGIN_CREDENTIALS) $(DOCKER_REPOSITORY)

##@ Containerizing
build-compose: DARGS?=--load
build-compose: ## build the image for the system architecture
	docker buildx bake --no-cache $(DARGS) --set *.platform=$(DOCKER_DEFAULT_PLATFORM)

push-compose: ## push the multi image with all tags
	$(MAKE) build-compose DARGS=--push

test:
	docker run -it $(DOCKER_REPOSITORY)/$(OWNER)/$(APP_NAME) bashids -e -s "this is my salt" 1 2 3