---
title: docker ElasticSearch
date: 2019-09-05 12:00:00
tags: docker
categories: DevOps
---

> 最近公司项目组要使用ElasticSearch，自己先学习一下，记录通过docker搭建的过程。

<!-- more -->

elasticsearch官方镜像会暴露9200 9300两个默认的http端口，可以通过此端口进行访问
- 9200: 对外提供服务的api使用端口
- 9300: 内部通信端口，包括心跳、集群内部信息同步

使用数据卷挂载自定义配置文件，以及进行存储数据持久化。分别挂载至：
- 配置文件: /usr/share/elasticsearch/config
- 存储数据: /usr/share/elasticsearch/data

# elasticsearch目录结构
```
bin：可执行文件，运行es的命令
config：配置文件目录
 config/elasticsearch.yml：ES启动基础配置
 config/jvm.options：ES启动时JVM配置
 config/log4j2.properties：ES日志输出配置文件
lib：依赖的jar
logs：日志文件夹
modules：es模块
plugins：可以自己开发的插件
data：我们自己创建的，存放es存储文件
```
## 配置文件
所以我们挂载的elasticsearch主要有一下几个配置文件：
* config/elasticsearch.yml   主配置文件
* config/jvm.options         jvm参数配置文件
* cofnig/log4j2.properties   日志配置文件

## 运行elasticsearch镜像
我是直接拉取了最新的elasticsearch:7.2.0
```
[root@iZwz91w0kp029z0dmueicoZ /root/elasticsearch]#docker run -d -p 9200:9200 -p 9300:9300 --name es -v $PWD/config:/usr/share/elasticsearch/config -v $PWD/data:/usr/share/elasticsearch/data elasticsearch:7.2.0
f22048b5909fe4ddb4c1a72bc30c375def5595c075eedcf8801bfd13bc06fae3
[root@iZwz91w0kp029z0dmueicoZ /root/elasticsearch]#docker ps -a
CONTAINER ID        IMAGE                                                 COMMAND                  CREATED             STATUS                       PORTS                    NAMES
f22048b5909f        elasticsearch:7.2.0                                   "/usr/local/bin/dock…"   44 seconds ago      Exited (1) 42 seconds ago                             es
```

直接run发现没有启动成功，这时候需要查看下启动日志
```
ERROR: [1] bootstrap checks failed
[1]: the default discovery settings are unsuitable for production use; at least one of [discovery.seed_hosts, discovery.seed_providers, cluster.initial_master_nodes] must be configured
```
大概的意思就是：默认发现设置不适合生产使用； 必须配置[discovery.seed_hosts，discovery.seed_providers，cluster.initial_master_nodes]中的至少一个。

* discovery.seed_hosts
* discovery.seed_providers
* cluster.initial_master_nodes