---
title: ElasticSearch 多字段查询
date: 2020-07-31 14:00:00
tags: ElasticSearch
categories: Elastic Stack
---

记录了多字符串与单字符串两种的多字段查询
<!-- more -->

# 多字符串多字段查询
## Bool Query复合查询
一个bool查询，是一个或多个查询子句的组合。总共包含4种子句，其中2种会影响算分，2种不影响算分。

相关性并不只是全文检索的专利，也适用于yes｜no的子句。匹配的子句越多，相关性评分越高。
如果多条查询子句被合并为一条复合查询语句，比如bool查询，则每个查询子句计算得出的评分会被合并到总的相关性评分种

## 说明
|  |  |
| - | - |
| must     | 必须匹配 贡献算分 |
| should   | 选择性匹配 贡献算分 |
| must_not | Filter Context 查询子句，必须不能匹配 |
| filter   | Filter Context 必须匹配，但是不贡献算分 |

- 子查询可以任意顺序出现
- 可以嵌套多个查询
- 如果你的bool查询中，没有must条件，should中必须至少满足一条查询

## 如何解决结构化查询“包含而不是相等”的问题
增加一个count字段进行计数

### 示例
genre字段是一个数组，包含了多个元素，通过增加genre_count字段来标识该字段的元素个数，从而进行精确匹配

``` json
POST /newmovies/_bulk
{ "index": { "_id": 1 }}
{ "title" : "Father of the Bridge Part II","year":1995, "genre":"Comedy","genre_count":1 }
{ "index": { "_id": 2 }}
{ "title" : "Dave","year":1993,"genre":["Comedy","Romance"],"genre_count":2 }

POST /newmovies/_search
{
    "query": {
        "bool": {
            "must": [
                {
                    "term": {
                        "genre.keyword": {
                            "value": "Comedy"
                        }
                    }
                },
                {
                    "term": {
                        "genre_count": {
                            "value": 1
                        }
                    }
                }
            ]
        }
    }
}
```
## Filter Context 不影响算分
结果的score是0
``` json
POST /newmovies/_search
{
    "query": {
        "bool": {
            "filter": [
                {
                    "term": {
                        "genre.keyword": {
                            "value": "Comedy"
                        }
                    }
                },
                {
                    "term": {
                        "genre_count": {
                            "value": 1
                        }
                    }
                }
            ]
        }
    }
}
```

## Query Context 影响算分
``` json
POST /products/_bulk
{ "index": { "_id": 1 }}
{ "price" : 10,"avaliable":true,"date":"2018-01-01", "productID" : "XHDK-A-1293-#fJ3" }
{ "index": { "_id": 2 }}
{ "price" : 20,"avaliable":true,"date":"2019-01-01", "productID" : "KDKE-B-9947-#kL5" }
{ "index": { "_id": 3 }}
{ "price" : 30,"avaliable":true, "productID" : "JODL-X-1937-#pV7" }
{ "index": { "_id": 4 }}
{ "price" : 30,"avaliable":false, "productID" : "QQPX-R-3956-#aD8" }

POST /products/_search
{
    "query": {
        "bool": {
            "should": [
                {
                    "term": {
                        "productID.keyword": {
                            "value": "JODL-X-1937-#pV7"
                        }
                    }
                },
                {
                    "term": {
                        "avaliable": {
                            "value": true
                        }
                    }
                }
            ]
        }
    }
}
```

## bool 嵌套
通过should中增加bool查询的must_not，从而实现了should not逻辑
``` json
POST /products/_search
{
    "query": {
        "bool": {
            "must": {
                "term": {
                    "price": "30"
                }
            },
            "should": [
                {
                    "bool": {
                        "must_not": {
                            "term": {
                                "avaliable": "false"
                            }
                        }
                    }
                }
            ],
            "minimum_should_match": 1
        }
    }
}
```
## 查询语句的结构，会对相关度算分产生影响
- 同一层级下的竞争字段，具有相同的权重
- 通过嵌套bool查询，可以改变对算分的影响

``` json
POST /animals/_search
{
  "query": {
    "bool": {
      "should": [
        { "term": { "text": "brown" }},
        { "term": { "text": "red" }},
        { "term": { "text": "quick"   }},
        { "term": { "text": "dog"   }}
      ]
    }
  }
}

POST /animals/_search
{
  "query": {
    "bool": {
      "should": [
        { "term": { "text": "quick" }},
        { "term": { "text": "dog"   }},
        {
          "bool":{
            "should":[
               { "term": { "text": "brown" }},
                 { "term": { "text": "brown" }},
            ]
          }

        }
      ]
    }
  }
}
```

