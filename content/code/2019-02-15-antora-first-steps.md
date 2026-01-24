---
title: Converting existing AsciiDoc into an Antora project
date: 2019-02-15
tags: [development, docs, architecture]
author: anoff
resizeImages: true
featuredImage: /assets/antora-arc42/antora-arc42.png
---

After 2 years of working with the arc42 template in markdown, I spent the last few weeks learning about an asciidoc based site generator named [Antora](//antora.org/). The main reason for the interest in AsciiDoc was the fact that the limited feature set in markdown often impairs you while writing down complex things. But I had one problem; most of our documentation is scattered across multiple repositories as we try to keep the docs as close to the code as possible. That is why this series will cover how to get a multi repository (software) architecture template up and running using [Antora](//antora.org/).

**This is a screenshot of the final result**

![Preview image](/assets/antora-arc42/website.png)

## The starting point

There are a few things that you should at least have heard of before you continue reading:

1. [AsciiDoc](//asciidoctor.org/docs/what-is-asciidoc/) is a markup language, kind of like Markdown but more powerful. Think of it as a hybrid between the extremely powerful LaTeX and the simple but easy to read Markdown.
   * Compared to Markdown it focuses more on providing large documents like books or full blown documentation
   * You might also stumble upon [Asciidoctor](//asciidoctor.org/) which is the de-facto standard for converting `asciidoc` files into readable formats like `pdf`, `html`, `epub` etc. whereas AsciiDoc itself is the markup syntax itself
2. [arc42](//arc42.org/) is a software architecture template under MIT license that can be used in almost any scenario because it proves to be highly flexible and inherently agnostic of technology and domains
3. [Antora](//antora.org/) solves the problem of writing `AsciiDoc` distributed over multiple repositories by introducing a component concept and providing a generator that merges the multiple sources automatically

The official [arc42 asciidoc template](//github.com/arc42/arc42-template/tree/master/EN/asciidoc) is structured into the twelve arc42 chapters and one main file `arc42-template.adoc` which includes all the chapters as refernce to combine them into a kind of _book_.
The main conflict I had with this concept in my projects was that I want my lower level software architecture to be close to the implementation and - in my multi-repository environment - that means a different repository than the overall concepts that arc42 focuses on in the first chapters.

The first step to introduce Antora is to make your `AsciiDoc` files actually comply with the Antora way of structuring documentation.

## Changing docs into the Antora structure

**📌 NOTE**\
Because [Sara White](//gitlab.com/graphitefriction) and [Dan Allen](//gitlab.com/mojavelinux) did an amazing job with [the Antora docs](//docs.antora.org/) detailing all the concepts behind Antora I will only mention the essentials here.

There are two types of _abstraction_ that Antora makes for distributed documentation; `Component` and `Module`

![Antora artifacts](/assets/plantuml/diagrams/dist/antora-artifacts.svg)

A ***component*** can have multiple modules that are all located in a fixed directory structure adjacent to each other, there can be only one component within a git repository. Each component must have at least one module, the _ROOT_ module.
The ***playbook*** (overall config of the documentation) references one or more git repositories that each contains a component with 1 or more modules.

1. Antora expects all documentation to be part of a _component_
   1. any asciidoc file can reference or include files from other components within the same Antora project
2. the playbook can define multiple content sources
   1. each content source needs to point to a root directory of a git repo (local or remote)
   2. you can use `start_path` in a [playfile source](//docs.antora.org/antora/2.0/playbook/playbook-schema/#content-category) to make the docs start relative to the git root
   3. the repo must have at least one commit
3. within this start path [a component structure](//docs.antora.org/antora/2.0/modules/#module-overview) is expected
   1. the [antora.yml](//docs.antora.org/antora/2.0/component-descriptor/#component-descriptor-requirements) file defines the position of a component
   2. there must be a `modules/ROOT` (uppercase) module present
   3. all `.adoc` files must reside in the `modules/XYZ/pages` directory
4. files are only `include::`-able in Antora if they have the `:page-partial:` attribute
   1. see [antora#405](//gitlab.com/antora/antora/issues/405) for Dan’s comments
   2. the `:page-partial:` attribute only works as a document attribute following the document heading
   3. if you only have lvl1 headings the attribute should be the very first line
   4. my current feeling is that antora `.adoc` files should best be written as their own documents i.e. give each file a document title followed by the partial attribute

## Modifications to the arc42 template

![Antora arc42 mashup](/assets/antora-arc42/antora-arc42-s.png)

**⚠️ WARNING**\
All links to my GitHub repo point to the HEAD commit at the time of writing; things might have changed on master.

The first version of the antora port remains as close to the original template as possible. To reproduce the result a couple of steps are necessary.

1. create the antora component structure with `docs/modules/ROOT/pages/`
   1. the `docs/` folder is not required by Antora, but I did not like having documentation _modules_ in the root of a git repo 🙄
   2. add a [playbook.yml](//github.com/anoff/antora-arc42/blob/0e46f1c8b700e594b5b2e22718264a23b5f6cf42/playbook.yml) to the root directory of the git repository specifying the current local directory as the only component and `start_path: docs`

      **playbook.yml**

      ```adoc
      site:
        title: Antora ARC42 Template
        # the 404 page and sitemap files only get generated when the url property is set
        url: https://anoff.io/antora-arc42
        start_page: system::03_system_scope_and_context.adoc
      content:
        sources:
        - url: ./
          start_path: docs
          branches: [HEAD]
      ui:
        bundle:
          url: https://gitlab.com/antora/antora-ui-default/-/jobs/artifacts/master/raw/build/ui-bundle.zip?job=bundle-stable
          snapshot: true
        supplemental_files: ./supplemental-ui
      ```
   3. move all [arc42 template](//github.com/arc42/arc42-template/tree/master/EN/asciidoc) files into the `ROOT/pages` directory directly - do not use subfolders within the pages directory
   4. create an [antora.yml](//github.com/anoff/antora-arc42/blob/0e46f1c8b700e594b5b2e22718264a23b5f6cf42/docs/antora.yml) that defines the entry point for the component into the `docs/` folder

      **antora.yml**

      ```adoc
      name: system
      title: System Level
      version: 0.9.0
      start_page: 03_system_scope_and_context.adoc
      nav:
        - modules/ROOT/nav.adoc
      ```
2. rewrite all template files to be adoc documents
   1. turn the `== Level 1 Heading` into `= Document title`
   2. adjust subsequent headings to preserve heading hierarchy
   3. add the `:page-partial:` attribute to each document
3. I got rid of all the help popups and instead made it fully visible _sidebar_ content
4. create a [nav.adoc](//github.com/anoff/antora-arc42/blob/0e46f1c8b700e594b5b2e22718264a23b5f6cf42/docs/modules/ROOT/nav.adoc) navigation entry for the ROOT component
   1. this is used to create the navbar entry on the right
5. Fix paths in the overview document
   1. I renamed `arc42-template.adoc` to `index.adoc`
   2. also make sure to change all `include::` paths to no longer use the `src/` subfolder
   3. [Dan recommends](//gitlab.com/antora/antora/issues/405#note_139121293) to use component references instead of local paths from the beginning, I assume this makes copy pasting less error-prone

If you want to follow the steps in detail, take a look at the [commits on my GitHub repo](//github.com/anoff/antora-arc42/commits/0e46f1c8b700e594b5b2e22718264a23b5f6cf42).

This should already yield a working page. You can test it running the following commands

```sh
# install the antora tools
npm i -g @antora/cli@2.0 @antora/site-generator-default@2.0
# install the serve utility to start a local web server
npm i -g serve

# run the antora build
antora generate playbook.yml --to-dir dist/ --clean

# browse the output locally
serve dist/
```

**💡 TIP**\
In case you want to publish to gh pages or any other service that might run jekyll [take a look at these notes](//docs.antora.org/antora/2.0/run-antora/#publish-to-github-pages) describing how to make antora work in a jekyll environment

## Customizing the UI

I actually think Antora’s default UI is quite pleasing - compared to the default plantUML theme 🙄. But I wanted to modify their default footer content. For small changes Antora has a concept of _supplemental_ UI files that allows you to switch individual files of the UI component that are used during the Antora site generation.

By taking a look at the [default UI project](//gitlab.com/antora/antora-ui-default/tree/master/src/partials) I identified the `footer-content.hbs` as the file I wanted to replace.
This is achieved by the `supplemental_files: ./supplemental-ui` section in the `playbook.yml` and adding the custom footer file in the respective directory.

**supplemental-ui/footer-content.hbs**

```hbs
<footer class="footer">
  <p>Original arc42 template licensed under <a href="https://raw.githubusercontent.com/arc42/arc42-template/master/LICENSE.txt">MIT</a> and modified for antora fit by <a href="https://anoff.io">Andreas Offenhaeuser</a>, the page is created using the Antora Default UI licensed under <a href="https://gitlab.com/antora/antora-ui-default/blob/master/LICENSE">MPL-2.0</a> </p>
</footer>
```

In addition to this I added the ***Find on GitHub*** entry in the header, but I am sure you can figure out how that works 😉

You can find the final result of all steps in this first tutorial [at antora-arc42-1.surge.sh](//antora-arc42-1.surge.sh)

## Next steps

Over the next few days/weeks I will keep working on this setup to bring in more aspects I see necessary for a real life scenario.

1. separate _larger_ sections of the arc42 template into their own antora component, e.g. architecture decisions, cross cutting concepts
2. setting up a multi repo arc42 playbook that consists of
   * a _system_ repository containing the top level architecture docs
   * two components that implement a part of the system and have the component specific documentation allocated in the same repository
   * an antora build that generates a fully integrated arc42 documentation out of those three repos
3. build a custom UI project
   * modified header colors etc
4. add plantUML support

Stay tuned for follow up posts on these steps.

If you have any questions send me a DM on [Twitter](//twitter.com/anoff_io) or leave a comment below.
