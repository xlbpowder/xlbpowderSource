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
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -d -p 3306:3306 --privileged=true --name mymysql -v $PWD/mysql/conf.d:/etc/mysql/conf.d -v $PWD/mysql/mysql.conf.d:/etc/mysql/mysql.conf.d -v $PWD/mysql/logs:/logs -v $PWD/mysql/data:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=123456 mysql:5.5
11e8f339f568
```
这里我是直接学习了别人启动使用的参数
- -d 后台运行
- -p 3306:3306：将容器的 3306 端口映射到主机的 3306 端口。
- --privileged=true：容器内的root拥有真正root权限，否则容器内root只是外部普通用户权限
- --name 容器命名
- -v $PWD/mysql/conf:/etc/mysql/conf.d：将主机当前目录下的 /mysql/conf 挂载到容器的 /etc/mysql/conf.d。
- -v $PWD/mysql/mysql.conf.d:/etc/mysql/mysql.conf.d：将主机当前目录下的/mysql/mysql.conf.d 挂载到容器的 /mysql/mysql.conf.d。
- -v $PWD/logs:/logs：将主机当前目录下的 /mysql/logs 目录挂载到容器的 /logs。
- -v $PWD/data:/var/lib/mysql ：将主机当前目录下的/mysql/data目录挂载到容器的 /var/lib/mysql 。
- -e MYSQL_ROOT_PASSWORD=123456：初始化 root 用户的密码。

这里为什么要将logs、data、conf挂在到宿主机的硬盘呢，是因为容器的存储是与容器的生命周期有关的，如果该mysql所属的容器关闭或出现其他问题，可能会导致数据丢失，数据库对于数据十分敏感，所以可以使用这种方式解决docker容器数据持久化的问题。

mysql5.6的这个镜像的配置文件中有!includedir /etc/mysql/conf.d/ !includedir /etc/mysql/mysql.conf.d/，这两个路径就是上面挂载的路径。所以和平时修改my.cnf不同，只修改挂载卷目录下的配置文件也是可以达到同样效果的。

之后会单独学习下docker的存储相关的知识。

### 其他配置方式
关于配置，其实还可以通过标签（flags）传递至mysql进程。这样就可以脱离cnf配置文件，对容器进行弹性的定制。

比如，如果需要修改默认编码方式，将所有编码方式修改为utf8mb4，则可以用下面这行命令
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run --name mymysql -e MYSQL_ROOT_PASSWORD=123456 -d mysql:tag --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```
如果需要查看可用选项的完整列表，可以执行
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker run -it --rm mysql:tag --verbose --help
```

## 查看运行容器
查看下已经启动好了，现在可以通过外部客户端工具链接访问下看看了。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                    NAMES
11e8f339f568        mysql:5.5           "docker-entrypoint.s…"   6 hours ago         Up 6 hours          0.0.0.0:3306->3306/tcp   mymysql
```

因为我提前在/mysql/conf.d和/mysql/mysql.conf.d/配置四个配置文件，主要是客户端和服务端的编码格式的，所以先访问容器，查看下mysql的配置有没有生效。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#docker exec -it mymysql bash
root@1254821edc4c:/# mysql -uroot -p123456
Warning: Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 5
Server version: 5.6.45 MySQL Community Server (GPL)

Copyright (c) 2000, 2019, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show variables like '%char%';
+--------------------------+----------------------------+
| Variable_name            | Value                      |
+--------------------------+----------------------------+
| character_set_client     | utf8mb4                    |
| character_set_connection | utf8mb4                    |
| character_set_database   | utf8mb4                    |
| character_set_filesystem | binary                     |
| character_set_results    | utf8mb4                    |
| character_set_server     | utf8mb4                    |
| character_set_system     | utf8                       |
| character_sets_dir       | /usr/share/mysql/charsets/ |
+--------------------------+----------------------------+
8 rows in set (0.00 sec)
```
可以看出是已经生效的了。