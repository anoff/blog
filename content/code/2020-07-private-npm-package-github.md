---
title: Publishing private npm packages to GitHub Package registry for free
date: 2020-07-26
tags: [web, development, github]
author: anoff
resizeImages: true
draft: false
featuredImage: /assets/github-npm/title.png
---

Even though I am a big fan of Open Source Software and try to make my projects open and consumable by others as well, there are cases where you want to keep your stuff private.
But even if you work in a closed source environment you still want to use the same tools that you employ in the open source world.
In this blog post I will explain how you can create private npm packages for your Javascript/Typescript projects - and I will show you how you can host your private npm packages **for free**!

<!--more-->

<!-- TOC depthFrom:2 -->

- [Introduction to GitHub Packages](#introduction-to-github-packages)
  - [Pricing 💰](#pricing-)
- [Using GitHub Packages](#using-github-packages)
- [Publishing private packages](#publishing-private-packages)
- [Consuming private packages in GitHub Actions](#consuming-private-packages-in-github-actions)

<!-- /TOC -->

## Introduction to GitHub Packages

A few months ago GitHub made their [package registry](https://github.com/features/packages) globally available to every user.
It offers not only a registry for npm packages but also supports many other tools and programming languages like Docker, Maven, NuGet, RubyGems.
You can use GitHub packages with the same tools you are used to - npm, yarn and a `package.json` for specifying your package dependencies.

### Pricing 💰

One advantage of GitHub Packages is that it allows you to publish private packages **for free**.
If you want to publish private packages on npmjs you need to pay at least $7 / month.
GitHub Packages has a fair use policy where you can create public and private packages for free for the first 500MB of package data an and 1GB traffic per month.

## Using GitHub Packages

By default your local tools will access the npmjs registry located at https://registry.npmjs.org/.
That means all requests to install or publish packages will be sent there.

![npm uses npmjs registry by default](/assets/github-npm/npm-default.png)

To use GitHub Packages you need to configure your npm (or yarn) to use the GitHub Packages URL.
The npm registry for GitHub Packages is https://npm.pkg.github.com.
For packages that are not available on GitHub Packages the service will automatically proxy all requests to the npmjs registry.
This might make the installation a little bit slower but it means you don't have to decide between GitHub Packages OR npmjs.

![use GitHub Packages registry](/assets/github-npm/npm-github.png)

GitHub Packages **requires user authentication** not only for publishing but also for installing packages.
This is different from the npmjs registry that allows anonymous read access.

So you first need to provide `npm` with an authentication token.
To do this you need to modify your local [npm configuration](https://docs.npmjs.com/configuring-npm/npmrc.html) that is located in the `.npmrc` file.
If you want to change the behavior only for a single project the file should be located in the project directory `/path/to/project/.npmrc`.
Once you decide you want to use GitHub Packages as default for all your projects it makes sense to modify your user configuration located in the home directory `~/.npmrc`.

The `.npmrc` file needs to contain the following line to use GitHub Packages:

```sh
//npm.pkg.github.com/:_authToken=<PERSONAL ACCESS TOKEN WITH read:packages SCOPE>
```

The Personal Access Token can be generated in the [GitHub Developer Settings](https://github.com/settings/tokens)

![GitHub PAT overview](/assets/github-npm/ss-tokens.png)

![GitHub PAT Creation](/assets/github-npm/ss-token-gen.png)

Make sure to give at least the `read:packages` scope, and also the `write:packages` and `delete:packages` if you plan on publishing packages as well.

## Publishing private packages

Any package that is published from a private repo also becomes a private package.
This is currently the only way to define the visibility of the package but I also think it makes sense to couple this.
So what you need to do is make sure the repository where you publish this package from is set to private.

![Private repo creates a private package](/assets/github-npm/public-private.png)

As a final step you need to configure your package configuration to also publish to GitHub Packages.

You do this by adding the following entry to your package definition

```javascript
  "publishConfig": {
    "registry": "https://npm.pkg.github.com/"
  },
```

You also need to make sure your npm package is scoped to your organization or username, you do this by adding `@SCOPE/` to your package name

```javascript
  "name": "@anoff/my-private-package",
```

## Consuming private packages in GitHub Actions

If you want to consume private packages hosted on GitHub Packages you need to provide an authentication token as you also did for your local environment.
I highly recommend to create a separate token for use in any CI environment.
In the GitHub Actions workflow you can add the authentication by adding this step, the secret `PACKAGE_TOKEN` needs to be added manually by you and should have the `read:packages` scope.

```yaml
- run: echo "//npm.pkg.github.com/:_authToken=${{ secrets.PACKAGE_TOKEN }}" >> .npmrc
  name: add auth token for npm packages
```

I hope this post helped you out and I would love to hear your thoughts in the comments or via [Twitter](https://twitter.com/anoff_io) 👋
