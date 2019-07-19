---
title: ElasticSearch安装
date: 2019-07-17 17:00:00
tags:
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

