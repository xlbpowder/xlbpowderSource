---
title: docker ElasticSearch
date: 2019-09-05 12:00:00
tags: docker
categories: DevOps
---

> 最近公司项目组要使用ElasticSearch，自己先学习一下，记录通过docker搭建的过程。

<!-- more -->

elasticsearch官方镜像会暴露9200 9300两个默认的http端口，可以通过此端口进行访问
- 9200: 对外提供服务的api使用端口
- 9300: 内部通信端口，包括心跳、集群内部信息同步

使用数据卷挂载自定义配置文件，以及进行存储数据持久化。分别挂载至：
- 配置文件: /usr/share/elasticsearch/config
- 存储数据: /usr/share/elasticsearch/data
