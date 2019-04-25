---
title: linux命令笔记
date: 2019-03-20 10:00:00
tags:
categories: linux
---

> 一直都在说要好好学习下linux命令，最近在学习docker的时候真的发现自己linux的能力太差了，基础也不行，暂时先记下学习docker过程中用到的一些命令行。

<!-- more -->

首先要先了解下自己的linux系统的操作版本，预防之后遇到的很多坑。

## 查看Linux系统版本与内核版本
* 查看内核版本的方式
1. uname -a
```
[root@iZwz91w0kp029z0dmueicoZ /root]#uname -a
Linux iZwz91w0kp029z0dmueicoZ 3.10.0-693.2.2.el7.x86_64 #1 SMP Tue Sep 12 22:26:13 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```
2. cat /proc/version
```
[root@iZwz91w0kp029z0dmueicoZ /root]#cat /proc/version
Linux version 3.10.0-693.2.2.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC) ) #1 SMP Tue Sep 12 22:26:13 UTC 2017
```

* 查看Linux系统版本命令
1. lsb_release
```
[root@iZwz91w0kp029z0dmueicoZ /root]#lsb_release -a
LSB Version:    :core-4.1-amd64:core-4.1-noarch
Distributor ID: CentOS
Description:    CentOS Linux release 7.4.1708 (Core)
Release:        7.4.1708
Codename:       Core
```
2. cat /etc/redhat-release
```
[root@iZwz91w0kp029z0dmueicoZ /root]#cat /etc/redhat-release
CentOS Linux release 7.4.1708 (Core)
```

还查到了一个说是cat /etc/issue但是这个文件打开后没什么东西，不清楚是不是我这个系统有问题。。

我这个是一个阿里云的服务器，系统内核是CentOS linux 7.4.1708 x86 64位，linux版本Linux version 3.10.0。


## 用户
今天在记笔记的时候，看到有的会是$ xxx的指令，而有的是# xxx，后来查了下才知道，原来root用户就会是#开头，而非root用户则是$开头。

一直用root用户其实也是有一定风险的，当然个人使用的话是没问题的，但是如果有多人使用，root用户权限会非常大，并不安全。所以先学习了下如何创建用户，并且分配相关权限。

