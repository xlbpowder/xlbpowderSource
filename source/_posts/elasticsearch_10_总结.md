---
title: ElasticSearch第一部分总结
date: 2020-07-15 18:00:00
tags: ElasticSearch
categories: Elastic Stack
---

对ES学习的第一部分做一个总结，以及部分练习题。从19年6月份开始学习ES到现在一年了陆续学习了这么一点，今后应该加快学习的脚步了
<!-- more -->

# 产品与使用场景
- Elasticsearch是一个开源的分布式搜索与分析引擎，提供了近实时搜索和聚合两大功能
- Elastic Stack包括Elasticsearch、Kibana、Logstash、Beats等一系列产品
    - Elasticsearch是核心引擎，提供了海量数据存储、搜索和聚合能力
    - Beats是轻量的数据采集器
    - Logstash用来做数据转换
    - Kibana提供了丰富的可视化展示与分析功能
- Elastic Stack主要被广泛适用于：搜索、日志管理、安全分析、指标分析、业务分析、应用性能监控等多个领域
- Elastic Stack开源了X-Pack在哪的相关代码。作为商业解决方案，X-Pack的部分功能需要收费。Elastic公司从6.8和7.1开始，Security功能也可以免费使用
- 相比关系型数据库，Elasticsearch提供了如模糊查询，搜索条件的算分等关系型数据库所不擅长的功能。但是在事务性等方面，也是不如关系型数据库强大。因此，在实际生产环境中，需要考虑具体业务要求综合使用

# 基本概念
- 一个Elasticsearch集群可以运行在单节点上，也支持运行在多个服务器上，实现数据和服务的水平扩展
- 从逻辑角度看，索引是一些具有相似结构的文档的集合
- 从物理角度看，分片是一个Lucene的实例。分片存储了索引的具体数据，分片可以分布在不同的节点上。副本分片除了提高数据的可靠性，还能一定程度提升集群查询的性能
- Elasticsearch的文档可以是任意的JSON格式的数据
- 将文档写进Elasticsearch的过程也叫做索引(indexing)
- Elasticsearch提供了REST API和Transport API两种方式，建议使用REST API

# 搜索和Aggregation(聚合)
- Precosion指除了相关结果，还返回了多少不相关的结果
- Recall衡量有多少相关的结果，实际上并没有返回
- 精确值包括：数字、日期和某些具体的字符串
- 全文本是需要被检索的非结构文本
- Analyis是将文本转换成倒排索引中的Term的过程
- Elasticsearch的Analyzer是Char_filter -> Tokenizer -> Token Filter的过程
- Elasticsearch搜索支持URI Search和REST Body两种方式
- Elasticsearch提供了Bucket/Metric/Pipeline/Matrix四种方式的聚合

# 文档的CRUD与Index Mapping
- 除了CRUD操作外，Elasticsearch还提供了bulk、mget和msearch等操作。从性能的角度上建议使用以提升性能，但是，单次操作的数据量不要过大，以免引发性能问题
- 每个索引都有一个Mapping定义。包含文档的字段和类型，字段的Analyzer的相关配置
- Mapping可以被动态创建，为了避免一些错误的类型推算或者满足特定的需求，也可以显性的定义Mapping
- 你可以为字段指定定制化的Analyzer，也可以为查询字符串指定search_analyzer
- Index Template可以定义Mapping和Settings，并自动的应用到新创建的索引之上，建议合理的使用Index Template
- Dynamic Template支持在具体的索引上指定规则，为新增加的字段指定相应的Mapping

# 测试题
1. 判断题：ES支持使用HTTP PUT写入新文档，并通过曰asticsearch生成文档Id
    - 错，需要用POST命令创建。
2. 判断题：Update—个文档，需要使用HTTP PUT
    - 错，Update文档，使用POST, PUT只能用来做Index或者Create
3. 判断题：Index—个已存在的文档，旧的文档会先被删除，新的文档再被写入，同时版本号加1
    - 对
4. 尝试描述创建一个新的文档到一个不存在的索引中，背后会发生一些什么？
    - 默认情况下，会创建相应的索引，并且自己设置Mapping，当然，实际情况还是要看是否有合适的Index Template
5. ES7中的合法的type是什么？
    - _doc
6. 精确值和全文的本质区别是什么？
    - 精确值不会被Analyzer分词，全文本会
7. Analyzer由哪几个部分组成？
    - Character Filter + Tokenizer + Token Filter
8. 尝试描述match和match_phrase的区别
    - Match中的terms之间是or的关系，Match Phrase的terms之间是and的关系，并且term之间位置关系也影响搜索的结果
9. 如果你希望match_phrase匹配到更多结果，你应该配置查询中什么参数？
    - slop
10. 如果Mapping的dynamic设置成“strict”，索引一个包含新增字段的文档时会发生什么?
    - 直接报错
11. 如果Mapping的dynamic设置成“false”，索引一个包含新增字段的文档时会发生什么？
    - 文档被索引，新的字段在_source中可见。但是该字段无法被搜索
12. 判断：可以把一个字段的类型从“integer”改成“long”，因为这两个类型是兼容的
    - 错。字段类型修改，需要重新reindex
13. 判断：你可以在Mapping文件中为indexing和searching指定不同的analyzer
    - 对。可以在Mapping中为index和search指定不同的analyizer
14. 判断：字段类型为Text的字段， 一定可以被全文搜索
    - 错。可以通过为text类型的字段指定Not Indexed，使其无法被搜索