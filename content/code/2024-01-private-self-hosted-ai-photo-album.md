---
title: TODO
date: 2024
tags: [development]
author: anoff
resizeImages: true
draft: true
---



Even though I am a big fan of Open Source Software and try to make my projects open and consumable by others as well, there are cases where you want to keep your stuff private.
But even if you work in a closed source environment you still want to use the same tools that you employ in the open source world.
In this blog post I will explain how you can create private npm packages for your Javascript/Typescript projects - and I will show you how you can host your private npm packages **for free**!


Over the years my attitude towards (de)centralized IT services had ups and downs.
In this post I will explain how I migrated my photo collection to a self-hosted service.
You can do this either as a backup or completely go decentralized with your data.
The application I chose is Photoprism, a German-based open source application that you can setup yourself.

This post will explain why and how I chose Photoprism and as always include code snippets to replicate my setup.

<!--more-->

<!-- TOC depthFrom:2 -->

- [💪 Motivation](#💪-motivation)
- [Setup](#setup)
- [Prepare NAS for making photos accessible to Photoprism](#prepare-nas-for-making-photos-accessible-to-photoprism)
- [Mount NAS storage on client](#mount-nas-storage-on-client)
- [Reindex faces](#reindex-faces)
- [Transfer existing Google Photos Library into own storage](#transfer-existing-google-photos-library-into-own-storage)
- [Share connected USB drive as network share](#share-connected-usb-drive-as-network-share)

<!-- /TOC -->

## 💪 Motivation

When I started working with computers ~20 years ago there was no SaaS, PaaS or even IaaS.
Everything you wanted to do, you did on your own PC.
Eventually web servers and virtual/shared servers came around, where you could offload some of your tasks.
With the rise of Google - at least for me - came also a huge adoption of SaaS, mostly because of the added convenience that came with having all pictures available across devices and synced automatically.
However as SaaS adoption in the industry grew, my data became decentralized as well.
I had some images on Google Photos, some on messenger services, those I took with my digital camera were only available on Adobe servers and software.
What I do not like about my current setup is:

1. The lack of organization throughout all services:
  If I'm looking for pictures of my daughter's birthday I have to check at least two if not three online services.
2. Increased costs:
  Even though each service offers me something I am willing to pay (e.g. Adobe Photo features) I do not want to pay for storage across all these services
3. The uncertainty what might happen if any of those providers decides to change their policies:
  There have been numerous reports of parents losing access to their accounts because they kept pictures of their kids in swimwear.
  With the increase of censorship and inability to fight those automatic misclassifications I am not willing to put the entire childhood memories of my kids into the hands of one company.
  It would be very sad if my parents were never able to show me any photo albums of myself - so I do not want to have this for my kids.

## Setup

N100

perform upgrade to latest release, at least kernel 6.2 to make use of GPU

check kernel uname -r

upgrade ->
  sudo apt install update-manager-core
  sudo nano /etc/update-manager/release-upgrades
  do-release-upgrade -c
  sudo do-release-upgrade

## Prepare NAS for making photos accessible to Photoprism

- enable NFS for target system
- 

## Mount NAS storage on client

> As mentioned above my client is a Ubuntu Mini PC

```shell
# install driver to mount NFS shares
sudo apt install nfs-common
```
sudo mkdir /mnt/photo
sudo mkdir /mnt/photo_landing

setup /etc/fstab

sudo mount -a (or restart)


## Reindex faces

<https://www.reddit.com/r/photoprism/comments/qr83si/comment/hk7ah8q/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button>

## Transfer existing Google Photos Library into own storage

<https://github.com/inthreedee/photoprism-transfer-album>
<https://github.com/mvgijssel/apple-photos-export-timestamp-fix/tree/master>


## Share connected USB drive as network share

```sh
# create user
sudo adduser --no-create-home --disabled-password --disabled-login diskwriter
sudo smbpasswd -a diskwriter

# create a new group that includes all relevant users and owns the data
sudo groupadd smbshare
sudo usermod -a -G smbshare diskwriter
sudo usermod -a -G smbshare anoff
sudo usermod -a -G smbshare root
sudo chgrp -R smbshare /mnt/ships/

# modify /etc/samba/smb.conf
[ships]
    comment = allow diskwriter user access to attached drive
    path = /mnt/ships
    browsable = yes
    writeable = yes
    guest ok = no
    force user = diskwriter
    directory mask = 0755
    create mask = 0644
    write list = diskwriter

# restart service
sudo service smbd force-reload
```

on the client

```sh
# /etc/fstab
//192.168.68.202/ships /mnt/ships cifs vers=3.0,credentials=/home/pi/.cred_ships,auto,rw,uid=pi,noperm 0 0
```