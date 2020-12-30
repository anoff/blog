---
title: How to setup Raspberry Pi as home server with Docker support
date: 2020-12-29
tags: [raspberry-pi, iot, docker]
author: anoff
resizeImages: true
draft: false
featuredImage: /assets/raspi-docker/title.png
---

This blog post will cover how to setup a Raspberry Pi with Docker support.
It will also cover some basic steps that will make it easier to work with your RasPi later on.
This setup will work completely without monitor/keyboard for your Raspberry but you need a LAN connection to it.
I wrote most commands so they are easily pastable and do not require too much interactive work - you should however carefully read what is going on with each of those commands before you fire them off!

<!--more-->

<!-- TOC depthFrom:2 -->

- [Installing Raspbian OS](#installing-raspbian-os)
- [Setting up SSH access](#setting-up-ssh-access)
  - [Enable SSH for first start](#enable-ssh-for-first-start)
  - [Install SSH Keyfile](#install-ssh-keyfile)
  - [Configuring your host to automatically use the Keyfile](#configuring-your-host-to-automatically-use-the-keyfile)
  - [Permanently enable SSH server](#permanently-enable-ssh-server)
  - [Change SSH port, hostname and disable password authentication](#change-ssh-port-hostname-and-disable-password-authentication)
- [Additional tweaks to your Pi](#additional-tweaks-to-your-pi)
  - [Expand Filesystem](#expand-filesystem)
  - [Disable WiFi/Bluetooth](#disable-wifibluetooth)
  - [Set default locale](#set-default-locale)
  - [Enable automatic upgrades](#enable-automatic-upgrades)
- [Install Docker](#install-docker)
- [Install docker-compose](#install-docker-compose)
- [add `ll` alias](#add-ll-alias)

<!-- /TOC -->

## Installing Raspbian OS

The first thing you need to do is get an SD Card that runs your Raspberry Pi operating system.
To install the OS grab the [Raspberry Pi Imager](https://www.raspberrypi.org/software/) (available for Linux, Windows and Mac) and run it.
If you only want to access your raspi remotely it is recommended to use the **Raspberry Pi OS Lite** from the imager menu.
Do not put the card into your raspi just yet - read the next chapter.

## Setting up SSH access

It is super helpful to have SSH access on your raspi - especially if you want to place it somewhere you do not see it all the time.
There are multiple ways to setup SSH, this one is the _SSH from the start_ approach where we enable SSH (temporarily) right from the first boot and then use an initial SSH connection to enable it permanently.
We will use SSH with public/private key authentication and prevent password authentication as a security measure.
As an additional light security measure we will change the SSH port.
This does not make your system more secure but it will make it less likely to be detected by bots sniffing for SSH servers and spare you some traffic.

### Enable SSH for first start

Before putting the newly formatted card into your Raspberry we need to create an empty file named `ssh` on the SD card.
On MacOS you can do this via:

```sh
touch /Volumes/boot/ssh
```

Next make sure the raspi has a LAN connection to your computer - either direct or via your home network.
Then power the board up.

> If you are unable to connect via SSH just re-do this step by putting the SD card back into your computer.

### Install SSH Keyfile

Create a private/public key pair and install the public key on the Raspberry.

```sh
# on your current computer
cd ~/.ssh
# create new key pair
ssh-keygen -b 4096 -f id_pi -N '' -C 'raspberry pi login key'
# add fingerprint to known hosts
ssh-keyscan -H raspberrypi >> ~/.ssh/known_hosts
# copy public key to pi
ssh-copy-id -i id_pi.pub pi@raspberrypi
# you need to enter the password for the pi user which by default is 'raspberry' (we'll fix this later)
```

### Configuring your host to automatically use the Keyfile

You can configure your host computer to automatically use the newly created keyfile when connecting to your Raspberry.
On your computer open `nano ~/.ssh/config` and add the following entry

```text
Host raspberrypi
  User              pi
  IdentityFile      ~/.ssh/id_pi
```

In case you change your hostname (later in this tutorial) you may want to change this config too.

### Permanently enable SSH server

To make sure you do not have to activate the SSH server manually every time you can activate it permanently using the following commands.

```sh
# log onto your raspberry
ssh -i ~/.ssh/id_pi pi@raspberrypi
# enable ssh server via system controls
sudo systemctl enable ssh
sudo systemctl start ssh
```

Now you are safe to reboot and still have a working SSH server.


### Change SSH port, hostname and disable password authentication

Again starting from your host system

```sh
# log onto the raspberry
ssh -i ~/.ssh/id_pi pi@raspberrypi
# change ssh port to 2221
sudo sed -i 's/^#*Port .*/Port 2221/' /etc/ssh/sshd_config
# disable password authentication on ssh (enforce use of private key)
sudo sed -i 's|[#]*PasswordAuthentication yes|PasswordAuthentication no|g' /etc/ssh/sshd_config
# restart ssh service
sudo service ssh restart
# change pi password
passwd # < interactive (make sure to pick a strong password and store it somewhere safe, this will be needed)
# re logon
exit
ssh -i id_pi -p 2221 pi@raspberrypi
# update packages
sudo apt update && apt upgrade
# change hostname
export NEW_HOSTNAME=mypi # set this to whatever you want to name your new raspberry pi
sudo sed -i "s|raspberrypi|$NEW_HOSTNAME|g" /etc/hosts
sudo sed -i "s|raspberrypi|$NEW_HOSTNAME|g" /etc/hostname
```

🚨 From now on you need to connect to your Raspberry using **port 2221** and the new hostname.

## Additional tweaks to your Pi

### Expand Filesystem

Make sure Raspbian OS can use the entire SD card.

```sh
sudo raspi-config --expand-rootfs
```

### Disable WiFi/Bluetooth

If you do not plan to use it, why not completely deactivate it.

```sh
sudo sh -c 'echo "dtoverlay=disable-wifi\ndtoverlay=pi3-disable-wifi\ndtoverlay=disable-bt\ndtoverlay=pi3-disable-bt" >> /boot/config.txt'
```

### Set default locale

Many tools rely on a configured localization, setting this will prevent annoying warnings.

```sh
# enable en_US as locale, change to your own if you want localize
sudo sed -i 's|# en_US.UTF-8 UTF-8|en_US.UTF-8 UTF-8|' /etc/locale.gen
sudo locale-gen
# set defaults to en_US
sudo sh -c 'echo "LC_ALL=en_US.UTF-8\nLANGUAGE=en_US.UTF-8\nLANG=en_US.UTF-8\nLC_MESSAGES=en_US.UTF-8" > /etc/default/locale'
```

### Enable automatic upgrades

It is important to keep your system up to date.
But we all know you will neglect this task, so just automate it.
If you have any critical applications you may want to skip this solution and find a more elaborate approach.

Create the following file `sudo touch /etc/cron.weekly/autoupdate && sudo chmod 755 /etc/cron.weekly/autoupdate && sudo nano /etc/cron.weekly/autoupdate`

```sh
#!/bin/bash
apt-get update
apt-get upgrade -y
apt-get autoclean
```

## Install Docker

On your Rasperry executed the following commands

```sh
# download the install script
curl -fsSL https://get.docker.com -o get-docker.sh
# run the install script
sh get-docker.sh
# add 'pi' user to docker group to allow running containers
sudo usermod -aG docker $(whoami)
```

Now you need to logout (`exit`) and login again to get access to the docker group.
Test if docker works correctly by running

```sh
# exit ssh session
exit
# open a new one
ssh -i id_pi -p 2221 pi@mypi
docker run hello-world
```

## Install docker-compose

docker-compose might be useful if you plan to run multiple containers.
The default installation option for compose does not provide an ARM solution so we use the fallback via python.

```sh
sudo apt-get -y install libffi-dev libssl-dev python3-dev python3 python3-pip
sudo pip3 install docker-compose # needs sudo to put it into path correctly
```

## add `ll` alias

Looking through directories using `ll` as an alias for `ls -ahl` is way more convenient, so you can enable it by modifying the default `.bashrc` file.

```sh
sed -i 's/#*alias ll=.*$/alias ll="ls -ahl"/g' ~/.bashrc
```

If any of this is outdated or does not work for you please leave a comment or reach out via [Twitter](https://twitter.com/anoff_io).
Appreciate the feedback 👋
