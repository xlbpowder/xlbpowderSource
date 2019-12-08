---
title: ElasticSearch基础RESTfulAPI
date: 2019-12-09 15:00:00
tags: ElasticSearch
categories: Elastic Stack
---

在学习Elasticsearch相关的api使用中，大多数其实可以通过kibana、cerebro来使用，很方便，但是当通过客户端应用程序连接的时候，其实还是要了解各个RESTfulAPI的细节，方便出现问题排查，所以记录了一下学习的基础API。

<!-- more -->

# 集群的监控
集群应用的相关信息，其实可以通过部署cerebro来查看，但是也是要了解一下相关的RESTfulAPI的。
- GET _cluster/health 查看集群的健康状况
- GET _cat/nodes 查看节点信息
- GET _cat/shards 查看分片信息

# 文档的CRUD
操作类型 | RESTfulAPI |  
-- | -- |
Index | PUT my_index/_doc/id
Create | PUT my_index/_create/id
Read | GET my_index/_doc/id
Update | POST my_index/_update/id
Delete | DELETE my_index/_doc/id

- Type约定都用_doc
- Create 如果ID已经存在，则会创建失败
- Index 如果ID不存在，创建新的文档，否则，会删除现有的文档，然后创建新的文档，版本号增加
- Update 文档必须已经存在，更新只会更新对应字段做增加修改

## 创建文档
有两种方式
```
POST /my_index/_doc                       自动生成ID创建文档
```

```
PUT /my_index/_create/${id}               指定ID创建文档
```

通过index操作，指定操作类型进行创建
```
PUT /my_index/_doc/${id}/?op_type=create  指定ID创建文档
```

## Index文档
如果文档不存在，就会索引新文档，否则，现有的文档会被珊瑚，新的文档被索引，版本信息+1。
```
PUT /my_index/_doc/${id}                  根据ID更新文档，如果不存在则创建文档
{
    // 要更新的内容
}
```

## 获取文档
找到文档会返回HTTP 200，找不到则会返回HTTP 404
```
GET /my_index/_doc/${id}                  获取文档
```

## 更新文档
更新的信息必须包含在"doc"中
```
POST /my_index/_update/${id}/             更新文档
{
    "doc":{
        // 要更新的内容
    }
}
```

# Bulk API
每次RESTfulAPI都会进行一次网络开销，如果多次调用会非常损耗性能。

Bulk API得核心思想就想在一次调用中，进行多种操作。

支持对一个索引的多种操作，也支持对多个索引的多种操作。
- Index
- Create
- Update
- Delete

即使单条操作失败，但并不会影响其他的操作。返回结果中包含了每一条的执行结果

# 批量独取 mget
批量独取，同Bulk API类似，都是通过减少网络连接减少对性能的开销。

只需要提供一细列的index和对应文档ID，就可以一次返回多条文档信息。

# 批量查询 msearch
可以通过一次调用，对不同的索引，进行不同维度的查询。

# 常见错误返回
问题/状态码 | 原因
-- | --
无法连接 | 网络故障或者集群挂了
连接无法关闭 | 网络故障或者节点出错
429 | 集群过于繁忙
4XX | 请求格式体有误
500 | 集群内部错误