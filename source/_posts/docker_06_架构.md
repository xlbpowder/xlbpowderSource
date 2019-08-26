---
title: docker 架构
date: 2019-08-26 11:58:00
tags: docker
categories: DevOps
---

> 前段时间公司培训，运维大佬提供的材料，有列举出docker的基本架构，在学习docker和Kubernetes的时候，其实先学习内部架构和对象的话，更有助于提升对整体应用的理解。

<!-- more -->
## 概述
Docker 是一个应用程序开发、部署、运行的平台，使用 go 语言开发。相较于传统的主机虚拟化，Docker提供了轻量级的应用隔离方案，并且为我们提供了应用程序快速扩容、缩容的能力。

Docker依赖于LXC(Linux Containers)技术，充分利用了其中的Namespace这个内核级特性，实现了容器之间的资源隔离。本质上来看，每一个Docker容器就是宿主机进程，不同 Docker 容器就对应不同的宿主机进程，这样，不同容器（即不同进程）就可以采用 Namespace 资源隔离，使得每一个容器看起来都像是一个独立的小虚拟机

docker其它核心技术：

- cgroup：资源控制
- rootfs：文件系统隔离
- aufs：高级分层文件系统(Advanced Multi-layered unification filesytem)

## 架构
### 静态部件描述
Docker采用的是CS架构，包含了三个主要部分：dockerd守护进程、REST API接口层、cli接口层(管理容器、镜像、网络、存储等等)，docker client 通过Unix套接字或者网络接口访问 docker daemon，从而完成容器、镜像等内容的管理

![](/image/DevOps/docker_01.png)

### 流程描述
![](/image/DevOps/docker_02.png)

## 对象

### 镜像
镜像是一个用来构建容器的只读模版，通常一个镜像会依赖其他的镜像。例如我们编写的一个Node程序需要依赖Node环境，那在构建这个应用镜像时就需要依赖基础的Node镜像。

我们可以创建自己的镜像，也可以使用仓库中已经创建好的镜像。创建镜像需要创建一个Dockerfile文件。每个Dockerfile定义镜像文件中的一层，当定义发生变化的时候，只需要更新着一层的文件即可。

### 容器

容器是一个运行时状态下的镜像，通过docker命令我们可以创建、启动、停止、删除容器

> 启动我们的第一个容器：
```
docker run --rm hello-world
```

1.  如果本地没有hello-world镜像，那么首先拉取镜像
2.  自动创建一个容器，相当于命令dock container create
3.  Docker分配一块文件系统给容器
4.  Docker创建网络接口、分配网络地址
5.  启动容器，并且执行目标入口命令
6.  容器关闭并退出
7.  容器销毁

### 网络

Docker的网络子系统是可插拔的，支持bridge、host、overlay、macvlan、none等网络模式

*  bridge模式是Docker默认的网络设置，此模式会为每一个容器分配Network Namespace、设置IP等，并将主机上的Docker容器连接到docker0虚拟网桥上，docker0网桥由docker后台服务启动时创建，默认在172.17.0.0/16段每一个容器运行时会生成一对veth网络设备直连，再通过网桥使得同一个主机上的容器间可以相互通信
```
+-------------------------------------------------------------------------------+
|                                                                               |
|       +---------------------------------------------------------------+       |
|       |                           docker0                             |       |
|       +---------------------------------------------------------------+       |
|                             ↑               ↑                                 |
|.............................|...............|.................................|
|                             ↓               ↓                                 |
|        +----------+    +-----------+   +-----------+    +-----------+         |
|        |   vth2   |<-->|   veth1   |   |   veth3   |<-->|   veth4   |         |
|        +----------+    +-----------+   +-----------+    +-----------+         |
|             ↑                                                 ↑               |
|             +-------------------------------------------------+               |
|        172.16.17.2                                       172.16.17.3          |
+-------------------------------------------------------------------------------+
```

