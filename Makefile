include ./common.mk

.PHONY: all build push clean docker-build docker-build-all docker-push docker-push-all docker-web docker-emoji docker-voting help test dev deploy

# Build all services
all: build

build:
	$(MAKE) -C emojivoto-web
	$(MAKE) -C emojivoto-emoji-svc
	$(MAKE) -C emojivoto-voting-svc

# Build multi-arch containers and push
push:
	$(MAKE) -C emojivoto-web build-multi-arch
	$(MAKE) -C emojivoto-emoji-svc build-multi-arch
	$(MAKE) -C emojivoto-voting-svc build-multi-arch

# Build Docker images locally (single architecture)
docker-build:
	$(MAKE) -C emojivoto-web build-container
	$(MAKE) -C emojivoto-emoji-svc build-container
	$(MAKE) -C emojivoto-voting-svc build-container

# Build all Docker images (alias for docker-build)
docker-build-all: docker-build

# Push Docker images to registry
docker-push:
	$(MAKE) -C emojivoto-web build-multi-arch
	$(MAKE) -C emojivoto-emoji-svc build-multi-arch
	$(MAKE) -C emojivoto-voting-svc build-multi-arch

# Push all Docker images (alias for docker-push)
docker-push-all: docker-push

# Clean all build artifacts
clean:
	$(MAKE) -C emojivoto-web clean
	$(MAKE) -C emojivoto-emoji-svc clean
	$(MAKE) -C emojivoto-voting-svc clean

# Local development with docker-compose
dev:
	docker-compose up --build

# Kind: load Docker images into kind cluster nodes (requires kind installed)
.PHONY: kind-image-load

kind-image-load:
	@echo "Loading images into kind cluster nodes..."
	kind load docker-image ghcr.io/lucchmielowski/emojivoto-web:$(IMAGE_TAG)
	kind load docker-image ghcr.io/lucchmielowski/emojivoto-emoji-svc:$(IMAGE_TAG)
	kind load docker-image ghcr.io/lucchmielowski/emojivoto-voting-svc:$(IMAGE_TAG)
	@echo "✅ Images loaded into kind cluster."


# Deploy to local kubernetes
deploy:
	kubectl apply -k kustomize/deployment/

# Run tests
test:
	$(MAKE) -C emojivoto-web test
	$(MAKE) -C emojivoto-emoji-svc test
	$(MAKE) -C emojivoto-voting-svc test

# Build individual service Docker images
docker-web:
	$(MAKE) -C emojivoto-web build-container

docker-emoji:
	$(MAKE) -C emojivoto-emoji-svc build-container

docker-voting:
	$(MAKE) -C emojivoto-voting-svc build-container

# Help target
help:
	@echo "Available targets:"
	@echo "  build           - Build all services locally"
	@echo "  test            - Run tests for all services"
	@echo "  clean           - Clean all build artifacts"
	@echo "  docker-build    - Build Docker images locally (single arch)"
	@echo "  docker-web      - Build web service Docker image"
	@echo "  docker-emoji    - Build emoji service Docker image"
	@echo "  docker-voting   - Build voting service Docker image"
	@echo "  docker-push     - Build and push multi-arch images to registry"
	@echo "  dev             - Start with docker-compose"
	@echo "  deploy          - Deploy to local kubernetes"
	@echo "  push            - Alias for docker-push"