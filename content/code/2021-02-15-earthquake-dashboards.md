---
title: TODO
date: 2024
tags: [development]
author: anoff
resizeImages: true
draft: true
---


- telegraf -> HTTP crawl, process, influx
- grafana map plugin
- influx query formatting


```toml
# earthquake data

[[inputs.http]]
  urls = [
    "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_day.geojson",
  ]
  # https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&minmagnitude=1&starttime=2010-01-01&endtime=2010-04-01
  #"https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/1.0_month.geojson"
  timeout = "10s"
  interval = "10m"
  data_format = "json"
  name_override = "earthquakes_usgs"
  json_query = "features"
  json_time_key = "properties_time"
  json_time_format = "unix_ms"
  tag_keys = [
    "properties_magType",
    "properties_type",
    "properties_status",
    "properties_alert"
  ]
  json_string_fields = ["properties_place", "properties_title"]
[[processors.rename]]
  namepass = ["earthquakes_usgs"]
  [[processors.rename.replace]]
    field = "properties_updated"
    dest = "time_updated"
  [[processors.rename.replace]]
    field = "properties_mag"
    dest = "magnitude"
  [[processors.rename.replace]]
    tag = "properties_magType"
    dest = "magType"
  [[processors.rename.replace]]
    tag = "properties_type"
    dest = "type"
  [[processors.rename.replace]]
    field = "geometry_coordinates_0"
    dest = "g.long"
  [[processors.rename.replace]]
    field = "geometry_coordinates_1"
    dest = "g.lat"
  [[processors.rename.replace]]
    field = "geometry_coordinates_2"
    dest = "g.elevation"
  [[processors.rename.replace]]
    field = "properties_place"
    dest = "place"
  [[processors.rename.replace]]
    field = "properties_title"
    dest = "title"
  [[processors.rename.replace]]
    tag = "properties_alert"
    dest = "alert"
  [[processors.rename.replace]]
    tag = "properties_status"
    dest = "status"
[[processors.date]]
  namepass = ["earthquakes_usgs"]
  tag_key = "date_str"
  date_format = "2006-01-02"
```