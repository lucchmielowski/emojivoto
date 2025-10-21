svc_name := emojivoto-web

all: clean protoc webpack package-web test

include ../common.mk

webpack:
	$(MAKE) -C webapp

package-web: webpack
	mkdir -p $(target_dir)/web
	cp web/favicon.ico $(target_dir)/web
	cp -a webapp/dist $(target_dir)

compile-vote-bot:
	CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) go build -v -o $(target_dir)/emojivoto-vote-bot cmd/vote-bot/main.go

compile-web:
	CGO_ENABLED=0 GOOS=linux GOARCH=$(GOARCH) go build -v -o $(target_dir)/$(svc_name) cmd/server.go

compile: compile-web compile-vote-bot
