---
title: docker 基础指令
date: 2019-08-21 18:00:00
tags: docker
categories: DevOps
---

> 列举一些学习过程中常用到的指令

<!-- more -->
想要一次全记住很困难，而且每个指令都有很多的参数，可以再之后使用的时候强化记忆，这里暂时先列出一些常用到的指令，具体的参数可以通过--help了解。如docker run的详细参数
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run --help
Usage:  docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
Run a command in a new container
Options:
      --add-host list                  Add a custom host-to-IP mapping (host:ip)
  -a, --attach list                    Attach to STDIN, STDOUT or STDERR
      --blkio-weight uint16            Block IO (relative weight), between 10 and 1000, or 0 to disable (default 0)
      --blkio-weight-device list       Block IO weight (relative device weight) (default [])
      --cap-add list                   Add Linux capabilities
      --cap-drop list                  Drop Linux capabilities
      --cgroup-parent string           Optional parent cgroup for the container
      --cidfile string                 Write the container ID to the file
      --cpu-period int                 Limit CPU CFS (Completely Fair Scheduler) period
      --cpu-quota int                  Limit CPU CFS (Completely Fair Scheduler) quota
      --cpu-rt-period int              Limit CPU real-time period in microseconds
      --cpu-rt-runtime int             Limit CPU real-time runtime in microseconds
  -c, --cpu-shares int                 CPU shares (relative weight)
      --cpus decimal                   Number of CPUs
      --cpuset-cpus string             CPUs in which to allow execution (0-3, 0,1)
      --cpuset-mems string             MEMs in which to allow execution (0-3, 0,1)
...
```
这里就不详细赘述每一个指令的详细参数了，如果想了解可以参考https://www.runoob.com/docker/docker-command-manual.html

# 操作镜像
## 查看镜像仓库
```
docker images
```
## 拉取镜像
```
docker pull
```
## 运行镜像
```
docker run
```
## 删除镜像
```
docker rmi
```
## 镜像仓库
### 查询镜像
```
docker search
```
# 操作容器
## 运行容器
```
docker run
```
## 查看运行中的容器
```
docker ps
```
## 查看全部容器
```
docker ps -a
```
## 停止容器
```
docker stop container_id/names
```
## 启动容器
已经停止的容器可以重新启动
```
docker start container_id/names
```
也可以直接重启
```
docker restart 
```

## 删除容器
```
docker rm container_id/names
```
## 查看容器端口
```
docker port container_id/names
```
## 查看容器日志
```
docker logs [-f] container_id/names
```
## 查看容器进程
```
docker top container_id/names
```

## 查看容器/镜像 元数据
会返回一个JSON文件记录着Docker容器的配置和状态信息。
```
docker inspect container_id/names
```


# 镜像仓库加速
我是直接使用的阿里云的镜像仓库，如果你有阿里云账号的话，直接登录阿里云控制台，搜索“容器镜像服务”，最下面有一个镜像加速。

里面是有介绍各个操作系统的步骤的，我的是CentOS。

打开/etc/docker/daemon.json文件，如果没有的话可以先创建。
```
sudo mkdir -p /etc/docker
```
然后增加如下内容
```
{
  "registry-mirrors": ["https://ilisd4hk.mirror.aliyuncs.com"]
}
```
最后重启docker
```
sudo systemctl daemon-reload
sudo systemctl restart docker
```