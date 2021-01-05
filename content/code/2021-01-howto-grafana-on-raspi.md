---
title: Setting up Grafana on Raspberry Pi with Docker (compose)
date: 2021-01-05
tags: [raspberry-pi, iot, docker]
author: anoff
resizeImages: true
draft: true
featuredImage: /assets/raspi-grafana/title.png
---

In previous blog posts I showed you [how to setup a Raspberry Pi with docker-compose support](/2020-12-install-docker-raspi) and [how to run InfluxDB on your Raspberry Pi](/2020-12-run-influx-on-raspi-docker-compose).
This tutorial will add [Grafana](https://grafana.com) to your Pi-stack and give you a complete monitoring setup.
The InfluxDB+Grafana stack is heavily used in DevOps scenarios but also extremely useful if you want to visualize any kind of timeseries data at home; power consumption, smart home events, computer uptime, amount of devices in your network, weather in your basement ... endless opportunities at your fingertips!

<!--more-->

<!-- TOC depthFrom:2 -->

- [Prepare the folder structure](#prepare-the-folder-structure)
- [Creating the .env file](#creating-the-env-file)
- [docker-compose.yml](#docker-composeyml)
- [Start Grafana](#start-grafana)

<!-- /TOC -->

This post assumes that you already have a Raspberry Pi with docker-compose installed; if you do not you may want to read up on this blog post.

## Prepare the folder structure

As with the InfluxDB setup, we first need to create some local folders to mount into the grafana docker container for persistence on the Raspberry disk.

```text
$HOME/docker/
├── grafana/
│   ├── data/ # grafanadb working directory
│   ├── provisioning/ # placeholder for provisioning scripts that grafana will load on boot
│   └── grafana.ini # config for telegraf instance
└── compose-files/
    └── grafana
        ├── .env # file containing user secrets
        └── docker-compose.yml # specification of docker containers to run
```

To create those folders you can use the following commands:

```sh
mkdir -p $HOME/docker/grafana/data
mkdir -p $HOME/docker/grafana/provisioning
mkdir -p $HOME/docker/compose-files/grafana
```

To get the correct configuration file for whatever grafana version you are running you can use the following command to spin-up a docker container and extract its default configuration:

```sh
cd $HOME/docker/grafana
docker run --rm --entrypoint /bin/bash grafana/grafana:latest -c 'cat $GF_PATHS_CONFIG' > grafana.ini
```

> ⚠️ Change `latest` to whatever version you plan to run. In this tutorial we will use `latest`.

For Grafana to be able to write to the data mount it needs to own the `grafana/data` directory.
There are two ways to achieve this:

1. Make sure your local directory is owned by the [default Grafana user ID 472:472](https://grafana.com/docs/grafana/latest/installation/docker/#migrate-to-v51-or-later)
  * `chown 472:472 $HOME/docker/grafana/data`
2. Run the Grafana container with your local user ID that already owns the directory
  * find your user id with `id -u` and put it in the `docker-compose.yml` later

Personally, I prefer option 1 on the Raspberry Pi, but found out it does not work that well on MacOS where you might want to run this setup as well.

## Creating the .env file

To make sure you do not have to expose credentials in your `docker-compose.yml` file I recommend to create a separate `.env` file next to the compose file.
This will automatically be sourced by the `docker-compose` script and the variables will be available in the compose file later on.

```ini
# $HOME/docker/compose-files/grafana/.env
GF_SECURITY_ADMIN_USER=admin
GF_SECURITY_ADMIN_PASSWORD=initialpassword
```

## docker-compose.yml

With the directories setup you can create the `$HOME/docker/compose-files/grafana/docker-compose.yml` file.
The entire file looks like this:

```yaml
version: "3.3"

services:
  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    restart: always
    # user: "1000" # needs to be `id -u` // alternatively chown the grafana/data dir to 472:472
    ports:
      - "3000:3000" # expose for localhost
    volumes:
      - $HOME/docker/grafana/data:/var/lib/grafana # data path
      - $HOME/docker/grafana/grafana.ini:/etc/grafana/grafana.ini
      - $HOME/docker/grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_INSTALL_PLUGINS=grafana-clock-panel,grafana-simple-json-datasource
      - GF_SECURITY_ADMIN_USER=${GF_SECURITY_ADMIN_USER}
      - GF_SECURITY_ADMIN_PASSWORD=${GF_SECURITY_ADMIN_PASSWORD}
```

Let us dissect this a bit.
`image` and `container_name` should be clear.

`restart: always` ensures that the container will be started automatically after rebooting the host system (Raspberry Pi).

In the `volumes`, define the mountpoints previously created.

`ports` tells Docker to forward the Grafana default port to the Raspberry Pi host, so it will be reachable from within your network.

> 🚨 If anything goes wrong, double-check that the Grafana docker user owns the `/var/lib/grafana` mountpoint.

One important environment variable that you want to remember is `GF_INSTALL_PLUGINS` that allows you to bootstrap your grafana docker image with pre-installed plugins.
In addition we define pass the `GF_SECURITY_ADMIN_USER/PASSWORD` credentials from our `.env` file into the container.

## Start Grafana

With all configuration done you can start the Grafana container:

```sh
cd $HOME/docker/compose-files/grafana
docker-compose up -d
```

To check if everything is running fine you can run `docker ps` and look for a container named `grafana`.

You should now be able to access your Grafana instance via a browser by opening `http://raspberrypi:3000` (or whatever the hostname of your raspi is 😉) and see the login screen.

![Screenshot of Grafana login screen](/assets/raspi-grafana/grafana-login.png)

If any of this is outdated or does not work for you please leave a comment or reach out via [Twitter](https://twitter.com/anoff_io).
Appreciate the feedback 👋
