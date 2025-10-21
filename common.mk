IMAGE_TAG ?= latest

.PHONY: clean protoc compile test build-container build-multi-arch

target_dir := target

clean:
	rm -rf gen $(target_dir)
	mkdir -p $(target_dir) gen

protoc:
	../bin/protoc -I .. ../proto/*.proto \
		--go_out=paths=source_relative:./gen \
		--go-grpc_out=paths=source_relative:./gen

compile: protoc
	CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) go build -v -o $(target_dir)/$(svc_name) cmd/server.go

test:
	go test ./...

build-container:
	docker build .. -t "ghcr.io/lucchmielowski/$(svc_name):$(IMAGE_TAG)" \
		--build-arg svc_name=$(svc_name)

build-multi-arch:
	docker buildx build .. -t "ghcr.io/lucchmielowski/$(svc_name):$(IMAGE_TAG)" \
		--build-arg svc_name=$(svc_name) \
		--platform linux/amd64,linux/arm64,linux/arm/v7 --push

# Default all target that can be overridden by individual services
all: clean protoc compile test