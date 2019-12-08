---
title: ElasticSearch相关基础概念
date: 2019-12-09 13:00:00
tags: ElasticSearch
categories: Elastic Stack
---

最近一直忙于工作、出差，一直没有更新内容，还是继续学习了一些Elasticsearch的知识，简单的记录一下

<!-- more -->

# 文档Document
Elasticsearch是面向文档的，文档是所有可搜索数据的最小单位

那什么是文档，可以根据不同的业务场景进行划分，比如：
- 日志文件中的日志项
- 一部电影、一张唱片的详细信息
- 一篇PDF文档的具体内容
- 等等

文档会被序列化为JSON格式，保存在Elasticsearch中
- JSON对象格式
- 每个JSON对象的属性都有对应的类型（数值、字符串、布尔类型、日期、数组等等

每一个文档都会有一个Unique ID，生成方式有两种：
- 指定文档ID
- ES自动生成

## JSON文档
一篇文档包含一系列的字段，类似数据库表中的一行记录。

JSON文档，格式灵活，不需要进行预先的格式定义。
- 字段的类型可以指定，或者让ES进行自动推算
- 支持数据、嵌套

## 文档的元数据
元数据，用于标注文档的相关基础信息。
- _index 文档所属的索引名
- _type 文档所属的类型名
- _id 文档的唯一标识
- _source 文档的原始JSON数据
- _all 整合所有的字段内容（在之后的版本已经被废除，原本是用于对所有的文档进行检索
- _version 版本号，用于解决多个相同文档的冲突问题
- _score 相关性分数

# 索引Index
索引是文档的容器，是一类文档的结合
- index体现了逻辑空间的概念：每个索引都有自己的Mapping定义，用于定义包含的文档的字段名和字段类型。
- shard 体现了物理空间的概念：索引中的数据分散在shard上。

可以对index设置mapping和setting
- mapping 定义文档字段的类型
- setting 定义不同的数据分布

## 索引在Elasticsearch中的语义
由于索引在不同的上下文中语义是不同的
- 名词 在es的基础概念中，索引是类文档的集合
- 动词 保存文档到es的过程也叫索引（indexing）
抛开es的名词概念，通常我们谈论到索引，一般指的是B树索引、倒排索引等，与ES中的索引是不同的概念

## Type
在7.0版本之前，一个index可以设置多个Types。但是在6.0开始，Type已经被废除不被使用了。一个索引只能创建一个Type "_doc"。

# 与RDBMS（关系型数据库）类比
进行了一个大概的类比

RDBMS | Elasticsearch
-- | --
table | index(type)
row | document
column | field
schema | mapping
SQL | DSL

与传统的关系型数据库的区别（待补充）：
- ES用于高性能的全文检索，对搜索结果进行算分。
- 关系型数据库更注重事务性

# 分布式部署下的一些基础概念
## 节点
节点是一个Elasticsearch的实例，本质上是一个Java进程，所以可以通过JVM启动参数对配置进行修改。

一台机器上可以运行多个es进程，但是一般生产环境一台机器上只运行一个es实例。

每个节点在启动之后都会分配一个UID，保存在data目录下。
### Master-eligible nodes和Master Node(合格主节点和主节点)
每一个节点启动后，默认就是一个Master eligible节点，可以设置node.master: false禁止。

- Master-eligible节点可以参加选主，成为Master节点。
- 当第一个节点启动的时候，他会将自己选举成Master节点。
- 每个节点上都保存了集群的状态，只有Master节点才能修改集群的状态信息。
    - 集群状态(Cluster State)维护了一个集群中的必要信息
        - 所有节点信息
        - 所有索引和其相关的Mapping和Setting信息
        - 分片的路由信息
    - 任意节点修改信息都会导致数据的不一致性

### Data Node和Corrdinating Node(数据节点和协调节点)
Data Node:
- 保存数据的节点，负责保存分片的数据，在数据扩展上起到关键作用。
Coordinating Node
- 负责接收Clinet的请求，将请求分发到合适的节点，最终把结果汇集到一起
- 每个节点都默认起到了Corrdinating Node的职责

### Hot&Warm Node(冷/热节点)
不同硬件配置的Data Node，用来实现冷热数据架构的，降低集群部署的成本。

一般日志的case的时候，热节点用更高配置的机器，更高性能的CPU、更大存储的硬盘。冷节点用来存储旧数据，相对来讲就可以使用配置低一些的机器。


### Machine Learning Node
Elasticsearch可以通过配置Machine Job自动的发现数据的一些异常，及时做出一些警报

所以machine learning node负责跑机器学习的Job，用来做异常检测。

### Tribe Node（已经被淘汰）
5.3开始使用了Cross Cluster Search ，和Tribe Node一样，连接到不同的Elasticsearch集群，并且支持将这些集群当成一个单独的集群处理。

## 配置节点类型
- 开发环境中一个节点可以承担多种角色
- 生产环境中应该设置单一角色的节点

节点类型 | 配置参数 | 默认值
-- | -- | --
master eligible | node.master | true
data | node.data | true
ingest| node.ingest | true
coordinating only | 无 | 每个节点默认都是coordinating节点，设置其他类型全部为false
machine learning | node.ml | true(需enable x-pack)

## 分片
主分片(Primary Shard)，用于解决数据水平扩展的问题。通过主分片，可以将数据分布到集群内的所有节点上。
- 一个分片是一个运行的lucene的实例
- 主分片数在索引创建时指定，后续不允许修改，除非Reindex。

副本分片(Replica Shard)，用于解决数据高可用问题，副本分片是主分片的拷贝。
- 副本分片数可以动态调整
- 增加副本数量，还可以一定程度上提高服务的可用性(独取的吞吐量)

![es04](/image/ElasticSearch/elasticsearch04.png)

## 集群
不同的集群通过名字进行区分，默认是"elasticsearch"

可以通过配置文件修改，或者启动命令行中增加"-E cluster.name=xxxx"指定名称。