DOCKER = docker
IMAGE = hentaiOS-Infrastructure/docker-buildcakes
TAG = $(shell git rev-parse --abbrev-ref HEAD)

build: Dockerfile
	$(DOCKER) build -t $(IMAGE):$(TAG) .

latest: Dockerfile
	$(DOCKER) build -t $(IMAGE):latest .

.PHONY: build
