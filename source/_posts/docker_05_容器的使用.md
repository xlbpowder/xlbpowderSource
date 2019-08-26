---
title: docker 容器使用
date: 2019-08-21 17:00:00
tags: docker
categories: DevOps
---

>

<!-- more -->

# 运行WEB应用
## 拉取测试镜像
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker pull training/webapp
Using default tag: latest
latest: Pulling from training/webapp
e190868d63f8: Pull complete
909cd34c6fd7: Pull complete
0b9bfabab7c1: Pull complete
a3ed95caeb02: Pull complete
10bbbc0fc0ff: Pull complete
fca59b508e9f: Pull complete
e7ae2541b15b: Pull complete
9dd97ef58ce9: Pull complete
a4c1b0cb7af7: Pull complete
Digest: sha256:06e9c1983bd6d5db5fba376ccd63bfa529e8d02f23d5079b8f74a616308fb11d
Status: Downloaded newer image for training/webapp:latest
```

## 运行镜像
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -d -P training/webapp python app.py
76fd8c2738182275dc0d6ff1a8b7c72caa0d7acc96fa640375d1f967cce3b0d1
```
- -d: 让容器在后台运行
- -P: 将容器内部使用的网络端口映射到我们使用的主机上

## 查看运行中的容器
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                     NAMES
76fd8c273818        training/webapp     "python app.py"     16 minutes ago      Up 16 minutes       0.0.0.0:32768->5000/tcp   dreamy_burnell
```
- PORTS 0.0.0.0:32768->5000/tcp，5000是容器监听的端口，映射到宿主机的32768端口。

这时候通过docker宿主机的ip:32768就可以直接访问了

## 运行镜像并修改监听端口
也可以通过-p参数设置不同的端口
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -d -p 5000:5000 training/webapp python app.py
1d7a7e33cdf674a0374e908613f1bd0ebe08a649d2b681e2afab6d25550ca6ba
```

再查看下
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                     NAMES
1d7a7e33cdf6        training/webapp     "python app.py"     5 seconds ago       Up 4 seconds        0.0.0.0:5000->5000/tcp    vigorous_murdock
76fd8c273818        training/webapp     "python app.py"     31 minutes ago      Up 31 minutes       0.0.0.0:32768->5000/tcp   dreamy_burnell
```

这时候通过ip:5000也是可以访问的

## 观察容器状态
### 网络端口
这时候可以先查下网络端口映射
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker port 1d7a7e33cdf6
0.0.0.0:5000->5000/tcp
[root@iZwz91w0kp029z0dmueicoZ /root]#docker port 76fd8c273818
0.0.0.0:32768->5000/tcp
```

### 应用程序日志
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker logs 006fdd129e49
 * Running on http://0.0.0.0:5000/ (Press CTRL+C to quit)
```
也可以加参数-f追踪查看最新打印的日志。

### 查看容器进程
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker top 006fdd129e49
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                30384               30366               0                   10:15               ?                   00:00:00            python app.py
```

## 停止容器
我们可以通过docker stop container_id来停止指定的容器。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker stop 1d7a7e33cdf6
```
这时再通过docker ps发现5000端口的webapp的容器已经没有了。