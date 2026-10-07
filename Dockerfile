# Minimal Docker image for freebayes using Alpine base
FROM alpine:latest

# install freebayes
RUN apk update && \
    apk add --no-cache bash wget && \
    wget -qO- "https://github.com/freebayes/freebayes/releases/download/v1.3.10/freebayes-1.3.10-linux-amd64-static.gz" | gunzip > /usr/local/bin/freebayes && \
    chmod a+x /usr/local/bin/freebayes
