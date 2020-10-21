---
title: ElasticSearch 配置跨集群搜索
date: 2020-09-09 15:00:00
tags: ElasticSearch
categories: Elastic Stack
---

我们知道ES是非常容易进行水平扩展的，但是横向水平扩展后，单集群节点数不能无限增加，会引发性能问题，本篇纪录了ES如何处理跨集群搜索相关的功能和配置
<!-- more -->
# 水平扩展的痛点
单集群，当水平扩展时，节点数不能无限增加。当集群的meta信息（节点、索引、集群状态）过多，会导致 更新压力变大，单个Active Master会成为性能瓶颈，导致整个集群无法正常工作

早期版本，通过Tribe Node可以实现多集群访问的需求，但是还存在一定问题
- Tribe Node会以Client Node的方式加入每个集群。集群中Master节点的任务变更需要Tribe Node的回应才能继续
- Tribe Node不保存Cluster State信息，一旦重启，初始化很慢
- 当多个集群存在索引重名情况时，只能设置一种Prefer规则

# Cross Cluster Search
早起Tribe Node方案已经被废弃。ES 5.3引入了跨集群搜索功能(Cross Cluster Search)并且推荐使用
- 允许任何节点扮演federated节点，以轻量的方式将搜索请求进行代理
- 不需要以Client Node的形式加入其他集群

# 示例
## 启动3个集群
``` linux
bin/elasticsearch -E node.name=cluster0node -E cluster.name=cluster0 -E path.data=cluster0_data -E discovery.type=single-node -E http.port=9200 -E transport.port=9300
bin/elasticsearch -E node.name=cluster1node -E cluster.name=cluster1 -E path.data=cluster1_data -E discovery.type=single-node -E http.port=9201 -E transport.port=9301
bin/elasticsearch -E node.name=cluster2node -E cluster.name=cluster2 -E path.data=cluster2_data -E discovery.type=single-node -E http.port=9202 -E transport.port=9302

```

## 在每个集群上设置其他节点信息
``` json
PUT _cluster/settings
{
  "persistent": {
    "cluster": {
      "remote": {
        "cluster0": {
          "seeds": [
            "127.0.0.1:9300"
          ],
          "transport.ping_schedule": "30s"
        },
        "cluster1": {
          "seeds": [
            "127.0.0.1:9301"
          ],
          "transport.compress": true,
          "skip_unavailable": true
        },
        "cluster2": {
          "seeds": [
            "127.0.0.1:9302"
          ]
        }
      }
    }
  }
}
```

## 设置并创建示例数据
```
curl -XPUT "http://localhost:9200/_cluster/settings" -H 'Content-Type: application/json' -d'
{"persistent":{"cluster":{"remote":{"cluster0":{"seeds":["127.0.0.1:9300"],"transport.ping_schedule":"30s"},"cluster1":{"seeds":["127.0.0.1:9301"],"transport.compress":true,"skip_unavailable":true},"cluster2":{"seeds":["127.0.0.1:9302"]}}}}}'

curl -XPUT "http://localhost:9201/_cluster/settings" -H 'Content-Type: application/json' -d'
{"persistent":{"cluster":{"remote":{"cluster0":{"seeds":["127.0.0.1:9300"],"transport.ping_schedule":"30s"},"cluster1":{"seeds":["127.0.0.1:9301"],"transport.compress":true,"skip_unavailable":true},"cluster2":{"seeds":["127.0.0.1:9302"]}}}}}'

curl -XPUT "http://localhost:9202/_cluster/settings" -H 'Content-Type: application/json' -d'
{"persistent":{"cluster":{"remote":{"cluster0":{"seeds":["127.0.0.1:9300"],"transport.ping_schedule":"30s"},"cluster1":{"seeds":["127.0.0.1:9301"],"transport.compress":true,"skip_unavailable":true},"cluster2":{"seeds":["127.0.0.1:9302"]}}}}}'

curl -XPOST "http://localhost:9200/users/_doc" -H 'Content-Type: application/json' -d'
{"name":"user1","age":10}'

curl -XPOST "http://localhost:9201/users/_doc" -H 'Content-Type: application/json' -d'
{"name":"user2","age":20}'

curl -XPOST "http://localhost:9202/users/_doc" -H 'Content-Type: application/json' -d'
{"name":"user3","age":30}'
```

## 使用的时候就可以指定集群的名字进行搜索
``` json
GET /users,cluster1:users,cluster2:users/_search
{
  "query": {
    "range": {
      "age": {
        "gte": 20,
        "lte": 40
      }
    }
  }
}
```

## 设置如果远程集群失去响应可以跳过继续执行
``` json
PUT _cluster/settings
{
  "persistent": {
    "cluster.remote.cluster_two.skip_unavailable": true
  }
}
```

# 在Kibana中使用Cross data search
- https://kelonsoftware.com/cross-cluster-search-kibana/
