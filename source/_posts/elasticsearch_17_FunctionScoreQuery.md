---
title: ElasticSearch Function Score Query优化算分
date: 2020-08-25 20:00:00
tags: ElasticSearch
categories: Elastic Stack
---

ES会对结果进行算分和排序，可以通过Score进行排序，但是不能满足某些特定的条件，无法针对相关度，对排序实现更多的控制

可以通过复合查询Function Score Query对搜索的精度进行控制。通过字段引入，对算分进行重排，也可以通过一致性随机函数展示随机的结果

<!-- more -->
# 算分与排序
- Elasticsearch默认会以文档的相关度算分进行排序
- 可以通过制定一个或多个字段进行排序
- 使用相关度算分(Score)排序，但不能满足特定条件

# Function Score Query
可以在查询结束后，对每一个匹配的文档进行一系列的重新算分，根据新生成的分数进行排序

提供了集中默认的计算分值的函数
- Weight: 为每一个文档设置一个简单而不被规范化的权重
- Field Value Factor: 使用该数值来修改_score，例如将“热度”和“点赞数”作为算分的参考因素
- Random Score: 为每一个用户使用不同的值随机算分结果
- 衰减函数: 以某个字段的值为标准，距离某个值越近，得分越高
- Script Score: 自定义脚本完全控制所需逻辑

# 示例

## 初始化数据
``` json
DELETE blogs
PUT /blogs/_doc/1
{
  "title":   "About popularity",
  "content": "In this post we will talk about...",
  "votes":   0
}

PUT /blogs/_doc/2
{
  "title":   "About popularity",
  "content": "In this post we will talk about...",
  "votes":   100
}

PUT /blogs/_doc/3
{
  "title":   "About popularity",
  "content": "In this post we will talk about...",
  "votes":   1000000
}
```

## 按受欢迎度提升权重
希望能够将点赞数多的blog放在搜索列表相对靠前的位置。同时搜索的评分，还是要作为排序的主要依据

通过function_score，在进行multi_match时增加对votes字段进行重打分排序
- 新的算分 = 老的算分 * 投票数
``` json
POST /blogs/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match": {
          "query":    "popularity",
          "fields": [ "title", "content" ]
        }
      },
      "field_value_factor": {
        "field": "votes"
      }
    }
  }
}
```

# Modifier
上面的示例会发现当设置的指定字段相差较大，可能会导致score差异变大。

通过使用Modifier来使查询结果Score平滑曲线

- 新的算分 = 老的算分 * log(1 + 投票数)

## 示例
``` json
POST /blogs/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match": {
          "query":    "popularity",
          "fields": [ "title", "content" ]
        }
      },
      "field_value_factor": {
        "field": "votes",
        "modifier": "log1p"
      }
    }
  }
}
```
## modifier的属性值
Modifier|Meaning|
-|-|
none| Do not apply any multiplier to the field value|
log|Take the common logarithm of the field value|
log1p|Add 1 to the field value and take the common logarithm|
log2p|Add 2 to the field value and take the common logarithm|
ln|Take the natural logarithm of the field value|
ln1p|Add 1 to the field value and take the natural logarithm|
ln2p|Add 2 to the field value and take the natural logarithm|
square|Square the field value(multiply it by itself)|
sqrt|Take the square root of the field value|
reciprocal|Reciprocate the field value, same as 1/x where x is the field's value|

# Factor
通过引入Factor自定义曲线
- 新的算分 = 老的算分 * log(1 + factor * 投票数)

## 示例
``` json
POST /blogs/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match": {
          "query":    "popularity",
          "fields": [ "title", "content" ]
        }
      },
      "field_value_factor": {
        "field": "votes",
        "modifier": "log1p" ,
        "factor": 0.1
      }
    }
  }
}
```

# Boost Mode、Max Boost
使用Boost Mode来获得不同的算分

## Boost Mode
- Multiply: 算分与函数值的乘积
- Sum: 算分与函数的和
- Min/Max: 算分与函数取最小/最大值
- Replace: 使用函数值取代算分

## Max Boost
可以将算分控制在该值范围内

## 示例
``` json
POST /blogs/_search
{
  "query": {
    "function_score": {
      "query": {
        "multi_match": {
          "query":    "popularity",
          "fields": [ "title", "content" ]
        }
      },
      "field_value_factor": {
        "field": "votes",
        "modifier": "log1p" ,
        "factor": 0.1
      },
      "boost_mode": "sum",
      "max_boost": 3
    }
  }
}
```
# random_score
有时我们会遇到一些场景，例如：让每个用户能看到不同的随机排名，但是也系统同一个用户访问时，结果的想对顺序保持一致(Consistently Random)

一致性随机函数
- 使用场景: 网站的广告需要提高展示率

通过设置seed的值来控制一致性，只要seed相同，随机排序顺序相同
## 示例
``` json
POST /blogs/_search
{
  "query": {
    "function_score": {
      "random_score": {
        "seed": 911119
      }
    }
  }
}
```