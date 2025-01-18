---
title: Continuous Vitae - Auto built and git versioned CV
date: 2019-04-08
tags: [recruiting, CI/CD, drone, docker]
author: anoff
draft: false
featuredImage: /assets/continuous-cv/logo.png
---

Versioning your CV is important. 
One traditional approach is to date it whenever you send it out.
I chose to present my CV on my [website](https://anoff.io) and host it on GitHub.
In this blog post I want to explain how I set up continuous integration pipeline for building my CV that automatically injects a unique version into each build.
This method is applicable for anyone choosing to ascii-based CV - in my case LaTeX.
You also need some basic knowledge of `git`, `Docker` and CI services like `Drone`.

## The Starting point

My CV is presented on a statically generated web page.
I recently changed this page to use [Hugo](/2019-02-17-hugo-render-asciidoc) for rendering.
Before automating the CV I built it locally using a `Makefile` and commit the generated PDF file into `git` repository as artifact.

**Makefile**

```make
.PHONY: pdf inject-git-version verify-git-clean clean commit
COMMIT_SHA := $(shell git rev-parse --short=8 HEAD) ①
FILE_TEX := ./cv-anoff.tex# latex filename

verify-git-clean:
	git diff-index --quiet HEAD ②
inject-git-version:
	sed -i.bak 's/\({git:\)[[:alnum:]]*\(}\)/\1${COMMIT_SHA}\2/' ${FILE_TEX} ③
pdf:
	docker run -v ${CURDIR}:/doc/ -t -i thomasweise/texlive lualatex.sh ${FILE_TEX} ④
clean:
	mv ${FILE_TEX}.bak ${FILE_TEX}
commit:
	git commit -am ":construction_worker: build: CV update"
build: verify-git-clean inject-git-version pdf clean commit
```
1. Get the first 8 character of the current git revision e.g. 11187f1
2. Make sure there are no uncommitted changes in the directory
3. Replace the placeholder in the `.tex` file with the git revision
4. Run the LaTeX pdf generation via Docker

The placeholder in the LaTeX file is `{git:COMMITID}`.
To make sure the replace operation matches only this one place I also added the surrounding curly braces to the matching string.
If your LaTeX file has a different setup you may need to modify the regular expression in the `Makefile`.

**cv-anoff.tex**

```latex
\begin{document}

\header{andreas}{of\/fenhaeuser}{software engineer/architect}{git:COMMITID}
```

Finally rendered you will see something like this

**git SHA as CV version**

![git SHA in PDF](/assets/continuous-cv/git-version.png)

The complete workflow to update the CV:

**Manual CV generation**

![Manual CV Generation](/assets/continuous-cv/manual-generation.svg)

## The Issues

There are a number of things that I did not like about my old setup:

**Annoyances to get rid off**

1. need to commit twice to make a change
2. artifacts are checked into `git`

But also some things I really like about it:

**Features to keep**

1. PDF can be previewed locally
2. exact version of a CV can easily be viewed on GitHub

## The Goal

Given the pros and cons I was aiming for a workflow that generates artifacts on the server but allows me to preview them locally as much as possible.
My ideal workflow for the web hosted CV is the following:

**Continuous Vitae generation**

![Automated CV Generation](/assets/continuous-cv/automated-generation.svg)

## The Solution

As with all my latest projects [drone](http://drone.io/) is the continuous integration service of choice.
The main challenge is to split the `Makefile` up into individual drone [pipeline steps](https://docs.drone.io/user-guide/pipeline/steps/).

### Get the git commit as CV version

With the old workflow the CV version is only updated whenever I ran the `Makefile` and take the current git commit SHA as a version.
Using a continuous build approach this would be run for each commit.
As the CV is versioned & built within my website this would result in a new CV version even if the CV was not updated.
Therefore the current way to get a version needs to be changed.

```bash
# OLD: using the current HEAD revision of the repo
git diff-index --quiet HEAD

# NEW: HEAD revision of a specific file
git rev-list --abbrev-commit -1 HEAD cv-anoff.tex
```

### Drone CI Config

This tutorial will not cover how to set up drone, there are plenty of articles out there for that.
The drone config file covers only on the CV specific steps:

1. get the commit ID of the latest CV version
2. inject commit ID as version into the CV
3. build the CV using docker LaTeX container

Things that you might want to do after these steps are creating your static site using Hugo/Jekyll/Gatsby.. and publishing it via zeit/surge/gh-pages.. So many options 🤯

**📌 NOTE**\
This is written with drone 1.0 syntax

**Drone steps for versioned CV PDF generation**

```yaml
kind: pipeline
name: deploy

steps:
- name: fetch-version
  image: alpine/git
  commands:
  - git rev-list --abbrev-commit -1 HEAD cv-anoff.tex > .COMMIT_SHA

- name: build-cv
  image: thomasweise/texlive
  commands:
  - export COMMIT_SHA=$(cat .COMMIT_SHA)
  - sed -i.bak "s/\({git:\)[[:alnum:]]*\(}\)/\1"$COMMIT_SHA"\2/" cv-anoff.tex
  - lualatex.sh cv-anoff.tex || echo "Ignoring original.pdf error"<1>
  - mv cv-anoff.tex.bak cv-anoff.tex
```
1. The build currently tries to manipulate a file that does not exist as part of a post-processing routine and fails; however the expected output exists so the `luatex` command may fail in this case

Note that the steps from the original `Makefile` are not just executed sequentially in a single step.
That is mainly due to the fact that the _thomasweise/texlive_ Docker image does not include `git`.
Instead of creating yet another docker image with all the dependencies needed (don’t be that person please) we can instead create a sequential build and separate those concerns.

The first step _fetch-version_ executes the git command to get the correct SHA.
This is stored in a temporary file to be passed into the next pipeline step.
The _build-cv_ step uses `sed` to replace the version placeholder with the commit SHA and execute the PDF build using `luatex`.

The PDF is placed next to the input so it is best to place the `.tex` file itself into a folder that is served as static asset.
Otherwise you may need an additional post processing step to move the file to an accessible location.

### Support local build

There are two easy ways to support the _create a local CV preview_ feature.

The first being the original `Makefile` - it used to work and it still does work.
You may want to remove the `git commit` step from the `Makefile` though and add the `.pdf` file itself onto `.gitignore` to make sure the preview stays local.
Downside of this option is you may need to patch code at two different locations.

The second option is to use ***drone*** and its awesome ***drone CLI*** support to run parts of the pipeline locally.
To achieve this install the [drone CLI](https://docs.drone.io/cli/install/) and either copy&paste or put the following line into a script file.

**local CV generation**

```bash
drone exec --include fetch-version --include build-cv
```

**Drone CLI output for local execution**

![CLI output](/assets/continuous-cv/drone-exec.png)

## Summary

We started out with scripting ***git versioning*** a LaTeX based document.
Then we used a `Makefile` to keep all the commands needed to automate the CV generation in one place.
In the final step I we from scripted and manually executed to scripted and ***fully automated generation*** of the PDF using the Drone continuous integration service.

If you have any questions DM me on Twitter [anoff_io](https://twitter.com/anoff_io) or leave a comment 👋
