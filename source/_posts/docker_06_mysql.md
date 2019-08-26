---
title: docker 安装MySql
date: 2019-08-22 11:00:00
tags: docker
categories: DevOps
---

> 最近被安排做数据迁移，因为刚换电脑，正好需要装一个mysql，想着正好直接用docker装一个试试

<!-- more -->

需要先获取mysql的docker镜像，获取的方式有两种，一种是直接获取docker hub上别人构建好的镜像，另一种是通过dockerfile构建镜像。

dockerfile之后会单独学习一下，这里就说下通过官方提供的docker镜像构建。

## 获取镜像
在docker hub上查找mysql的镜像。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker search mysql
NAME                              DESCRIPTION                                     STARS               OFFICIAL            AUTOMATED
mysql                             MySQL is a widely used, open-source relation…   8511                [OK]
mariadb                           MariaDB is a community-developed fork of MyS…   2951                [OK]
mysql/mysql-server                Optimized MySQL Server Docker images. Create…   628                                     [OK]
centos/mysql-57-centos7           MySQL 5.7 SQL database server                   62
centurylink/mysql                 Image containing mysql. Optimized to be link…   61                                      [OK]
mysql/mysql-cluster               Experimental MySQL Cluster Docker images. Cr…   50
deitch/mysql-backup               Automated and scheduled mysql database dumps…   41                                      [OK]
tutum/mysql                       Base docker image to run a MySQL database se…   33
bitnami/mysql                     Bitnami MySQL Docker Image                      31                                      [OK]
schickling/mysql-backup-s3        Backup MySQL to S3 (supports periodic backup…   28                                      [OK]
linuxserver/mysql                 A Mysql container, brought to you by LinuxSe…   21
prom/mysqld-exporter                                                              20                                      [OK]
centos/mysql-56-centos7           MySQL 5.6 SQL database server                   15
circleci/mysql                    MySQL is a widely used, open-source relation…   14
mysql/mysql-router                MySQL Router provides transparent routing be…   12
arey/mysql-client                 Run a MySQL client from a docker container      10                                      [OK]
openshift/mysql-55-centos7        DEPRECATED: A Centos7 based MySQL v5.5 image…   6
imega/mysql-client                Size: 36 MB, alpine:3.5, Mysql client: 10.1.…   6                                       [OK]
yloeffler/mysql-backup            This image runs mysqldump to backup data usi…   6                                       [OK]
fradelg/mysql-cron-backup         MySQL/MariaDB database backup using cron tas…   4                                       [OK]
genschsa/mysql-employees          MySQL Employee Sample Database                  2                                       [OK]
ansibleplaybookbundle/mysql-apb   An APB which deploys RHSCL MySQL                1                                       [OK]
jelastic/mysql                    An image of the MySQL database server mainta…   1
monasca/mysql-init                A minimal decoupled init container for mysql    0
widdpim/mysql-client              Dockerized MySQL Client (5.7) including Curl…   0                                       [OK]
```

因为我们使用的mysql是5.5版本的，所以直接就pull 5.5版本的
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker pull mysql:5.5
5.5: Pulling from library/mysql
743f2d6c1f65: Pull complete
3f0c413ee255: Pull complete
aef1ef8f1aac: Pull complete
f9ee573e34cb: Pull complete
3f237e01f153: Pull complete
03da1e065b16: Pull complete
04087a801070: Pull complete
7efd5395ab31: Pull complete
1b5cc03aaac8: Pull complete
2b7adaec9998: Pull complete
385b8f96a9ba: Pull complete
Digest: sha256:12da85ab88aedfdf39455872fb044f607c32fdc233cd59f1d26769fbf439b045
Status: Downloaded newer image for mysql:5.5
```
这里如果下载的很慢，可以参考上一节文末讲到的如果修改公共仓库地址的那个。

现在看下本地镜像仓库，已经存在了。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
mysql               5.6                 732765f8c7d2        8 days ago          257MB
mysql               5.5                 d404d78aa797        3 months ago        205MB
hello-world         latest              fce289e99eb9        7 months ago        1.84kB
ubuntu              15.10               9b9cb95443b5        3 years ago         137MB
training/webapp     latest              6fae60ef3446        4 years ago         349MB
```

## 使用镜像
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -p 3306:3306 --name mymysql -v $PWD/conf:/etc/mysql/conf.d -v $PWD/logs:/logs -v $PWD/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:5.5
11e8f339f568
```
这里我是直接学习了别人启动使用的参数
- -p 3306:3306：将容器的 3306 端口映射到主机的 3306 端口。
- -v $PWD/conf:/etc/mysql/conf.d：将主机当前目录下的 conf/my.cnf 挂载到容器的 /etc/mysql/my.cnf。
- -v $PWD/logs:/logs：将主机当前目录下的 logs 目录挂载到容器的 /logs。
- -v $PWD/data:/var/lib/mysql ：将主机当前目录下的data目录挂载到容器的 /var/lib/mysql 。
- -e MYSQL_ROOT_PASSWORD=123456：初始化 root 用户的密码。

## 查看运行容器
查看下已经启动好了，现在可以通过外部客户端工具链接访问下看看了。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
11e8f339f568        mysql:5.5           "docker-entrypoint.s…"   6 hours ago         Up 6 hours          0.0.0.0:3306->3306/tcp   mymysql
```