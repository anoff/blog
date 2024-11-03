---
title: Backup your NAS (Synology) to external harddrive
date: 2024-11-03
tags: [development]
author: anoff
resizeImages: true
draft: false
featuredImage: /assets/2024-nas-backup/title.png
---

Some months ago I decided it is time to take control of all my pictures.
So far everything is hosted either on Google Photos or Adobe servers.

First thing was buying a NAS and trying out different self-hosted photo applications.
Of course if you keep the data yourself, you are also responsible for making sure nothing happens to it and run **Backups**.
This post will explain how to setup a non-vendor-specific encrypted backup of your NAS data that can be read by any Linux system.
The description in this blog post is based on a Synology NAS but works for any Linux based system, NAS, server or computer.

<!--more-->
<!-- TOC depthFrom:2 -->


## What's the best backup strategy for NAS systems?

While researching and selecting my NAS I briefly thought about backup, essentially impacting how many drive bays the NAS should have.
I decided to run my NAS on a RAID1 which means there are two disks but they contain exactly the same information.
Thus if one disk fails the other still works.
In retrospect, I would not go for RAID1 again because it is a waste of money and does not provide any real backup benefits.
Imho RAID1 systems are only relevant if you aim for high availability systems, for home appliances you want to put your money into a proper backup, rather than just duplicate disks.

But what is a proper backup strategy for your important data?

One of the backup standards is the **3-2-1 backup** which states, you should always have:

- 3 copies of your data (the production data you actively work with, + 2 separate backups)
- 2 different media types
- 1 backup in another location

In reality the 2 media types often just means two different devices, but both hard disks.
This blog post will provide with a **2-2-1(0) backup** strategy.
Wheter it is a 2-2-1 or 2-2-0 depends on how you keep the external harddive.
Personally I specifically chose to use an encrypted external harddrive so I can keep it disconnected and easily move it away from my home.

> 💡 I recommend to backup your data on a fixed schedule, biweekly or monthly. Keep the external drive at a friend's, parent's or work place otherwise.

![NAS on fire](/assets/2024-nas-backup/nas-fire.jpg)

This way you have an offsite backup, which protects you against theft or anything destroying your home like a fire, flood, earthquake.
The further you keep your copy from your own home the more better it is protected against bigger disaster, but it will be more difficult to backup frequently.
One thing to look out for is to regularly access this offsite backup so you know the drive is still there.

> If you are not sure if the data is accessible, your backup does not exist!

## Why should I encrypt my backup?

Simply put, because my main data on the NAS is encrypted so having an unencrypted backup makes no sense.
Also the encryption makes it a lot easier to store your backup off-site, because you do not have to worry about another person getting access to your data.
Of course you should still trust them, because it is your backup after all!

## How to encrypt the backup?

Most NAS systems come with their own user interface that supports creating encrypted volumes.
I explicitly chose not to do this, because this creates a lock-in to the NAS system.

In the disaster event where my primary system is destroyed, having a non-vendor-specific backup allows me to backup into any new system I want.
Even without a NAS system I can directly duplicate my backup on another drive and have two copies again.



<!-- /TOC -->

## Share connected USB drive as network share

```sh
# connect disk via USB
# encrypt see crypto.md
# go to synology disk station and create folder under /volume1/
# mount external disk with luks, mount into /volume1/
```