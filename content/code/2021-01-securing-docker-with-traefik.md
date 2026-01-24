---
title: TODO
date: 2024
tags: [development]
author: anoff
resizeImages: true
draft: true
---



- traefik must be in the same network as the containers you want to expose
- if your container is not running on port 80 you need a load balancer to make it reachable under 80: ` - "traefik.http.services.grafana.loadBalancer.server.port=3000"`
- you can create nice subdomains to test locally `- "traefik.http.routers.grafana.rule=Host( ``grafana.localhost`` )"` # note the weird ticks ` 

- traefik routers need a service (unless specified with docker labels)
- dynamic and static config
- if you want to forward to local LAN hostnames your DNS might be unale to resolve it, use IPs instead or pass LAN DNS server
