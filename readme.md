# Andreas' blog

A dump of [my medium blog posts](https://medium.com/@an0xff) into ~~Jekyll~~ Hugo and 
some more stuff as well.

Ported to Hugo from Jekyll, last commit in Jekyll style: [aa1376c2d116](https://github.com/anoff/blog/tree/aa1376c2d116d8075ce6ae76a75b1920c35eb6e5)

## Fixes to theme

```scss
// themes/bilberry-hugo-theme/assets/sass/_variables.scss
// main colors
$page-background-color: #f1f1f1;
$base-color: #444;
$special-color: #cc0033;
$highlight-color: #cc0033;
$text-color: #111;
```

## Local preview

```sh
PATH=$PWD:$PATH hugo server -D
```

## Deployment

```sh
# generate the static site
PATH=$PWD:$PATH hugo --gc --minify -d _site
# deploy via surge
surge _site/ blog.anoff.io
```

## Attribution

Content is my own unless otherwise stated

I am using the [bilberry-hugo-theme](https://github.com/Lednerb/bilberry-hugo-theme)