## Boosting Query
``` json
POST news/_search
{
  "query": {
    "bool": {
      "must": {
        "match":{"content":"apple"}
      }
    }
  }
}

POST news/_search
{
  "query": {
    "bool": {
      "must": {
        "match":{"content":"apple"}
      },
      "must_not": {
        "match":{"content":"pie"}
      }
    }
  }
}

POST news/_search
{
  "query": {
    "boosting": {
      "positive": {
        "match": {
          "content": "apple"
        }
      },
      "negative": {
        "match": {
          "content": "pie"
        }
      },
      "negative_boost": 0.5
    }
  }
}
```


# 单字符串多字段查询

## 问题场景
``` json
PUT /blogs/_doc/1
{
    "title": "Quick brown rabbits",
    "body":  "Brown rabbits are commonly seen."
}

PUT /blogs/_doc/2
{
    "title": "Keeping pets healthy",
    "body":  "My quick brown fox eats rabbits on a regular basis."
}

POST /blogs/_search
{
    "query": {
        "bool": {
            "should": [
                { "match": { "title": "Brown fox" }},
                { "match": { "body":  "Brown fox" }}
            ]
        }
    }
}
```
文档1中出现了Brown，文档2中Brown fox全部出现，并且保持和查询一致的顺序，目测认为相关性更高

``` json
{
  "took" : 2,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.90425634,
    "hits" : [
      {
        "_index" : "blogs",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.90425634,
        "_source" : {
          "title" : "Quick brown rabbits",
          "body" : "Brown rabbits are commonly seen."
        }
      },
      {
        "_index" : "blogs",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 0.77041256,
        "_source" : {
          "title" : "Keeping pets healthy",
          "body" : "My quick brown fox eats rabbits on a regular basis."
        }
      }
    ]
  }
}
```
但是通过bool query返回的信息中，1文档相关分数约为0.9，2文档的分数约为0.7。并没有返回我们预期的顺序。

这里涉及到`Bool Query的算分逻辑`
- 进行should语句中的两个查询
- 两个查询的评分进行相加
- 乘以匹配语句的总数
- 除以所有语句的总数

文档1中因为title、body中都包含了Brown，文档2中body包含了Brown fox，应该是有更高的相似度，但由于title中相关性算分较低，按照上述的Bool Query的算分逻辑则不复合我们的查询预期。

## Disjunction Max Query
上述例子中title和body相互为竞争关系，不应该将分数简单叠加，而是应该找到单个最佳匹配的字段的评分。

### 概念
Disjunction Max Query就是满足改需求的，DisMaxQuery会将任何与任一查询匹配的文档作为结果返回。采用字段上的最匹配的评分作为最终评分返回

### 示例
``` json
POST blogs/_search
{
    "query": {
        "dis_max": {
            "queries": [
                { "match": { "title": "Quick fox" }},
                { "match": { "body":  "Quick fox" }}
            ]
        }
    }
}
```

### tie_breaker
- Tier Breaker是一个介于0-1之间的浮点数。0代表使用最佳匹配；1代表所有语句同等重要

替换title和body的查询条件为Quick pets。会发现查询的结果评分相同。
通过增加tie_breaker，可以获得最佳匹配语句的评分，将其他匹配语句的评分与tie_breaker相乘，对评分求和并规范化。

``` json
POST blogs/_search
{
    "query": {
        "dis_max": {
            "queries": [
                { "match": { "title": "Quick pets" }},
                { "match": { "body":  "Quick pets" }}
            ],
            "tie_breaker": 0.2
        }
    }
}
```

## Multi Match
三种场景

### 最佳字段(Best Fields)
当字段之间相互竞争，又相互关联。例如title和body这样的字段。评分来自最匹配字段

#### 示例
- best_fields是默认类型，可以不用指定
- Minimum should match等参数可以传递到生成的query中
- 同Disjunction Max Query一样，可以指定tie_breaker
- 可以指定多个字段，并且支持通配符匹配

``` json
POST blogs/_search
{
  "query": {
    "multi_match": {
      "type": "best_fields",
      "query": "Quick pets",
      "fields": ["title","body"],
      "tie_breaker": 0.2,
      "minimum_should_match": "20%"
    }
  }
}

POST books/_search
{
  "multi_match": {
      "query":  "Quick brown fox",
      "fields": "*_title"
  }
}

POST books/_search
{
  "multi_match": {
      "query":  "Quick brown fox",
      "fields": [ "*_title", "chapter_title^2" ]
  }
}
```

