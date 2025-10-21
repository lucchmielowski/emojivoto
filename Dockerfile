ARG svc_name=emojivoto-emoji-svc

# Build stage
FROM --platform=$BUILDPLATFORM golang:1.25-alpine AS builder
WORKDIR /build

# Install build tools
RUN apk add --no-cache protobuf-dev protoc build-base git make
RUN go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.31.0
RUN go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.3.0

# Copy dependencies first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy source and build
COPY . .
ARG TARGETARCH
ARG svc_name
RUN export GOARCH=$TARGETARCH && make -C $svc_name clean protoc compile

# Webpack stage for web service only
FROM --platform=$BUILDPLATFORM node:20-alpine AS webpack
WORKDIR /build
RUN apk add --no-cache make
COPY . .
RUN make -C emojivoto-web clean webpack package-web

# Runtime stage
FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl dnsutils iptables jq nghttp2 && rm -rf /var/lib/apt/lists/*

ARG svc_name

# Copy the built binary
COPY --from=builder /build/$svc_name/target/ /usr/local/bin/

# For web service, also copy webpack assets
COPY --from=webpack /build/emojivoto-web/target/ /usr/local/bin/

ARG svc_name
WORKDIR /usr/local/bin
ENV SVC_NAME=$svc_name
ENTRYPOINT ["/bin/sh", "-c", "exec \"/usr/local/bin/$SVC_NAME\" \"$@\""]
