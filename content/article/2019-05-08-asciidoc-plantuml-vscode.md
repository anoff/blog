---
title: Preview AsciiDoc with PlantUML in VS Code
date: 2019-05-08
tags: [docs, development]
draft: false
author: anoff
featuredImage: /assets/asciidoc-plantuml/title.png
---
:imagesdir: /assets/asciidoc-plantuml/
:imagesoutdir: _site/assets/asciidoc-plantuml/

This post is for everyone that likes to write AsciiDoc in VS Code but also wants to inline PlantUML diagrams within their docs.
In a previous post about [diagrams with PlantUML](/2018-07-31-diagrams-with-plantuml/) I gave an intro into PlantUML and how to preview images in VS Code.
With the latest release of the asciidoctor plugin for VS Code it is possible to easily preview embedded PlantUML images within AsciiDocs.
No more need to maintain attributes in each file 🎉

Follow me on Twitter at [@anoff_io](https://twitter.com/anoff_io) for future blog updates.
Currently I am writing mostly about _docs-as-code_.
Check [my post tags](/tags) for other topics.

## Prerequisites

You should already have [Visual Studio Code installed](https://code.visualstudio.com/docs/setup/setup-overview) on your machine.
At the time of writing this post I am using `v1.33.1` on MacOS and also verified the setup on a Windows 10 machine.

For the AsciiDoc preview to work we will use the [AsciiDoc extension](https://marketplace.visualstudio.com/items?itemName=joaompinto.asciidoctor-vscode) that you can get by executing

```bash
code --install-extension joaompinto.asciidoctor-vscode
```

**📌 NOTE**\
The feature we are going to use here is [rather new](https://github.com/asciidoctor/asciidoctor-vscode/issues/155#event-2305465063) and shipped with `2.6.0` of the AsciiDoc plugin.

The third thing you need is a PlantUML server.
There are multiple options:

1. use the public [plantuml.com/plantuml](http://plantuml.com/plantuml) server
2. deploy your own [plantuml-server](https://github.com/plantuml/plantuml-server)
3. run [plantuml/plantuml-server](https://hub.docker.com/r/plantuml/plantuml-server/) docker container on your local machine

For test cases option 1 works fine; even if the server claims it does not store any data I would advise you to host your own server if you are working on anything professionally that is not open source.
Setting up a PlantUML server is rather easy if you are familiar with Docker, you can see an example setup in [my blog post from march 2019](/2019-03-24-self-hosted-gitea-drone/).
Finally the third option of running it locally within docker is great if you are on the road or sitting somewhere without WiFi.

**💡 TIP**\
Keep a list of docker images you always have pulled on `:latest` before going for trips.

This post will use option 1 as it just works out of the box while following these instructions.

## Configuring the extension

The [option](https://github.com/asciidoctor/asciidoctor-vscode#options) we will use for this feature is `asciidoc.preview.attributes` that allows you to set arbitrary AsciiDoc attributes.
These attributes will be injected into the preview.
You could also set the attribute manually on each file but that is really something you do not want to do for generic configs like a server URL.
Build systems in the AsciiDoc ecosystem like [Antora](//antora.org) allow you to set attributes during the build process (see [this example](https://github.com/anoff/antora-arc42/blob/master/playbook-remote.yml#L21)), so having a local editor that also injects these attributes is super handy.

Under the hood the AsciiDoc VS Code extension relies on the [javascript port of asciidoctor](https://github.com/asciidoctor/asciidoctor.js) and the [asciidoctor-plantuml.js](https://github.com/eshepelyuk/asciidoctor-plantuml.js) extension.
This extension needs the `:plantuml-server-url:` attribute to be set in the AsciiDoc document to become active and parse PlantUML blocks.

So all you need to do in VS Code is to hop into your user settings and add the following entry

```javascript
"asciidoc.preview.attributes": {
  "plantuml-server-url": "http://plantuml.com/plantuml"
}
```

**⚠️ WARNING**\
The downside of using the public server is that it does not offer SSL encrypted endpoints and you must weaken your VS Code security settings to preview correctly.

The PlantUML images are served over `http://` and you must allow your preview to include data from _unsafe_ sources.
To do this open your command palette (⌘+P, ctrl+P) and enter `asciidoc preview security` and choose _Allow insecure content_.
In case you are running a local PlantUML server you may choose _Allow insecure local content_.

**opening asciidoc preview security settings**

![command palette screenshot](cmd1.png)

**allow insecure content**

![command palette screenshot](cmd2.png)

## Live Preview AsciiDoc with embedded PlantUML

To test it out just create an example file with some PlantUML content.

**This image is rendered on the fly**

```plantuml
@startuml
!includeurl https://gist.githubusercontent.com/anoff/d8f48105ac4d3c7b14ca8c34d6d54938/raw/anoff.plantuml
node "McDonald's" as mcd
node "Rick" as rick
mcd --> rick: szechuan sauce
@enduml
```

With the attribute set correctly the above code block renders as an image

![working preview](preview-ok.png)

    ..without the attribute set or issues with the security settings you just see a code block

![broken preview](preview-nok.png)

Hope this post helped you.
If you have any questions or know of better/alternative ways let me know via [Twitter](https://twitter.com/anoff_io) or leave a comment 👋