### 多数字段(Most Fields)
处理英文内容时：一种常见的手段是，在主字段(English Analyzer)抽取词干，加入同义词，以匹配更多的文档。
相同的文本，加入子字段(Standard Analyzer)以提供更加精确的匹配。
其他字段作为匹配文档提高相关度的信号。匹配字段越多则越好

#### 示例
##### 问题场景
初始化一份新的数据，使用text作为字段类型，并采用标准的英文分词器进行分词，插入两条文档
``` json
DELETE /titles

PUT /titles
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "english"
      }
    }
  }
}

POST titles/_bulk
{ "index": { "_id": 1 }}
{ "title": "My dog barks" }
{ "index": { "_id": 2 }}
{ "title": "I see a lot of barking dogs on the road " }

```

英文分词器，导致精确度降低，时态(ing)信息丢失。

查看结果会发现id=1的文档算分更高。但其实我们期望的应该是id=2的文档更匹配才对。

是因为我们采用了英文分词器，会把barking和dogs做分词处理，输入的term是一样的，但id=1的文档更短所以算分更高
``` json
GET /titles/_search
{
   "query": {
        "multi_match": {
            "query":  "barking dogs",
            "type":   "most_fields",
            "fields": [ "title", "title.std" ]
        }
    }
}

{
  "took" : 1,
  "timed_out" : false,
  "_shards" : {
    "total" : 1,
    "successful" : 1,
    "skipped" : 0,
    "failed" : 0
  },
  "hits" : {
    "total" : {
      "value" : 2,
      "relation" : "eq"
    },
    "max_score" : 0.42221838,
    "hits" : [
      {
        "_index" : "titles",
        "_type" : "_doc",
        "_id" : "1",
        "_score" : 0.42221838,
        "_source" : {
          "title" : "My dog barks"
        }
      },
      {
        "_index" : "titles",
        "_type" : "_doc",
        "_id" : "2",
        "_score" : 0.320886,
        "_source" : {
          "title" : "I see a lot of barking dogs on the road "
        }
      }
    ]
  }
}
```

##### 使用多数字段匹配解决
对于上述问题，我们可以通过为title指定英文分词器，英文分词器会对时态做词干的提取。同时为该字段增加一个子字段std，使用standard analyzer，该分词器不会对词干做提取，所以就不会损失时态等信息。

这样可以同时使用english和standard两个分词器，一个对词干进行搜索，另外还可以控制搜索条件精度。使用most_fields搜索两个字段。

- 使用广度匹配字段title包括尽可能多的文档——以提升召回率
- 同时又使用字段title.std作为信号，将相关度更高的文档置于结果顶部
``` json
DELETE /titles
PUT /titles
{
  "mappings": {
    "properties": {
      "title": {
        "type": "text",
        "analyzer": "english",
        "fields": {"std": {"type": "text","analyzer": "standard"}}
      }
    }
  }
}

POST titles/_bulk
{ "index": { "_id": 1 }}
{ "title": "My dog barks" }
{ "index": { "_id": 2 }}
{ "title": "I see a lot of barking dogs on the road " }

GET /titles/_search
{
   "query": {
        "multi_match": {
            "query":  "barking dogs",
            "type":   "most_fields",
            "fields": [ "title", "title.std" ]
        }
    }
}
```
##### 权重
每个字段对于最终评分的贡献可以通过自定义值`boost`来控制。比如，使title字段更为重要，这样同时也降低了其他信号字段的作用
``` json
GET /titles/_search
{
   "query": {
        "multi_match": {
            "query":  "barking dogs",
            "type":   "most_fields",
            "fields": [ "title^10", "title.std" ]
        }
    }
}
```

### 混合字段(Cross Fields)
对于某些实体，例如人名、地址、图书信息等，需要在多个字段中确定信息，单个字段只能作为整体的一部分。希望在任何这些列出的字段中找到尽可能多的词
- 支持使用operator
- 与copy_to相比，节省空间且在搜索单个字段时可以提升权重

#### 示例
##### 跨字段搜索问题
例如地址信息，存储在多个属性中。无法使用Operator，可以使用copy_to解决，但需要额外的存储空间。
``` json
{
	"street": "5 Poland Street",
	"city": "London",
	"country": "United Kingdom",
	"country": " W1V 3DG"
}

POST address/_search
{
	"query": {
		"multi_match": {
			"query": " Poland Street W1V",
			"type": "most_fields",
			// "operator":"and",
			"fields": ["street", "city", "country", "country"]
		}
	}
}
```

``` json
POST address/_search
{
	"query": {
		"multi_match": {
			"query": " Poland Street W1V",
			"type": "cross_fields",
			"operator":"and",
			"fields": ["street", "city", "country", "country"]
		}
	}
}
```
