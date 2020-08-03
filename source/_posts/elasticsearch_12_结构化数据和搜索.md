---
title: ElasticSearch 结构化查询和结构化数据
date: 2020-07-30 16:00:00
tags: ElasticSearch
categories: Elastic Stack
---

Elasticsearch深入搜索，结构化查询和结构化数据知识
<!-- more -->
Structured Search是指对结构化数据的搜索

# 结构化数据
日期、布尔类型和数字类型都是结构化的

文本也可以是结构化的
- 彩色笔可以有离散的颜色集合：红、绿、蓝
- 一个博客可能被标记了标签：分布式、搜索
- 电商网站商品都有UPCs（通用产品码Universal Product Codes）或其他的唯一标识，他们都需要遵从严格规定的、结构化的格式

# ES中的结构化搜索
- 布尔、时间、日期和数字这类结构化数据：有精准的格式，我们可以对这些格式进行逻辑操作。包括比较数字或时间的范围，比较两个值的大小
- 结构化的文本可以做到精确匹配或者部分匹配：Term查询/Prefix前缀查询
- 结构化结果只有"是"或"否"两个值
- 根据场景要求，可以决定结构化搜索是否需要打分

## 日期格式
同JAVA DataFormat

## 示例
初始化数据

``` json
DELETE products

POST /products/_bulk
{ "index": { "_id": 1 }}
{ "price" : 10,"avaliable":true,"date":"2018-01-01", "productID" : "XHDK-A-1293-#fJ3" }
{ "index": { "_id": 2 }}
{ "price" : 20,"avaliable":true,"date":"2019-01-01", "productID" : "KDKE-B-9947-#kL5" }
{ "index": { "_id": 3 }}
{ "price" : 30,"avaliable":true, "productID" : "JODL-X-1937-#pV7" }
{ "index": { "_id": 4 }}
{ "price" : 30,"avaliable":false, "productID" : "QQPX-R-3956-#aD8" }

GET products/_mapping
```

对布尔值match查询，有算分
``` json
POST products/_search
{
  "profile": "true",
  "explain": true,
  "query": {
    "term": {
      "avaliable": true
    }
  }
}
```

对布尔值，通过constant score 转成 filtering，没有算分
``` json
POST products/_search
{
  "profile": "true",
  "explain": true,
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "avaliable": true
        }
      }
    }
  }
}
```

数字类型 Term、Terms
``` json
POST products/_search
{
  "profile": "true",
  "explain": true,
  "query": {
    "term": {
      "price": 30
    }
  }
}

POST products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "terms": {
          "price": [
            "20",
            "30"
          ]
        }
      }
    }
  }
}
```

数字和日期的Range查询
``` json
GET products/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "range" : {
                    "price" : {
                        "gte" : 20,
                        "lte"  : 30
                    }
                }
            }
        }
    }
}

POST products/_search
{
    "query" : {
        "constant_score" : {
            "filter" : {
                "range" : {
                    "date" : {
                      "gte" : "now-1y"
                    }
                }
            }
        }
    }
}
```

Exists查询
``` json
POST products/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "exists": {
          "field": "date"
        }
      }
    }
  }
}
```

# 多值字段查询
对于多值字段的查询，ES默认是包含，而不是相等。

解决方案：增加一个genre_count字段进行计数，结合bool Query做精确匹配
``` json
# 初始化数据
POST /movies/_bulk
{ "index": { "_id": 1 }}
{ "title" : "Father of the Bridge Part II","year":1995, "genre":"Comedy"}
{ "index": { "_id": 2 }}
{ "title" : "Dave","year":1993,"genre":["Comedy","Romance"] }


# 处理多值字段，term 查询是包含，而不是等于
POST movies/_search
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "genre.keyword": "Comedy"
        }
      }
    }
  }
}
```
# 总结
- 结构化数据&结构化搜索，如果不需要算分，可以通过Constant Score，将查询转为Filtering
- 范围查询和Data Math
- 使用Exists查询处理非空 null值
- 精确值&多值字段的精确值查找，Term查询是包含，不是完全相等。针对多值字段需要注意