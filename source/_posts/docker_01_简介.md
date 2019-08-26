---
title: docker 简介
date: 2019-03-21 10:00:00
tags: docker
categories: DevOps
---

> 大概一年前接触微服务后就听说过容器化、docker这些名词了，草草了解了之后一直没有实践开始学习过，对于DevOps而言，容器化、以及容器编排都是非常重要的技术，现在开始着手学习并且记录下学习的笔记。

<!-- more -->
## 什么是Docker
Dcoker是一个开源的应用容器引擎，基于Go语言并遵从Apache2.0协议开源。

Docker可以轻松的为任何应用创建一个轻量的、可移植的、自给自足的容器。开发者进行编写后测试通过的容器，可以批量的在生产环境中部署，包括VMs（虚拟机）、bare metal、OpenStack集群和其他基础应用平台。

## 什么是容器
其实容器是一种虚拟化的方案。容器是完全使用沙箱机制，相互之间不会有任何接口，最重要的是容器的性能开销相比传统的虚拟机性能开销低。

## Docker的好处
1. 更快的交付和部署

    对于开发、运维人员来说，最希望的就是一次创建和配置，可以在任意环境运行。

    开发人员可以构建标准的镜像，开发完成后，运维人员可以直接使用这个镜像启动一个应用容器。Docker可以快速创建容器，快速迭代应用程序，大量的节省了开发、测试、运维部署的时间。

2. 更高效的虚拟化

    Docker容器的运行不需要额外的Hypervisor支持，他是内核级的虚拟化，因此可以实现更高的性能和效率。

## 相关概念
Docker是CS架构的应用，主要以下几种组成：
* Docker daemon： 运行再宿主机上，Docker的守护进程，用户通过Docker client（docker命令行）进行交互
* Docker client：Docker的命令行工具，是用户使用Docker的主要途径，Docker client也可以通过socket或者RESTful api访问远程的Docker deamon
* Docker image：Docker镜像，是只读的，镜像中包含有需要运行的文件，通过镜像来创建container，一个镜像可以运行多个container；镜像可以通过Dockerfile创建，也可以通过Docker hub/registry下载官方或者个人创建好的镜像。
* Docker container：容器是docker运行的组件，也是一个程序的最小单元。容器是一个隔离的环境，多个容器之间不会互相影响，来保证容器中的程序运行在一个相对安全独立的环境中
* Docker hub/registry：共享和管理Docker镜像，用户可以上传或者下载镜像，官方地址位https://registry.hub.docker.com/，也可以搭建私有的Docker registry

总结：镜像就相当于打包好的应用，镜像启动了之后运行在容器中，而通过dockerfile制作或者下载docker镜像后可以放在仓库中存储。


## 参考资料
* http://www.runoob.com/docker/docker-tutorial.html
* http://www.docker.org.cn/