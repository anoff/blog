---
title: Running influxdb on Raspberry Pi using Docker compose
date: 2020-12-31
tags: [raspberry-pi, iot, docker]
author: anoff
resizeImages: true
draft: false
featuredImage: /assets/raspi-influx/title.png
---

This blog post will explain how you can setup influxdb (and the telegraf plugin) on your Raspberry Pi using docker-compose.
We will use config-as-code wherever possible to create reproducible setups.
This is extremely helpful for hobby projects that you come back to every now-and-then because you can lookup exactly what you are running 😉

<!--more-->

A quick overview of what needs to be done to get influxdb running on a Raspberry Pi using docker-compose to orchestrate it.

<!-- TOC depthFrom:2 -->

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Preparing the influxdb working directory](#preparing-the-influxdb-working-directory)
  - [Creating folder structure](#creating-folder-structure)
  - [Create influxdb.conf and telegraf.conf](#create-influxdbconf-and-telegrafconf)
  - [Create Init Script for Telegraf database & user](#create-init-script-for-telegraf-database--user)
  - [Create docker-compose specification](#create-docker-compose-specification)
  - [Insert user secrets into docker recipe](#insert-user-secrets-into-docker-recipe)
- [Start influxdb via docker-compose](#start-influxdb-via-docker-compose)
- [Access your influxdb instance via shell](#access-your-influxdb-instance-via-shell)
  - [Access the chronograf web UI](#access-the-chronograf-web-ui)

<!-- /TOC -->

## Overview

A quick overview of the service architecture that will be built with this setup.

* InfluxDB exposing a port into your home network
* Chronograf as Admin UI, only accessible from within your Raspberry Pi
* Telegraf to ingest system metrics

.Service Setup
[plantuml, service-setup, svg]
....
@startuml service-setup
skinparam monochrome true
skinparam defaulttextalignment center

frame "Home Network" as net {
  interface "influx<i>:8086" as influx
  frame "Raspberry Pi" as pi {
    interface "chronograf UI<i>:8888" as chronograf
    component Docker as docker1 {
      artifact "influxdb:latest" as influxdb
      artifact "telegraf:latest" as telegraf
      artifact "chronograf:latest" as chrono
    }
  }
  frame "Computer" as pc {
    artifact "Shell session" as shell
    artifact "Browser" as browser
  }
  influxdb -- influx
  chrono -- chronograf
  telegraf --(0 influxdb
  chrono --(0 influxdb
  shell --(0 pi
}
@enduml
....

## Prerequisites

You will need to have a Raspberry Pi with Docker and docker-compose installed.
See my previous blog post if you do not know how to do that [How to setup Raspberry Pi as home server with Docker support](/2020-12-install-docker-raspi-3).
Your pi also needs to have an active internet connection and you need access it's terminal, either via SSH or direct keyboard.

## Preparing the influxdb working directory

To persist data and configuration of your influxdb instance you need to create a directory on your Raspberry system that will be used by docker.

### Creating folder structure

I suggest creating this structure directly in your home directory.
This way you will not have to worry about permissions too much.
To keep things a bit cleaner I suggest nesting all your docker mounts into a common folder.

```text
$HOME/docker/
├── influxdb/
│   ├── data/ # grafanadb working directory
│   ├── init/ # some init scripts to bootstrap the instance
│   ├── influxdb.conf # config for influxdb instance
│   └── telegraf.conf # config for telegraf instance
└── compose-files/
    └── influxdb
        ├── .env # file containing user secrets
        └── docker-compose.yml # specification of docker containers to run
```

To create the directories run these commands

```sh
# do this on your raspi
mkdir -p $HOME/docker/influxdb/data
mkdir -p $HOME/docker/influxdb/init
mkdir -p $HOME/docker/influxdb/compose-files/influxdb
```

### Create influxdb.conf and telegraf.conf

To create a default config in the newly created working directory run the following command

```sh
cd $HOME/docker/influxdb
docker run --rm influxdb influxd config > influxdb.conf
# next do some modifications to the default config
# enable HTTP auth
sed -i 's/^  auth-enabled = false$/  auth-enabled = true/g' influxdb.conf
# do any other changes you want, or replace with your own config entirely
```

Next create the config file for telegraf and do some modifications.
Please note `<telegrafUSERpassword>` and create your own password here.

```sh
cd $HOME/docker/influxdb
docker run --rm telegraf telegraf config > telegraf.conf
# now modify it to tell it how to authenticate against influxdb
sed -i 's/^  # urls = \["http:\/\/127\.0\.0\.1:8086"\]$/  urls = \["http:\/\/influxdb:8086"\]/g' telegraf.conf
sed -i 's/^  # database = "telegraf"$/  database = "telegraf"/' telegraf.conf
sed -i 's/^  # password = "metricsmetricsmetricsmetrics"$/  password = "<telegrafUSERpassword>"/' telegraf.conf
# as we run inside docker, the telegraf hostname is different from our Raspberry hostname, let's change it
sed -i 's/^  hostname = ""$/  hostname = "'${HOSTNAME}'"/' telegraf.conf
```

After those modifications your file should have the following (and a lot more) entries:

```sh
[agent]
  hostname = "${PI_HOSTNAME}"
[[outputs.influxdb]]
  urls = ["http://influxdb:8086"]
  database = "telegraf"
  ## HTTP Basic Auth
  username = "telegraf"
  password = "<telegrafUSERpassword>"
```

### Create Init Script for Telegraf database & user

As good security practice we do not want telegraf to operate with the admin account of influxdb, instead create a separate account.
Making use of the init scripts feature of the influxdb docker container, we can create influxQL scripts in the `influxdb/init` folder that will be executed on first start of the container.

Create the following script at `$HOME/docker/influxdb/init/create-telegraf.iql`.
This creates a database with 31 days retention - modify password and retention to your liking.

```sql
CREATE DATABASE telegraf WITH DURATION 31d
CREATE USER telegraf WITH PASSWORD '<telegrafUSERpassword>' # same password that you used in telegraf.conf
GRANT WRITE ON telegraf to telegraf
```

### Create docker-compose specification

Create the following file at `$HOME/docker/compose-files/influxdb/docker-compose.yml`

```yml
version: "3"

networks:
  metrics:
    external: false

services:
  influxdb:
    image: influxdb:latest
    container_name: influxdb
    restart: always
    networks: [metrics]
    ports:
      - "8086:8086"
    volumes:
      - $HOME/docker/influxdb/data:/var/lib/influxdb
      - $HOME/docker/influxdb/influxdb.conf:/etc/influxdb/influxdb.conf:ro
      - $HOME/docker/influxdb/init:/docker-entrypoint-initdb.d
    environment:
      - INFLUXDB_ADMIN_USER=${INFLUXDB_USERNAME} # sourced from .env
      - INFLUXDB_ADMIN_PASSWORD=${INFLUXDB_PASSWORD} # sourced from .env
  telegraf:
    image: telegraf:latest
    container_name: telegraf
    networks: [metrics]
    volumes:
      - $HOME/docker/influxdb/telegraf.conf:/etc/telegraf/telegraf.conf:ro
  chronograf:
    container_name: chronograf
    image: chronograf:latest
    ports:
      - "127.0.0.1:8888:8888"
    depends_on:
      - influxdb
    networks: [metrics]
    environment:
      - INFLUXDB_URL=http://influxdb:8086 # needs to match container_name
      - INFLUXDB_USERNAME=${INFLUXDB_USERNAME} # sourced from .env
      - INFLUXDB_PASSWORD=${INFLUXDB_PASSWORD} # sourced from .env
```

We also add chronograf as an Admin UI for influxdb into the container setup.
However chronograf does not support any authentication so we allow it only to be accessed from the machine that runs docker directly i.e. our Raspberry Pi.
So even though it looks odd please do not change `"127.0.0.1:8888:8888"` as this makes sure this port is only accessible from the localhost.
Later on you will learn how to reach this from outside the Raspberry system though.

### Insert user secrets into docker recipe

As you saw in the `docker-compose.yml` it does not contain the actual usernames and secrets.
These will be read from a (hopefully secret) `.env` file that you need to place next to the yml at `$HOME/docker/compose-files/influxdb/.env`

```sh
INFLUXDB_USERNAME=admin
INFLUXDB_PASSWORD=<superSECRETinfluxPASSWORD>
```

## Start influxdb via docker-compose

Now it is finally time to startup all containers for the first time!

```sh
cd $HOME/docker/compose-files/influxdb
docker-compose up -d # -d will start the containers in "detached" mode so they continue running after you close the shell
```

## Access your influxdb instance via shell

With your docker container running you can use the following command to create an interactive `influx` shell

```sh
docker exec -it influxdb influx
```

Authenticate with the admin user (remember the `.env` file) in order to look at all users and databases).
Then you can use the `SHOW USERS` and `SHOW DATABASES` commands.
With my username and pi hostname it looks like this:

![Screenshot of Influx Shell](./assets/raspi-influx/influx-shell.png)

If anything up until this point did not correctly and you do not have the `telegaf` user and database I suggest cleaning up everything and restarting.

```sh
# 🚨 ONLY DO THIS if you have issues, this will delete your setup
sudo rm -rf $HOME/docker/influxdb/data
mkdir -p $HOME/docker/influxdb/data
cd $HOME/docker/compose-files/influxdb
docker-compose rm --stop --force
docker system prune --force
```

### Access the chronograf web UI

As mentioned earlier the chronograf UI does not offer any application level authentication.
This is why the application is secured on a network level by making it only accessible from the Raspberry itself.
To be able to access the dashboard from outside the raspi you can do temporary port forwarding via SSH using the following command

```sh
# run this on your computer
ssh pi@soto -L 8888:localhost:8888 -N
# now you can enjoy the chronograf UI on localhost:8888 on your computer as well
# once you are done kill the SSH process to stop the port forwarding
```



If any of this is outdated or does not work for you please leave a comment or reach out via [Twitter](https://twitter.com/anoff_io).
Appreciate the feedback 👋
