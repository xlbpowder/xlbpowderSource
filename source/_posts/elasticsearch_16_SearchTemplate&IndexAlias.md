---
title: ElasticSearch Search Template与Index Alias
date: 2020-08-14 18:00:00
tags: ElasticSearch
categories: Elastic Stack
---

记录了学习Search Template与Index Alias相关知识的笔记
<!-- more -->
# Search Template
- 实现搜索和DSL的分离

es的查询语句对相关性算分和查询性能的要求都很高，在开发初期，虽然可以明确查询参数，往往都不能最终定义查询的DSL具体结构

这时就可以使用Search Template先定义接口和参数。具体template中查询的语句可以后期进行调整和优化

使用`_scripts`来对Search Template进行操作，查询时就可以使用模版指定id和参数即可。这样即便是DSL修改了，也不影响查询方式。具体文档请查阅

- (Search Template elastic官方文档)[https://www.elastic.co/guide/en/elasticsearch/reference/7.1/search-template.html]

## 示例
``` json
POST _scripts/tmdb
{
  "script": {
    "lang": "mustache",
    "source": {
      "_source": [
        "title","overview"
      ],
      "size": 20,
      "query": {
        "multi_match": {
          "query": "{{q}}",
          "fields": ["title","overview"]
        }
      }
    }
  }
}
DELETE _scripts/tmdb

GET _scripts/tmdb

POST tmdb/_search/template
{
    "id":"tmdb",
    "params": {
        "q": "basketball with cartoon aliens"
    }
}
```

# Index Alias
有时Index的名字是动态的，索引的改名或者重建，这样就需要修改查询语句。使用Index Alias就可以在不修改DSL的前提下进行索引名称的变更

## 示例
首先为索引指定一个别名，在通过别名进行index的读写操作
``` json
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "movies-2019",
        "alias": "movies-latest"
      }
    }
  ]
}

POST movies-latest/_search
{
  "query": {
    "match_all": {}
  }
}

```

也可以在设置Alias的同时设置过滤器。使用filter指定rating大于4的时候，才进行显示，这样子再指定一个新的别名
## 示例
``` json
POST _aliases
{
  "actions": [
    {
      "add": {
        "index": "movies-2019",
        "alias": "movies-lastest-highrate",
        "filter": {
          "range": {
            "rating": {
              "gte": 4
            }
          }
        }
      }
    }
  ]
}

POST movies-lastest-highrate/_search
{
  "query": {
    "match_all": {}
  }
}
```