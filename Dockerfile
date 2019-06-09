FROM asciidoctor/docker-asciidoctor
LABEL maintainer="offenhaeuser@gmail.com"

ENV HUGO_VERSION 0.55.6
ENV HUGO_BINARY hugo_extended_${HUGO_VERSION}_Linux-64bit.tar.gz
ENV GLIBC_VERSION 2.29-r0

RUN set -x && \
  apk update && \
  apk add --update wget ca-certificates libstdc++

# add asciidoctor libs
RUN gem install --no-document \
  asciidoctor-html5s \
  asciidoctor-diagram \
  coderay

# add glibc, see https://github.com/gohugoio/hugo/issues/4961 and https://github.com/sgerrand/alpine-pkg-glibc
RUN wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-$GLIBC_VERSION.apk" \
&&  rm "glibc-$GLIBC_VERSION.apk" \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-bin-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-bin-$GLIBC_VERSION.apk" \
&&  rm "glibc-bin-$GLIBC_VERSION.apk" \
&&  wget "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc-i18n-$GLIBC_VERSION.apk" \
&&  apk --no-cache add "glibc-i18n-$GLIBC_VERSION.apk" \
&&  rm "glibc-i18n-$GLIBC_VERSION.apk"


# get hugo
RUN wget -q https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${HUGO_BINARY} && \
  tar xzf ${HUGO_BINARY} && \
  rm -r ${HUGO_BINARY} && \
  mv hugo /usr/bin && \
  apk del wget ca-certificates

# clean cache
RUN rm /var/cache/apk/*

WORKDIR /app

# add asciidoctor hack
COPY asciidoctor /app/asciidoctor
ENV PATH "/app:${PATH}"
