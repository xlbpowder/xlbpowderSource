---
title: docker 安装
date: 2019-03-22 10:00:00
tags: docker
categories: DevOps
---

> 

<!-- more -->
Docker目前可以在红帽企业版7(Red Hat Enterprise Linux 7)版本下面安装。

Docker需要一个64位系统的红帽系统，内核的版本必须大于3.10。


我用的是阿里云的云服务器，CentOS系统。

先更新现有的yum包
``` linux
$ sudo yum update
```

## 安装docker
docker其实有很多种安装方式，看下执行docker安装脚本
``` linux
$ curl -sSL http://get.docker.com/ | sh
```
安装后可以先用
``` linux
$ docker version
```
可以看到docker服务已经安装好了，但是还未启动
``` linux
Client:
 Version:           18.09.4
 API version:       1.39
 Go version:        go1.10.8
 Git commit:        d14af54266
 Built:             Wed Mar 27 18:34:51 2019
 OS/Arch:           linux/amd64
 Experimental:      false
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?
```

## Hello World
我第一次尝试的时候，是按照docker中文网的教程进行的，直接运行了helloworld
``` linux
$ docker run hello-world
```
``` linux
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
1b930d010525: Pull complete
Digest: sha256:2557e3c07ed1e38f26e389462d03ed943586f744621577a99efb77324b0fe535
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

```
其实是可以看到，提示未找到hello-world:latest的镜像在本地，docker默认进行了pulling from library/hello-world的操作，pull image完成后，进行了docker run。

如果需要单独获取镜像的话
``` linux
$ docker pull library/hello-world
```
上面就是获取image的命令，library/hello-world是image在仓库中的位置，其中library是image文件所在的组，hello-world是image文件的名字。

获取成功后，就可以在宿主机（本机）看到这个image了。
``` linux
[root@iZwz91w0kp029z0dmueicoZ /root]# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
hello-world         latest              fce289e99eb9        3 months ago        1.84kB
```
## 卸载docker
再简单说下卸载docker
``` linux
$ sudo yum remove docker
```

卸载docker后，/var/lib/docker/目录下会保留原docker的镜像、网络、存储卷等文件，如果需要安装全新的docker，还需要删除/var/lib/docker/目录。
``` linux
$ rm -fr /var/lib/docker/
```

## 好东西
如果没有主机的，或者觉得安装虚拟机太麻烦的朋友，可以再daocloud.io玩下胶囊机，虽然只能用120分钟，但是简单入门玩下还是ok的。

## 参考资源
* http://tech.meituan.com/
