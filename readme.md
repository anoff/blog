# Andreas' blog

[![build status](https://github.com/anoff/blog/workflows/deploy%20to%20gh-pages/badge.svg?branch=master)](https://github.com/anoff/blog/actions?query=workflow%3A%22deploy+to+gh-pages%22&branch=master)

Some thoughts and lessons I write down so that I can look them up later - and maybe help others along the way.

# TODO:
- fix google analytics
- review all converted adoc -> md
- rework all plantuml to mermaidjs
- fix release pipeline

## Customizations

Theme overrides are located in the `assets/` directory.

## Local preview

```sh
$ ./dev.sh
```
or
```sh
$ hugo server -D
```

## Planned development

I want to merge this with my personal landing page resulting in the following URL scenarios

- `blog.anoff.io` => overview of all blogposts
- `blog.anoff.io/filename` => specific post
- `anoff.io` => show the about page

## Attribution

Content is my own unless otherwise stated

I am using the [bilberry-hugo-theme](https://github.com/Lednerb/bilberry-hugo-theme)

## Version history

- 2018-01: started out on [medium](https://medium.com/@anoff_io)
- 2018-07: Migrated to selfhosted solution using Jekyll
- 2019-02: Ported to Hugo, last commit in Jekyll style: [aa1376c2d116](https://github.com/anoff/blog/tree/aa1376c2d116d8075ce6ae76a75b1920c35eb6e5) hosted for eternity(?) on [anoff-aa1376c.surge.sh](//anoff-aa1376c.surge.sh/)
- 2026-01: Migrated to Hugo with markdown only
