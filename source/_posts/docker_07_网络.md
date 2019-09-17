---
title: docker 网络模式
date: 2019-08-28 10:41:00
tags: docker
categories: DevOps
---

> 上一篇分享的文章中有简单的讲到docker内部的网络模式，但很多点并没有讲的很详细，这篇就专门讨论学习一下docker的网络模式。

<!-- more -->

这里提到的docker的网络模式，指的是docker deamon与docker启动的容器实例的网络模式。不是docker与宿主机的网络模式。
## docker network
首先我们可以通过docker network了解下相关指令有什么东西。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker network COMMAND --help

Usage:  docker network COMMAND

Manage networks

Commands:
  connect     Connect a container to a network
  create      Create a network
  disconnect  Disconnect a container from a network
  inspect     Display detailed information on one or more networks
  ls          List networks
  prune       Remove all unused networks
  rm          Remove one or more networks

```
其实这里都有解释每一个指令的
- connect: 建立容器网络链接
- disconnect: 断开容器网络链接
- create: 创建一个自定义网
- inspect: 查看网络详情
- ls: 列出网络信息
- prune: 移除全部未使用的网络
- rm: 移除一个或多个网络

### ls
先看下docker network ls
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker network ls
NETWORK ID          NAME                DRIVER              SCOPE
dd3610923996        bridge              bridge              local
2499a5d8180c        host                host                local
68083386230a        none                null                local
```
