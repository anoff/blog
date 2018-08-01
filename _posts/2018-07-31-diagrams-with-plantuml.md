---
layout: post
title: Markdown native diagrams with PlantUML
subtitle: Create flowcharts, sequence and other diagrams in plain text with full version control support and native markdown rendering
tags: [development, gitlab, github]
---

> This post will cover PlantUML basics and how it can be used in GitLab or GitHub projects as well as a seamless local development environment using Visual Studio Code.

<!-- TOC -->

- [PlantUML Basics 👨‍🎨](#plantuml-basics-‍)
  - [Reasons to love PlantUML 🤗](#reasons-to-love-plantuml-)
    - [Versioning 📦](#versioning-)
    - [Syntax 🐟](#syntax-)
    - [Layouting 🏗](#layouting-🏗)
    - [Share anywhere 📱](#share-anywhere-)
- [Local development 💻](#local-development-)
  - [Visual Studio Code](#visual-studio-code)
  - [Render to SVG/PDF](#render-to-svgpdf)
- [GitLab integration](#gitlab-integration)
- [GitHub integration](#github-integration)
- [Summary](#summary)

<!-- /TOC -->

I have been wanting to write this post for months. Lately I have been using PlantUML extensively at work but also in my private projects. You can see it being used in my [plantbuddy](https://github.com/anoff/plantbuddy#main-features) and [techradar](https://github.com/anoff/techradar#design) projects on GitHub. Using it in different places and for various purposes I came across a bunch of issues that I want to share in this post.

# PlantUML Basics 👨‍🎨

For those that do not know [PlatUML](http://plantuml.com/): It is an open source tool that allows you to define UML diagrams with plain text. There are different [diagram types](http://plantuml.com/sitemap-language-specification) available being described with custom syntax but following a common scheme. This post will not go into the details of each of those diagram types because the PlantUML website does a pretty good job at describing [sequence](http://plantuml.com/sequence-diagram), [component](http://plantuml.com/component-diagram), [activity](http://plantuml.com/activity-diagram-beta) and the other diagram types.

A basic component diagram showing data flow can be built using the following markup:

```text
@startuml component
actor client
node app
database db

db -> app
app -> client
@enduml
```

![basic component diagram showing data flowing from a database via an app to a client]({{ site.baseurl }}/img/assets/plantuml/diagrams/dist/component.svg)

## Reasons to love PlantUML 🤗

### Versioning 📦

A very important aspect for developing software and writing documentation is to keep it in sync. One part is to update documentation if the code itself is updated. Another important part is versioning - usually software is versioned using `git` or similar systems. By putting the documentation into the same repository as the code you make sure to always look at the correct state of documentation for a respective point in time.

For that reason I love putting all my documentation either within the sourcecode as comments or as Markdown files next to the sourcecode. One thing I was always lacking with this approach is visualizing things. Putting PowerPoint/Keynote/Visio/Enterprise Architect.. files into a repository does make sure your diagrams are always versioned with the code - but they are not browsable in Web UIs. Come PlantUML and GitLab rendering to the rescue: GitLab allows you to [inline PlantUML diagrams](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/administration/integration/plantuml.md) directly into your Markdown files and they will be rendered on the fly when viewing the files in the browser.

One other benefit PlantUML has over the mentioned tools is that by defining your diagrams in plain text you make them diff-able in pull requests. Reviewers can always see what changes have been made and easily compare changes to the diagram with changes made inside the code.

### Syntax 🐟

The basic syntax of PlantUML is very concise and builds a good foundation for the different diagram types. It is also well very smart in the way that it allows diagrams to be written with different flavors e.g. you can declare/instantiate all nodes at the top, but if you do not declare them they will be inferred automatically. Same goes for [macros and definitions](http://plantuml.com/preprocessing) that allow you to compose larger diagrams or a common library for your team.

I recently created a [PlantUML Cheatsheet](http://anoff.io/blog/img/puml-cheatsheet.pdf) for a lot of useful tricks - it does however not cover the very basics of PlantUML syntax. You can browse the [latest version](https://github.com/anoff/blog/raw/master/img/assets/plantuml/puml-cheatsheet.pdf) or the [LaTeX sourcecode](https://github.com/anoff/blog/blob/master/img/assets/plantuml/puml-cheatsheet.tex) on GitHub.

### Layouting 🏗

Compared with WYSIWYG editors PlantUML diagrams only define components and their relationship but not the actual layout of the diagram. Instead the diagram is inferred by a deterministic algorithm in the rendering process. This is beneficial when specifying the diagram because you only focus on the content - comparable to writing a LaTeX document.
Sadly the layouting engine is not as good as you sometimes wish it to be and especially in component diagrams with 10+ nodes you might end up spending a lot of time enforcing specific layouts manually.

For sequence and activity diagrams the automatic layouting works great even for very large diagrams. After you built a few diagrams and notice how easy it is to just move lines of code up and down and have changes in the code immediately reflect in your documentation you will love the automatic layouting.

### Share anywhere 📱

If you want to _freeze_ a diagram version and send it to someone outside your organization you can simply send them an insanely long url (e.g. [http://www.plantuml.com/plantuml/png/5Son3G8n34RXtbFyb1GiG9MM6H25XGsnH9p8SGgslrpxzFILcHovse-yYw8QdlJl2v--N93rJ2Bg4EDlSBlG0pn6wDiu5NiDcAU6piJzTgKN5NNPu040](http://www.plantuml.com/plantuml/png/5Son3G8n34RXtbFyb1GiG9MM6H25XGsnH9p8SGgslrpxzFILcHovse-yYw8QdlJl2v--N93rJ2Bg4EDlSBlG0pn6wDiu5NiDcAU6piJzTgKN5NNPu040)) that encodes the entire diagram definition. You can also just embed this URL inside an HTML `<img>` tag. If anyone ever needs to work with the image all you have to do is swap `/plantuml/png` to `/plantuml/uml` and you will see the [definition](http://www.plantuml.com/plantuml/uml/5Son3G8n34RXtbFyb1GiG9MM6H25XGsnH9p8SGgslrpxzFILcHovse-yYw8QdlJl2v--N93rJ2Bg4EDlSBlG0pn6wDiu5NiDcAU6piJzTgKN5NNPu040) of the diagram.

This gives the entire PlantUML toolstack an extremely versatile way of passing information as well as viewable images.

# Local development 💻

The fastest, platform agnostic and easiest way to start creating PlantUML diagrams is using their [online editor](http://www.plantuml.com/plantuml/uml/SoWkIImgAStDuShBJqbLA4ajBk5oICrB0Oe00000) (btw. you can easily host it on prem using the [plantuml-server Docker image](https://hub.docker.com/r/plantuml/plantuml-server/)). This is fine for creating simple diagrams with a few nodes but larger diagrams require a lot of _previewing_ which is annoying in the online editor.

_If you have any other local setups please let me know via [Twitter](https://twitter.com/an0xff)_

## Visual Studio Code

> In case you already use VS Code this is a no brainer to set up. Otherwise you might seriously want to consider using it for the purpose of editing PlantUML diagrams (in Markdown) only because it is a super smooth experience.

All you need to do is to get the [PlantUML extension](https://marketplace.visualstudio.com/items?itemName=jebbs.plantuml) to enable codes native [Markdown preview feature](https://code.visualstudio.com/docs/languages/markdown) to also parse inline diagrams.

![Screenshot of Visual Studio Code showing rendered PlantUML diagram in Markdown preview]({{ site.baseurl }}/img/assets/plantuml/code-rendering.png)

By default the plugin requires a local PlantUML process to be running and accepting the rendering requests. I recommend switching it to use a server for rendering; this could be the official plantuml.com server, an on premise instance or a locally running [container](https://hub.docker.com/r/plantuml/plantuml-server/). After installing the plugin go to the VS Code options (`ctrl/⌘ + ,`) and change the `plantuml.render` property.

```javascript
// PlantUMLServer: Render diagrams by server which is specified with "plantuml.server". It's much faster, but requires a server.
// Local is the default configuration.
"plantuml.render": "PlantUMLServer",

// Plantuml server to generate UML diagrams on-the-fly.
"plantuml.server": "http://www.plantuml.com/plantuml",
```

If you ever go off the grid and still want to work remember to `docker run -d -p 8080:8080 plantuml/plantuml-server:jetty` while you still have an internet connection. The image is `~250MB` to download. Afterwards set `plantuml.server` to `http://localhost:8080/` and you're set for an offline adventure.

_On my MacBook I sometimes experience a lot of CPU consumption from the running container - even when not actively rendering. Restarting the container helps 🤷‍_

## Render to SVG/PDF

> This method only works if diagrams are defined explicitly in files and not inlined into Markdown.

To write this blog post and build the [Cheatsheet]() I played around with non-realtime ways of rendering PlantUML diagrams into images. You can use the [Makefile](https://github.com/anoff/blog/blob/master/img/assets/plantuml/Makefile) and [Shell script](https://github.com/anoff/blog/blob/master/img/assets/plantuml/diagrams/convert.sh) to convert an entire [folder](https://github.com/anoff/blog/tree/master/img/assets/plantuml/diagrams) of PlantUML diagrams with `.puml` extension into `.svg` and `.pdf` [files](https://github.com/anoff/blog/tree/master/img/assets/plantuml/diagrams/dist).

The script essentially runs the diagram definition through a dockerized PlantUML process which outputs an `.svg` and then uses Inkscape to create a `.pdf` file for importing it into LaTeX documents for example.

```sh
#!/bin/sh
# converts all puml files to svg

BASEDIR=$(dirname "$0")
mkdir -p $BASEDIR/dist
rm $BASEDIR/dist/*
for FILE in $BASEDIR/*.puml; do
  echo Converting $FILE..
  FILE_SVG=${FILE//puml/svg}
  FILE_PDF=${FILE//puml/pdf}
  cat $FILE | docker run --rm -i think/plantuml > $FILE_SVG
  docker run --rm -v $PWD:/diagrams productionwentdown/ubuntu-inkscape inkscape /diagrams/$FILE_SVG --export-area-page --without-gui --export-pdf=/diagrams/$FILE_PDF &> /dev/null
done
mv $BASEDIR/*.svg $BASEDIR/dist/
mv $BASEDIR/*.pdf $BASEDIR/dist/
echo Done
```

# GitLab integration

> This feature is currently only available with on-prem installations of GitLab, enabling it on gitlab.com is [an open issue](https://gitlab.com/gitlab-com/infrastructure/issues/2163). See the GitHub integration for a workaround.

Using PlantUML within GitLab is super fun. All you have to do is [set up](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/doc/administration/integration/plantuml.md) a render server to use and you can just commit Markdown files with inlined PlantUML diagrams and they will render for everyone visiting the GitLab web UI.

What's great is that this does not only works in Markdown files committed into a git repository but in all other fields within GitLab that render markdown - virtually everything. You can have small diagrams helping illustrate things in issues as well.

![Screenshot of PlantUML syntax in a GitLab issue]({{ site.baseurl }}/img/assets/plantuml/puml-issue.png)

![Rendered PlantUML diagram in a GitLab issue]({{ site.baseurl }}/img/assets/plantuml/puml-issue-rendered.png)

# GitHub integration

There is no native PlantUML integration for GitHub and gitlab.com available. To maintain the advantages listed above it is obviously not a valid workaround to just render the files locally and commit them into git.

Instead make use of the PlantUML [proxy service](http://plantuml.com/server) as described in [this stackoverflow discussion](https://stackoverflow.com/questions/32203610/how-to-integrate-uml-diagrams-into-gitlab-or-github). The way this works is that instead of passing the PlantUML server the diagram content within the URL we define a _remote URL_ where the content can be fetched from e.g. `http://www.plantuml.com/plantuml/proxy?src=https://raw.github.com/plantuml/plantuml-server/master/src/main/webapp/resource/test2diagrams.txt`. This URL can be embedded in an HTML `<img>` tag or within Markdown image syntax `![]()`. To leverage this feature when using GitHub, simply point the _remote URL_ to a raw link of the PlantUML diagram in your repository.

The following diagram shows what will happen when you open a Markdown page hosted on GitHub that contains such a link:

![sequence diagram showing how PlantUML proxy service works]({{ site.baseurl }}/img/assets/plantuml/diagrams/dist/plantuml-proxy.svg)

[This example](https://github.com/anoff/plantbuddy/blame/master/readme.md#L12) shows that adding a `?cache=no` might be a good idea because of GitHubs Camo [caching strategy](http://forum.plantuml.net/7163/githubs-aggressive-caching-prevent-diagrams-updated-markdown) which will prevent your images from updating if you change the sourcecode.

The downside of this approach is that it will always render the latest commmit in your repository even if you browse old versions. If browsing old versions is a _strong_ requirement for you when using an integration with GitHub then you might need to build your own plugin/renderer or optimize the local development environment because after all the correct diagram version will always be with the sourcecode you checked out.

To use the proxy service integration simply use:

```text
![cached image](http://www.plantuml.com/plantuml/proxy?src=https://raw.github.com/plantuml/plantuml-server/master/src/main/webapp/resource/test2diagrams.txt)

![uncached image](http://www.plantuml.com/plantuml/proxy?cache=no&src=https://raw.github.com/plantuml/plantuml-server/master/src/main/webapp/resource/test2diagrams.txt)
```

# Summary

There are two fundamental ways of keeping PlantUML diagrams

1. inline into Markdown
1. keep as individual `.puml` files

Depending on your toolstack one of those should be your preferred option to work with diagrams in your repository. It is highly recommend to keep diagrams as close to the code as possible and not create artificial documentation repositories.

This post covered how to write and render files locally in **VS Code**, using **Docker** containers and how to integrate into **GitLab on prem** as well as publich **GitHub** and **GitLab** instances.

There is a lot more to tell about PlantUML but I hope this article gave you enough infos to get started on whatever platform you are using. I recommend this [PlantUML Cheatsheet](http://anoff.io/blog/img/puml-cheatsheet.pdf) which will help you to cover an even wider range of use cases.

Tell me about your experiences with PlantUML or alternative integrations on [Twitter 🐦](https://twitter.com/an0xff)