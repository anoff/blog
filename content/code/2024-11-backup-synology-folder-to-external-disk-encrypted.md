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

First, find your disk and define variables for your device and mapping name:

```sh
sudo fdisk -l
export MNT_DEVICE=/dev/sda # adjust this to your device
export MNT_NAME=extbackup  # mapping handle name
```

Create the encrypted partition and map it:

```sh
sudo cryptsetup --type luks2 --cipher aes-xts-plain64 --hash sha256 --iter-time 10000 --key-size 512 --pbkdf argon2id --sector-size 4096 --use-random --verify-passphrase luksFormat $MNT_DEVICE
sudo cryptsetup open $MNT_DEVICE $MNT_NAME
```

It is highly recommended to backup the LUKS header in case of corruption:

```sh
sudo cryptsetup luksHeaderBackup $MNT_DEVICE --header-backup-file luks-header-backup.img
```

Create a filesystem, mount it, and assign permissions:

```sh
# optionally wipe with zeros: sudo dd if=/dev/zero of=/dev/mapper/$MNT_NAME bs=1M status=progress
sudo mkfs.ext4 /dev/mapper/$MNT_NAME
sudo mkdir -p /mnt/$MNT_NAME
sudo mount /dev/mapper/$MNT_NAME /mnt/$MNT_NAME

cd /mnt/$MNT_NAME
sudo chown user:user . -R
```

## Share connected USB drive as network share

To share the USB drive to the network using samba, install samba and add the following configuration to `/etc/samba/smb.conf`:

```ini
[extbackup]
    comment = allow diskwriter user access to attached drive
    path = /mnt/extbackup
    browsable = yes
    writeable = yes
    guest ok = no
    force user = diskwriter
    directory mask = 0755
    create mask = 0644
    write list = diskwriter
```

Create a group where all users with write access are included and set the directory permissions:

```sh
# Make sure the group exists
sudo groupadd smbshare

# Add users to the group
sudo usermod -aG smbshare alice
sudo usermod -aG smbshare diskwriter

# Change folder group ownership
sudo chgrp smbshare /mnt/$MNT_NAME

# Give group write access + setgid so new files inherit the group
sudo chmod 2775 /mnt/$MNT_NAME
```

## Running the Backup

Finally, to actually run the backup, I recommend using `rsync` with various flags.
Depending on the data, you may want to use the `--delete` flag to ensure that files deleted from the source are also removed from the backup.
**Always be aware that this will permanently delete files on the destination!**

First, open the encrypted partition and mount it (e.g., on a Synology NAS):

```sh
export MNT_DEVICE=/dev/sda # adjust this to your device
export MNT_NAME=extbackup  # mapping handle name

# Open and mount the partition
sudo cryptsetup open $MNT_DEVICE $MNT_NAME
sudo mount /dev/mapper/$MNT_NAME /volume1/ext_backup/
```

Then, use `rsync` to copy your data:

```sh
# Sync application data (e.g. Immich libraries) with --delete
cd /volume1/ext_backup/immichlib
rsync -ra --progress --delete --include '/' --include 'library/***' --include 'profile/***' --include 'upload/***' --exclude '*' /volume1/photolib/ .

# Sync other backups without deleting historical files
rsync -ra --progress --include '/' --include 'backups/***' --exclude '*' /volume1/photolib/ .

# Sync standard folders
cd /volume1/ext_backup/
rsync -ra --progress /volume1/documents .
rsync -ra --progress /volume1/video .
```

After the backup is complete, securely unmount and power off the drive:

```sh
cd ~
sudo umount /volume1/ext_backup/
sudo cryptsetup close $MNT_NAME

# Power off the USB drive (may not work on Synology)
sudo udisksctl power-off -b $MNT_DEVICE
```