FROM ghcr.io/gohugoio/hugo:latest

# Install git for GitInfo and module support
USER root
RUN apk add --no-cache git
USER hugo

WORKDIR /src

