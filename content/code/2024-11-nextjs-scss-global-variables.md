---
title: Loading global scss variables in nextjs with sass preprendData
date: 2024-11-15
tags: [web, development]
author: anoff
resizeImages: true
draft: false
---

Recently I started using [next.js](https://nextjs.org/) and slowly diving into lower levels of web design, creating own components, managing complexer styles etc.
One of the things I realized was that I want to use a CSS preprocessor, so I went for [dart sass](https://sass-lang.com/dart-sass/) but sticking to `.scss` as file format.

The one thing that annoyed me - and took me some time to solve - was how to use react with modular styles i.e. `component.module.scss` but having a central `_variables.scss` containing colors, common element widths.
I have seen approaches that require custom loaders or organizing my stylesheets in a certain way.
Finally I found out that dart sass can be configured to append data to every stylesheet before parsing it.

<!--more-->

Let's assume there is a `src/_variables.scss` file 

This is achieved by modifying the next.js config file (`next.config.js`) and define the `sassOptions.prependData` property.


```javascript
const nextConfig = {
  reactStrictMode: true,
  swcMinify: true,
  output: 'standalone',
  sassOptions: {
    includePaths: [
      path.join(__dirname, 'styles'),
      path.join(__dirname, 'node_modules')
    ],
    // ensure the common variables exist in each scss file before parsing
    prependData: `@use './src/style/_variables.scss' as *;`
  },
```

Note that `@use` is preferred over `@import` in recent versions of dart sass.

It is also possible to either globally activate certain sass plugins or import the variables in a name-spaced context.

```javascript
  prependData: `@use 'sass:color';@use './src/_variables.scss' as app;`
```

When loading the files/variables with a namespace, any `.scss` file in your can reference variables as 

```scss
// ./src/_variables.scss, which is imported under 'app' namespace
$main-color: #ff3;


// somefile.scss
.div {
  color: app.$main-color;
}
```

That's all, hope it helped some of you :)
