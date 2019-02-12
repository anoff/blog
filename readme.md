# anoff's blog

A dump of [my medium blog posts](https://medium.com/@an0xff) into Jekyll and 
some more stuff as well.

## local preview

The best way to preview the blog locally is to build it using a docker container.

```sh
# build the image locally
docker build -t anoff/blog .

# run jekyll on the local directory
docker run -it -v $PWD:/app -p 4000:4000 anoff/blog
```

to deploy run `surge _site/ blog.anoff.io`

## attribution

Content is my own unless otherwise stated

The original Jekyll theme is by [Dean Attali](https://github.com/daattali/beautiful-jekyll), some files have been modified.
