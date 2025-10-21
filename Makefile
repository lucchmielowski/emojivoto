include ./common.mk

.PHONY: all build push clean

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

# Clean all build artifacts
clean:
	$(MAKE) -C emojivoto-web clean
	$(MAKE) -C emojivoto-emoji-svc clean
	$(MAKE) -C emojivoto-voting-svc clean

# Local development with docker-compose
dev:
	docker-compose up --build

# Deploy to local kubernetes
deploy:
	kubectl apply -f kustomize/deployment/

# Run tests
test:
	$(MAKE) -C emojivoto-web test
	$(MAKE) -C emojivoto-emoji-svc test
	$(MAKE) -C emojivoto-voting-svc test