.DEFAULT_GOAL := help

mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir := $(dir $(mkfile_path))

app_name = optimize_exprev
ecr_repo = 048300154415.dkr.ecr.us-west-2.amazonaws.com

.SECONDEXPANSION:

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-_.]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'

clean:  ## Clean the distro directory
	rm -rf dist/*

setup:  ## Setup the environment
	mkdir -p dist
	mkdir -p build

debug:  ## Debug information
	@echo $(mkfile_dir)
	@echo $(app_name)

venv:  ## Setup python venv
	python3 -m venv venv

ecr-login:
	@docker login -u AWS -p $(shell aws ecr get-login-password --region us-west-2) https://$(ecr_repo)

docker.build:  ## Build the docker image
	docker build --tag $(ecr_repo)/$(app_name) .

docker.push:  ## Push the docker image to the AWS image repository
	make ecr-login
	docker push $(ecr_repo)/$(app_name)

docker.pull:  ## Pull the docker image
	make ecr-login
	docker pull $(ecr_repo)/$(app_name)

docker.run:  ## Run the docker image locally
	@docker stop $(app) 2>/dev/null 1>&2 || true
	@docker rm $(app) 2>/dev/null 1>&2 || true
	@echo "running $(app_name) container (ctrl-c to exit)"
	@docker run \
		--rm \
		-it \
		--name=$(app_name) \
		-p 8080:8080 \
		-e APP_ENV=development \
		-e AWS_ACCESS_KEY_ID=$$AWS_ACCESS_KEY_ID \
		-e AWS_SECRET_ACCESS_KEY=$$AWS_SECRET_ACCESS_KEY \
		-e AWS_REGION=us-west-2 \
		-v $$HOME/.ssh:/root/.ssh \
		-e CTZ_DEV_USERNAME=$$CTZ_DEV_USERNAME \
		-e CTZ_OPEN_SSH_TUNNEL=true \
		$(ecr_repo)/$(app_name)

