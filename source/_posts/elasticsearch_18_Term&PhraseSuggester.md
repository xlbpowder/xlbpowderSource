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