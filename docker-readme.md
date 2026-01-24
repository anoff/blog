# Docker Build

Start a shell in a container with all dependencies installed:

```sh
docker run --rm -it -v $PWD:/src -p 1313:1313 --entrypoint=sh $(docker build -q .)
```

Inside the container:

```sh
hugo server -D --bind 0.0.0.0
```

Or just build via Docker:

```sh
docker build -t my-blog .
docker run --rm -v $PWD/public:/src/public my-blog
```
