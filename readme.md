# Andreas' blog

[![Build Status](https://anoff.visualstudio.com/anoff.io/_apis/build/status/anoff.blog?branchName=master)](https://anoff.visualstudio.com/anoff.io/_build/latest?definitionId=1&branchName=master)

A dump of [my medium blog posts](https://medium.com/@anoff_io) into ~~Jekyll~~ Hugo and 
some more stuff as well.

Ported to Hugo from Jekyll, last commit in Jekyll style: [aa1376c2d116](https://github.com/anoff/blog/tree/aa1376c2d116d8075ce6ae76a75b1920c35eb6e5) hosted for eternity on [anoff-aa1376c.surge.sh](//anoff-aa1376c.surge.sh/)

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
$ docker run --rm -v $PWD:/app -p 1313:1313 anoff/hugo-asciidoctor hugo server -D --bind 0.0.0.0
```

## Planned deployment

I want to merge this with my personal landing page resulting in the following URL scenarios

- `blog.anoff.io` => overview of all blogposts
- `blog.anoff.io/filename` => specific post
- `anoff.io` => show the about page

## Attribution

Content is my own unless otherwise stated

I am using the [bilberry-hugo-theme](https://github.com/Lednerb/bilberry-hugo-theme)
