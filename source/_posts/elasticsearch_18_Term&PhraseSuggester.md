---
title: ElasticSearch Term&PhraseSuggester
date: 2020-08-26 14:00:00
tags: ElasticSearch
categories: Elastic Stack
---

现代的搜索引擎一般都会提供Suggest as you type的功能，即搜索建议。本篇就主要记录下ES提供的相关能力
<!-- more -->

# 什么是搜索建议
现代的搜索引擎，一般都会提供SUggest as you type的功能。帮助用户在输入搜索的过程中，进行自动补全或者纠错。通过协助用户输入更加精准的关键词，提高后续搜索阶段文档匹配程度

在google上搜索，一开始会自动补全。当输入到一定长度，如因为单词拼写错误无法补全，就会开始提示相似的词或者句子

# Elasticsearch Suggester API
ES通过Suggester API来实现的搜索建议

原理是，将输入的文本分解为Token，然后在索引的字典里查找相似的Term并返回

根据不同的使用场景，ES设计了四种类别的Suggester
- Term & Phrase Suggester
- Complete & Context Suggester

# Term Suggester
Suggester其实就是一种特殊类型的搜索，"text"里是调用时候提供的文本，通常来自用户输入的内容

## 示例
### 创建示例数据
``` json
DELETE articles
PUT articles
{
  "mappings": {
    "properties": {
      "title_completion":{
        "type": "completion"
      }
    }
  }
}

POST articles/_bulk
{ "index" : { } }
{ "title_completion": "lucene is very cool"}
{ "index" : { } }
{ "title_completion": "Elasticsearch builds on top of lucene"}
{ "index" : { } }
{ "title_completion": "Elasticsearch rocks"}
{ "index" : { } }
{ "title_completion": "elastic is the company behind ELK stack"}
{ "index" : { } }
{ "title_completion": "Elk stack rocks"}
{ "index" : {} }
```

### 搜索
- 用户输入的"lucen"是一个错误的拼写
- 会到指定的字段"body"上搜索，当无法搜索到结果时(missing)，返回建议的词
``` json
POST /articles/_search
{
  "size": 1,
  "query": {
    "match": {
      "body": "lucen rock"
    }
  },
  "suggest": {
    "term-suggestion": {
      "text": "lucen rock",
      "term": {
        "suggest_mode": "missing",
        "field": "body"
      }
    }
  }
}
```

# Suggestion Mode
- Missing 如索引中已经存在，就不提供建议
- Popular 推荐出现词频更加高的词
- Always 无论是否存在，都提供建议

# 实现原理
相似性是通过Levenshtein Edit Distance的算法实现的。核心思想就是一个词改动多少字符就可以和另外一个词一致。提供了很多可选参数来控制相似度的模糊程度。例如"max_edits"

每个建议都包含了一个算分，下面例子中响应信息可以看出

# 示例
搜索"lucen rock"
``` json
POST /articles/_search
{

  "suggest": {
    "term-suggestion": {
      "text": "lucen rock",
      "term": {
        "suggest_mode": "popular",
        "field": "body"
      }
    }
  }
}
```

响应信息如下
``` json
"suggest" : {
"term-suggestion" : [
    {
    "text" : "lucen",
    "offset" : 0,
    "length" : 5,
    "options" : [
        {
        "text" : "lucene",
        "score" : 0.8,
        "freq" : 2
        }
    ]
    },
    {
    "text" : "rock",
    "offset" : 6,
    "length" : 4,
    "options" : [
        {
        "text" : "rocks",
        "score" : 0.75,
        "freq" : 2
        }
    ]
    }
]
}
```

将查询条件"rock"修改为"hock"，增加了"prefix_length"来进行控制，结果返回也是会推荐"rock"相关推荐
``` json
POST /articles/_search
{

  "suggest": {
    "term-suggestion": {
      "text": "lucen hocks",
      "term": {
        "suggest_mode": "always",
        "field": "body",
        "prefix_length":0,
        "sort": "frequency"
      }
    }
  }
}
```

