---
title: ElasticSearch 安装
date: 2019-07-17 17:00:00
tags: ElasticSearch
categories: Elastic Stack
---

Elasticsearch的安装部署、以及简单配置。

<!-- more -->

## 运行环境
- 安装并配置JDK，设置$JAVA_HOME。
- 各个版本对Java的依赖
    - Elasticsearch 5，需要Java8以上版本
    - Elasticsearch 6.5开始支持Java11
    - Elasticsearch 7.0开始，内置了Java环境

## 安装
可以直接访问[Elasticsearch官网](https://www.elastic.co/cn/downloads/elasticsearch)进行下载。同时，Elastic官方也提供docker镜像，通过docker进行快速部署。

## Elasticsearch的文件目录结构
目录 | 配置文件 | 描述
-- | -- | --
bin     |  | 脚本文件，包括启动elasticsearch，安装插件。运行统计数据等
config  | elasticsearch.yml | 集群配置文件，user、role、based相关配置
JDK     |  | Java运行环境
data    | path.data | 数据文件
lib     |  | Java相关类库
logs    | path.log | 日志文件
modules |  | 包含所有ES模块
plugins |  | 包含所有已安装插件

## 安装错误解决方法汇总
1. seccomp unavailable 错误
解决方法：elasticsearch.yml 配置

bootstrap.memory_lock: false

bootstrap.system_call_filter: false

2. max file descriptors [4096] for elasticsearch process likely too low, increase to at least [65536]

解决方法：修改 /etc/security/limits.conf，配置：

hard nofile 80000

soft nofile 80000

3. max virtual memory areas vm.max_map_count [65530] is too low

解决方法：修改 /etc/sysctl.conf，添加 ：

vm.max_map_count = 262144

然后 sysctl -p 生效

4. the default discovery settings are unsuitable...., last least one of [....] must be configured

解决方法：elasticsearch.yml 开启配置：

node.name: node-1

cluster.initial_master_nodes: ["node-1"]