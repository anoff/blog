FROM asciidoctor/docker-asciidoctor
LABEL maintainer="offenhaeuser@gmail.com"

ENV HUGO_VERSION 0.50
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz

RUN apk update

# add glibc, see https://github.com/gohugoio/hugo/issues/4961 and https://github.com/sgerrand/alpine-pkg-glibc
RUN apk --no-cache add ca-certificates wget \
&& wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&& wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \
&& apk add glibc-2.29-r0.apk

# get hugo
RUN wget https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
  tar xzf ${HUGO_BINARY} && \
  rm -r ${HUGO_BINARY} && \
  mv hugo /usr/bin && \
  apk del wget ca-certificates

# clean cache
RUN rm /var/cache/apk/*

WORKDIR /app