* host模式下，容器会共享主机的network namespace，所以拥有主机的全部网络通信能力，通常用于docker容器测试

### 存储

默认情况下，容器中的应用生成的所有文件都存放在一个可写的容器层，意味着这些数据的生命周期和容器保持一致，这些文件与容器高度关联，因此会带来下面几个问题：

* 不能在宿主机上很方便地访问容器中的文件
* 无法在多个容器之间共享数据
* 当容器删除时，容器中产生的数据将丢失

为此，Docker提供了两种方案解决数据问题：
* bind mount volumes：将host上已存在的目录或文件挂载到容器中使用
* docker managed volumes：docker自己管理的数据卷存储

对比一下两种方式各自的特点：

- | bind mount Volumes | docker managed volumes
- | - | -
volume 位置 | 可任意指定 | /var/lib/docker/volumes/...
对已有mount point 影响 | 隐藏并替换为 volume | 原有数据复制到 volume<
是否支持单个文件 | 支持 | 不支持，只能是目录
权限控制 | 可设置为只读，默认为读写权限 |无控制，均为读写权限
移植性 | 移植性弱，与 host path 绑定 | 移植性强，无需指定 host 目录

不管使用哪种方式，容器内看起来都是一样的，或者作为一个文件夹存在、或者作为一个文件存在。

上图说明了不同方式的区别，Volumes 是存在本地文件系统中的一部分，其他应用程序不能对这个文件系统进行修改，Linux下在/var/lib/docker/volumes。这是数据持久化的最好方案。Bind Mount 允许将主机中任何位置的数据挂载，这些数据的读写没有收到保护。tmps是存储在主机内存中的数据。

## 常用操作
### cli
#### 下载镜像
```
docker pull urlpath:[tag]
```
#### 查询镜像
```
docker images
```
#### 运行镜像（启动容器）
```
docker run [-d] \
  [--rm] \
  [--name {container_name}] \
  [-p {hostport:containerport}] \
  [-v {hostpath:containerpath}:[ro] ] \
  [-e "key=value"] \
  {image_name:[tag]}
```

* -d可以指定当前容器在后台运行，释放当前终端控制台不阻塞，用户可以继续往下输入命令
* --rm可以指定容器停止即刻销毁删除
* -p可以指定主机和容器的端口映射，可以重复指定多个映射
* -v可以指定主机的存储目录挂载至容器中，可以重复指定多个挂载，默认读写，ro选项可以指定只读保护数据
* * hostpath为绝对路径：开户bind mount模式
* * hostpath为一个变量或连同“:”一起省略：开户docker managed模式
* * 使用hostpath变量时只能为：[a-zA-Z0-9][a-zA-Z0-9_.-]
* -e可以预置一些环境变量供容器使用，可以重复指定多个环境变量

#### 构建镜像（打包）
```
docker build -t {image_name}:[tag] [Dockerfile目录]
```

#### 查询容器
```
docker ps [-a]
docker inspect {container_name|container_id}
```

#### 进入容器
```
docker exec -ti {container_name|container_id} sh/bash ...
```

#### 查看容器日志
```
docker logs {container_name|container_id} [--tail n] [-f]
```

#### 查看网络
```
docker network ls
docker network inspect {network_name}
```

#### 查看存储
```
docker volume ls
docker volume inspect {volume_name}
```
> 注：docker volume只能查看docker managed volumes，对于bind mount volumes只能通过docker inspect来查看

### Restful api
操作 | API
- | -
查询镜像 | curl -X GET http://{IP}:{PORT}/images/json
查询容器 | curl -X GET http://{IP}:{PORT}/containers/json
启动容器 | curl -X POST http://{IP}:{PORT}/images/create?fromImage=hello-world:lates</td>

## 参考文档
[https://yeasy.gitbooks.io/docker_practice/content/](https://yeasy.gitbooks.io/docker_practice/content/)