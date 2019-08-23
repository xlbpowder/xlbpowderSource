---
title: docker Hello World
date: 2019-08-21 10:00:00
tags:
categories: docker
---

有段时间没更新了，前段时间出去玩了一圈，回来接着学习docker。

上一节有简单的讲到docker run运行hellVo world，这次详细的讲解下docker的一些基础命令

<!-- more -->
# Hello World
上次是直接使用了docker run hello-world运行了hello world，但这仅仅是打印了hello world字符串。这次我们换种方式。

```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run ubuntu:15.10 /bin/echo "Hello world"
Unable to find image 'ubuntu:15.10' locally
15.10: Pulling from library/ubuntu
7dcf5a444392: Pull complete
759aa75f3cee: Pull complete
3fa871dc8a2b: Pull complete
224c42ae46e7: Pull complete
Digest: sha256:02521a2d079595241c6793b2044f02eecf294034f31d6e235ac4b2b54ffc41f3
Status: Downloaded newer image for ubuntu:15.10
Hello world
```
这里逐个参数的讲解：
- docker: Docker 的二进制执行文件。
- run: 与前面的 docker 组合来运行一个容器。
- ubuntu:15.10 指定要运行的镜像，Docker首先从本地主机上查找镜像是否存在，如果不存在，Docker 就会从镜像仓库 Docker Hub 下载公共镜像。
- /bin/echo "Hello world": 在启动的容器里执行的命令

这里完整的执行逻辑是：Docker以ubuntu15.10镜像创建一个新容器，仓库中不存在镜像，提示了"Unable to find image 'ubuntu:15.10' locally"，所以先pull了镜像，然后在容器里执行 bin/echo "Hello world"，然后输出结果。

# 与容器进行交互
我们通过docker的两个参数 -i -t，让docker运行的容器实现"对话"的能力

```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -i -t ubuntu:15.10 /bin/bash
root@61124b8b51b1:/#
```
- -t: 在新容器内指定一个伪终端或终端。
- -i: 允许你对容器内的标准输入 (STDIN) 进行交互。

此时我们就相当于进入了一个ubuntu15.10系统的容器内部的控制台。这时候我们可以使用一些命令来查看容器的情况，如ls、cat /proc/version

```
root@61124b8b51b1:/# cat /proc/version
Linux version 3.10.0-693.2.2.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat #1 SMP Tue Sep 12 22:26:13 UTC 2017
root@61124b8b51b1:/# ls -lrt
total 64
```

# 后台运行容器
我们用下面这条命令创建一个容器
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -d ubuntu:15.10 /bin/sh -c "while true; do echo hello world;sleep 1; done"
4d8f66bb1369a8d0b74b9b23bb6dcc86bc85fd638eb9801f21e99734747f4ab1
```
这里并没有响应Hello world，而是返回了一堆字符串，其实这个字符串是这个正在运行的容器ID，我们可以通过容器的ID对该容器做一些列的操作。

这里同上面一样，运行了一个ubuntu:15.10的容器，并且运行了shell脚本，循环打印hello world，保持容器一直是有事情做的。

# 查看容器
我们可以使用docker ps来查看当面在运行的容器列表
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
4d8f66bb1369        ubuntu:15.10        "/bin/sh -c 'while t…"   3 seconds ago       Up 2 seconds                            modest_chatelet
```
- CONTAINER ID: 容器ID
- NAMES: 自动生成的容器别名

我们可以通过container id和names来控制某个容器

## 查看容器日志
通过container id来查看
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker logs 4d8f66bb1369
hello world
hello world
hello world
hello world
hello world
```

通过names来查看
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker logs modest_chatelet
hello world
hello world
hello world
hello world
```

# 停止容器
我们可以使用docker stop来停止容器，同样通过容器id或别名。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker stop modest_chatelet
modest_chatelet
```
然后我们再查看一次容器的列表

```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
[root@iZwz91w0kp029z0dmueicoZ /root]#
```
列表列现在已经没有了任何正在运行的容器

我们可以重复上面的操作再创建一个容器，然后使用容器ID停止一次，也是可以的。

# 参考资料
* https://www.runoob.com/docker/docker-hello-world.html