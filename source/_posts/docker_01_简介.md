---
title: docker简介
date: 2019-03-21 10:00:00
tags:
categories: docker
---

> 大概一年前接触微服务后就听说过容器化、docker这些名词了，草草了解了之后一直没有实践开始学习过，对于DevOps而言，容器化、以及容器编排都是非常重要的技术，现在开始着手学习并且记录下学习的笔记。

<!-- more -->
### 什么是Docker
docker的容器，其实就是虚拟化技术的一种。

### 什么是容器
是一种虚拟化的方案，传统的是通过中间层，将一台或者多台机器，


## 相关概念
Docker是CS架构的应用，主要以下几种组成：
* Docker daemon： 运行再宿主机上，Docker的守护进程，用户通过Docker client（docker命令行）进行交互
* Docker client：Docker的命令行工具，是用户使用Docker的主要途径，Docker client也可以通过socket或者RESTful api访问远程的Docker deamon
* Docker image：Docker镜像，是只读的，镜像中包含有需要运行的文件，通过镜像来创建container，一个镜像可以运行多个container；镜像可以通过Dockerfile创建，也可以通过Docker hub/registry下载官方或者个人创建好的镜像。
* Docker container：容器是docker运行的组件，也是一个程序的最小单元。容器是一个隔离的环境，多个容器之间不会互相影响，来保证容器中的程序运行在一个相对安全独立的环境中
* Docker hub/registry：共享和管理Docker镜像，用户可以上传或者下载镜像，官方地址位https://registry.hub.docker.com/，也可以搭建私有的Docker registry

总结：镜像就相当于打包好的应用，镜像启动了之后运行在容器中，而通过dockerfile制作或者下载docker镜像后可以放在仓库中存储。

