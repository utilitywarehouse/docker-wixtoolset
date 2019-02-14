VERSION=3.11.1

DOCKER_REGISTRY=quay.io
DOCKER_CONTAINER_NAME=wixtools
NAMESPACE=utilitywarehouse
DOCKER_REPOSITORY=$(DOCKER_REGISTRY)/$(NAMESPACE)/$(DOCKER_CONTAINER_NAME)

docker-image:
	docker build -t $(DOCKER_CONTAINER_NAME) .

ci-docker-auth:
	@echo "Logging in to $(DOCKER_REGISTRY) as $(DOCKER_ID)"
	@docker login -u $(DOCKER_ID) -p $(DOCKER_PASSWORD) $(DOCKER_REGISTRY)

ci-docker-build: ci-docker-auth
	docker build -t $(DOCKER_REPOSITORY):$(CIRCLE_SHA1) .
	docker tag $(DOCKER_REPOSITORY):$(CIRCLE_SHA1) $(DOCKER_REPOSITORY):latest
	docker tag $(DOCKER_REPOSITORY):$(CIRCLE_SHA1) $(DOCKER_REPOSITORY):$(VERSION)
	docker push $(DOCKER_REPOSITORY)
	docker push $(DOCKER_REPOSITORY):$(VERSION)
