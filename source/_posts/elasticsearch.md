---
title: ElasticSearch入门
date: 2019-06-20 10:41:00
tags:
categories: ElasticSearch
---

又开了一个坑，之前也只是对ES和ELK的使用和搭建只有简单的理解，没有系统的学习过，那趁着这段时间好好系统的学习下。

<!-- more -->

ElasticSearch 基于JSON的开源分布式搜索分析引擎
- Near Real Time 近实时
- 分布式存储/搜索/分析引擎

## 同类产品
- solr(Apache开源项目)
- splunk(商业上市公司)

## Elastic Stack
- Kibana 数据可视化
- Logstash 动态数据收集管道
- Beats 轻量型数据采集器

## 起源
### Lucene
初创于1999年，Apache开源项目，基于JAVA语言开发
- Lucene具有高性能、易扩展的优点
- Lucene的局限性：
    - 只能基于JAVA语言开发
    - 类库的接口学习曲线陡峭
    - 原生并不支持水品扩展

### Elasticsearch的诞生
- 2004年Shay Banon基于Lucene开发了Compass
- 2010年Shay Banon对Compass进行了重写，更名为Elasticsearch
    - 支持分布式、可水平扩展
    - 提供Restful Api，降低全文检索的学习曲线。并且可接入任何语言应用。

## Elasticsearch的分布式架构
![es01](/image/ElasticSearch/elasticsearch01.jpg)
- 集群规模可以从单个扩展至数百个节点
- 高可用&水平扩展，从服务和数据两个维度
- 支持设置不同的节点类型，支持Hot&Warm架构

## 支持多种方式介接入
