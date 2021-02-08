---
title: ElasticSearch 集群分布式模型与脑裂问题
date: 2020-10-21 21:00:00
tags: ElasticSearch
categories: Elastic Stack
---

本篇主要记录ES分布式架构的模型相关知识，最初篇ES的笔记中有简单记录ES的分布式信息，但是本篇更具体
<!-- more -->

# 分布式特性
Elasticsearch的分布式架构带来的好处
- 存储的水平扩容，支持PB级的数据
- 提高系统的可用性，部分节点停止服务，整个集群的服务不受影响

Elasticsearch的分布式架构
- 不同的集群通过不同的名字来区分，默认名字为“elasticsearch”
- 通过修改配置文件，或在启动命令行中 -E cluster.name=xxx进行设定

# 节点
节点是一个Elasticsearch的实例，其实本质上就是一个JAVA进程。

一台机器上可以运行多个Elasticsearch进程，但是生产环境一般一台机器上就运行一个ES实例

每个节点都有自己的名字，通过修改配置文件，或者在启动的时候修改-E node.name=xxx指定

每个节点在启动之后，都会分配一个UID保存在data目录下

## Coordinating Node(协调节点)
处理请求的节点叫做Coordinating Node。路由请求到正确的节点，例如创建索引的请求，需要路由到Master节点

所有节点默认都是Coordinating Node，通过将其他类型设置成False，使其成为Dedicated Coordinating Node(专职协调节点)

## Data Node(数据节点)
可以保存数据的节点叫做Data Node。节点启动后，默认就是数据节点。可以设置node.data: false来禁止成为data node

Data Node的职责: 保存分片数据。在数据扩展上起到了至关重要的作用(由Master Node决定如何把分片分发到数据节点上)

通过增加Data Node可以解决数据水平扩展和解决数据单点问题

## Master Node(主节点)
Master Node职责: 
- 处理创建、删除索引等请求
- 决定分片被分配到哪个节点
- 负责索引的创建与删除
- 维护并且更新Cluster State

Master Node的最佳实践: Master Node非常重要，在部署上需要考虑解决单点问题。为一个集群设置多个Master Node，每个节点只承担Master的单一角色

### Master Eligible Nodes
一个集群，支持配置多个Master Eligible节点。这些节点可以在必要时(如Master节点出现网络故障等)参与选主流程，成为Master节点

每个节点启动后默认就是一个Master Eligible节点，可以设置node.master: false禁止

当集群内的第一个Master Eligible节点启动的时候，它会将自己选举成Master节点

### 脑裂问题
Split-Brain, 分布式系统的经典网络问题，当出现网络问题，一个节点和其他节点无法连接。
现在有三个Node，当node1出现问题。Node2和3会重新选举Master。两者分别选为自己作为Master组成一个集群，并且维护Cluster State。

### 如何避免脑裂问题
限定一个选举条件，设置quorum(仲裁)，只有在Master Eligible节点数大于quorum时才能进行选举

- Quorum = (master节点总数 / 2) + 1

例如上述场景，当产生3个Master Eligible时，设置discovery.zen.minimum_master_nodes为2，即可避免脑裂

从7.0版本开始已经不需要主动进行该配置了。移除了minimum_master_nodes参数，让ES自己选择可以形成仲裁的节点。

典型的主节点选注现在只需要很短的时间就可以完成。集群的伸缩变得更安全、容易，并且可能造成丢失数据的系统配置选项更少了。节点更清楚地记录它们的状态，有助于诊断它们为什么不能加入集群或无法选举出主节点

### 选主流程
相互Ping对方，NodeID低的会成为被选举的节点。其他节点会加入集群，但是不会承担Master节点的角色。一旦发现被选中的主节点丢失，就会选举出新的Master节点

## 集群状态
集群状态信息(Cluster State)维护了一个集群中必要的信息，包括
- 所有节点信息
- 所有的索引和其相关Mapping与Setting信息
- 分片的路由信息

在每个节点上都保存了集群的状态信息。但是，只有Master节点才能修改集群的状态信息，并负责同步给其他节点。因为如果任意节点都能修改信息可能会导致Cluster State不一致



