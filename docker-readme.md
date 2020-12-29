# A hugo image with asciidoctor compatibility

For my blog I built a docker image that allows building a hugo site with asciidoctor content. There are a few [hacks](https://blog.anoff.io/2019-02-17-hugo-render-asciidoc/) I needed that are also baked into this image.

Make sure git submodules are initialized `git submodule update --init`

To write/live preview the content start hugo in dev mode and open [localhost:1313](http://localhost:1313)

```sh
$ docker run --rm -v $PWD:/app -p 1313:1313 anoff/hugo-asciidoctor hugo server -D --bind 0.0.0.0
```

To build your site:

```sh
$ docker run --rm -v $PWD:/app anoff/hugo-asciidoctor hugo --gc --minify -d _site
```