# Phrase Suggester
Phrase Suggester在Term Suggester上增加了一些额外的逻辑。

增加了如下参数
- Suggest Mode: missing, popular, always
- Max Errors: 最多可拼错的Terms数
- Confidence: 限制返回结果数，默认为1

## 示例
``` json
POST /articles/_search
{
  "suggest": {
    "my-suggestion": {
      "text": "lucne and elasticsear rock hello world ",
      "phrase": {
        "field": "body",
        "max_errors":2,
        "confidence":0,
        "direct_generator":[{
          "field":"body",
          "suggest_mode":"always"
        }],
        "highlight": {
          "pre_tag": "<em>",
          "post_tag": "</em>"
        }
      }
    }
  }
}
```

# The Completion Suggester
Completion Suggester提供了自动补全（Auto Complete）的功能。用户每输入一个字符，就需要即时发送一个查询请求到后端查找匹配项

对性能要求比较苛刻。ES采用了不同的数据结构，并非通过倒排索引完成。
而是将Analyze的数据编码成FST和索引一起存放。FST会被ES加载进内存，访问速度很快

- 缺点：FST只能用于前缀查找

## 使用Completion Suggester的步骤
- 定义Mapping，type使用completion
- 创建索引数据后，使用suggest查询来获取搜索建议


## 示例
创建mapping，创建示例数据。
- suggest查询使用article-suggester
- prefix 需要补全内容的前缀，即用户输入内容
- completion field指定补全字段

``` json
PUT articles
{
  "mappings": {
    "properties": {
      "title_completion":{
        "type": "completion"
      }
    }
  }
}

POST articles/_bulk
{ "index" : { } }
{ "title_completion": "lucene is very cool"}
{ "index" : { } }
{ "title_completion": "Elasticsearch builds on top of lucene"}
{ "index" : { } }
{ "title_completion": "Elasticsearch rocks"}
{ "index" : { } }
{ "title_completion": "elastic is the company behind ELK stack"}
{ "index" : { } }
{ "title_completion": "Elk stack rocks"}
{ "index" : {} }

POST articles/_search?pretty
{
  "size": 0,
  "suggest": {
    "article-suggester": {
      "prefix": "elk ",
      "completion": {
        "field": "title_completion"
      }
    }
  }
}
```
# Context Suggester
Completion Suggester的扩展功能

在很多情况下用户输入信息需要根据上下文进行提示，例如用户输入"star"
- 咖啡相关 建议"Starbucks"
- 电影相关 建议"StarWars"

## 实现Context Suggester
可以定义两种类型的Context
- Category 任意字符串
- Geo 地理位置信息

## 实现Context Suggester的步骤
- 定义Mapping
- 创建索引数据，并且为每个文档加入Context信息
- 结合Context进行Suggestion查询

## 示例
同样创建一个type为completion的字段，并且指定contexts，type为category，且为其命名

查询时在completion下增加contexts，使用定义mapping时候contexts的命名comment_category来进行查询
``` json
PUT comments/_mapping
{
  "properties": {
    "comment_autocomplete":{
      "type": "completion",
      "contexts":[{
        "type":"category",
        "name":"comment_category"
      }]
    }
  }
}

POST comments/_doc
{
  "comment":"I love the star war movies",
  "comment_autocomplete":{
    "input":["star wars"],
    "contexts":{
      "comment_category":"movies"
    }
  }
}

POST comments/_doc
{
  "comment":"Where can I find a Starbucks",
  "comment_autocomplete":{
    "input":["starbucks"],
    "contexts":{
      "comment_category":"coffee"
    }
  }
}

POST comments/_search
{
  "suggest": {
    "MY_SUGGESTION": {
      "prefix": "sta",
      "completion":{
        "field":"comment_autocomplete",
        "contexts":{
          "comment_category":"coffee"
        }
      }
    }
  }
}
```
# Suggester精准度和召回率比较

## 精准度
Completion > Phrase > Term

## 召回率
Term > Phrase > Completion

## 性能
Completion > Phrase > Term