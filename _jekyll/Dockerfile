FROM jekyll/jekyll

WORKDIR /app
COPY Gemfile .
COPY Gemfile.lock .

RUN apk add ttf-dejavu graphviz
RUN bundle install

EXPOSE 4000
CMD ["bundle", "exec", "jekyll", "serve", "--watch", "--host", "0.0.0.0"]
