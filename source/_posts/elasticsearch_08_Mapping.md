---
title: ElasticSearch Mapping
date: 2020-07-06 16:00:00
tags: ElasticSearch
categories: Elastic Stack
---

Elasticsearch Mapping
<!-- more -->

# 什么是Mapping
mapping类似于数据库中schema的定义，作用如下
- 定义索引中字段的名称
- 定义字段的数据类型，例如字符串，数字，布尔等
- 字段，倒排索引的相关配置(Analyzed or Not Analyzed, Analyzer)

Mapping会吧JSON文档映射成Lucene所需要的扁平格式

一个Mapping属于一个索引的的Type
- 每个文档都属于一个Type
- 一个Type都有一个Mapping定义
- 7.0开始不需要在Mapping定义中指定Type信息

# API
## 查看Mapping
GET /my_index/_mappings

# 字段的数据类型
## 简单类型
- Text/Keyword
- Date
- Integer/Floating
- Boolean
- IPv4/IPv6

## 复杂类型
- 对象类型/嵌套类型

## 特殊类型
地理相关信息
- geo_point/geo_shape/percolator

# Dynamic Mapping
在写入文档的时候，如果索引不存在，会自动创建索引

Dynamic Mapping的机制，使得我们无需手动定义Mappings，Elasticsearch会自动根据文档的信息，推断出字段的类型。但推断并不一定准确，例如地理位置信息

当类型如果设置不对，会导致一些功能无法正常运行，例如Range查询

## 类型的自动识别
| JSON类型 | Elasticsearch类型 |
| -- | -- |
| 字符串 | 日期格式，设置成Date; 数字格式设置为Float或者Long，该选项默认关闭; 设置为Text并且增加Keyword子字段|
| 布尔值 | boolean |
| 浮点数 | float |
| 整数 | long |
| 对象 | Object |
| 数组 | 由第一个非空数值的类型所决定 |
| 空值 | 忽略 |

## 示例
# 写入文档
```
PUT /mapping_test/_doc/1
{
  "firstName" : "Bo",
  "lastName": "Liu",
  "loginDate":"2020-07-05T16:00:00.100Z"
}
```

# 查看mapping
```
GET /mapping_test/_mapping
{
  "mapping_test" : {
    "mappings" : {
      "properties" : {
        "firstName" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "lastName" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "loginDate" : {
          "type" : "date"
        }
      }
    }
  }
}
```

# 删除mapping
DELETE mapping_test

# 写入一个新文档
```
PUT /mapping_test/_doc/1
{
  "uid" : 10001,
  "isVip": true,
  "isAdmin":"false",
  "age":24,
  "heigh":170
}

{
  "mapping_test" : {
    "mappings" : {
      "properties" : {
        "age" : {
          "type" : "long"
        },
        "heigh" : {
          "type" : "long"
        },
        "isAdmin" : {
          "type" : "text",
          "fields" : {
            "keyword" : {
              "type" : "keyword",
              "ignore_above" : 256
            }
          }
        },
        "isVip" : {
          "type" : "boolean"
        },
        "uid" : {
          "type" : "long"
        }
      }
    }
  }
}
```

## 控制Dynamic Mappings
```
PUT mapping_test_2
{
  "mappings": {
    "dynamic" : "false"
  }
}
```

|  | true | false | strict |
| -- | -- | -- | -- |
| 文档可索引 | Y | Y | N |
| 字段可索引 | Y | N | N |
| Mapping被更新 | Y | N | N |

- 当dynamic被设置成false时，已存在的字段的数据会写入并且可以被索引，但新增字段会被丢弃
- 当dynamic被设置成strict时，数据写入会直接报错

# 更改Mapping的字段类型
## 新增字段
- Dynamic为true，一旦有新增字段的文档写入，Mapping也同时会被更新
- Dynamic为false，Mapping不会被更新，新增字段的数据无法被索引，但是信息会出现在_source中
- Dynamic为Strict(严格的)，文档写入会失败

对已有字段，一旦已经有数据写入，就不再支持修改字段定义。原因是Lucene实现的倒排索引，一旦生效后就不允许修改

如果希望改变字段类型，必须Reindex API重建索引

## 原因
- 如果修改了字段的数据类型，会导致无法搜索到已被索引的数据
- 新增字段则不会有该影响


# 注意点
## keyword
es的每个字段可以做多字段，例如，你有一个content的字段，类型是text。你可以为他指定一个子字段叫 keyword（也可以取名字叫kw）类型设置成keword，在做term查询时，就查询content.keyword（或者叫content.kw

es默认为所有文本都设置成text，并且设置keywoed的子字段

## mapping信息位置
mapping信息是保存在cluster state里面的.文件应该放在 nodes/{N}/_state/global-{NNN}下面

https://www.elastic.co/guide/en/elasticsearch/reference/current/cluster-state.html

## 使用动态mapping的隐患
设置成strict，万一有一条数据里带着不存在的字段，写入就会失败

设置成true，数据可以写入，还会在mapping中增加那个字段的设置。随着时间的流逝，这类数据会导致mapping设定的膨胀

## 选择使用ES的场景，及同步数据的思路
如果有全文搜索的需求。或者有统计分析的需求，都可以用es作为存储。数据可以在数据库里保存一份，定期同步到es中。然后对一些全文搜索的，对应es实现。

数据库和es同步可以考虑使用logstash的jdbc connector。只需要配置就可以实现增量同步。对于你说的物理删除的记录如何同步es，在logstash中不支持这个功能。但是你可以通过为数据增加isDeleted字段的方式。标记成删除状态。同步到es后 再用程序分别删除。

# 显式Mapping设置
```
PUT /mapping_test_3
{
  "mappings": {
    // define your mappings here
  }
}
```

## 建议
参考API手册，线创建一个临时index，写入一些样本数据，通过mapping API获取dynamic mapping生成的mapping定义，而后在此基础上对错误定义的进行修改，再删除临时的index，以减少自定义错误概览

## 控制当前字段是否被索引
index控制当前字段是否被索引，默认为true，如果设置成false，该字段不可被搜索

某些情况写部分字段不需要被搜索到，就可以减少倒排索引建立的空间开销
```
PUT user
{
  "mappings": {
    "properties": {
      "firstName":{
        "type": "text"
      },
      "lastName":{
        "type": "text"
      },
      "mobile":{
        "type": "text",
        "index": false
      }
    }
  }
}
```
## Index Options
ES提供了四种不同级别的倒排索引index options配置，可以控制倒排索引纪录的内容
- docs 记录doc id
- freqs 记录doc id和term frequencies
- positions 记录doc id/term frequencies/term position
- offsets doc id/term frequencies/term posistion/character offects

Text类型默认记录postions，其他默认为docs。记录内容越多，占用空间越大

## null_value
- 需要对null值实现搜索
- 只有Keyword类型支持设定Null_Vaule
```
GET user/_search?q=mobile:NULL

PUT user
{
  "mappings": {
    "properties": {
      "mobile":{
        "type": "keyword",
        "null_value": "NULL"
      }
    }
  }
}
```
## copy_to设置
_all在7中被copy_to替代了，满足一些特定的搜索需求，copy_to会将字段的数值拷贝到目标字段
- copy_to的目标字段不会出现在_source中
```
PUT user
{
  "mappings": {
    "properties": {
      "firstName":{
        "type": "text",
        "copy_to": "fullName"
      },
      "lastName":{
        "type": "text",
        "copy_to": "fullName"
      }
    }
  }
}

GET user/_search?q=fullName:(firstName lastName)
```

## 数组类型
ES不提供专门的数组类型。但是任何字段都可以包含多个相同类型的数值
```
PUT user/_doc/1
{
  "firstName": "Bo",
  "lastName": "Liu",
  "mobile": "13300001111"
}

PUT user/_doc/1
{
  "firstName": "Bo",
  "lastName": "Liu",
  "mobile": ["13300001111", "13300001112"]
}
```

# Exact Values精确词
包括数字、日期、具体的一个字符串，比如“Apple Store”。不需要做分词
- Elasticsearch中的keyword

Elasticsearch为每一个keyword字段创建一个倒排索引

# Full Text全文本
全文本，非结构化的文本数据，也就是Elasticsearch中的text。需要做分词

# Index Template
随着时间推移，集群上会有越来越多的索引。比如集群用作日志管理，每天都会为日志生成新的索引，这样子会为数据管理更加合理，也会有更好的性能。

Index Template可以帮助你设置Mappings和Settings的shards、replicas等，并按照一定的规则，自动匹配到新创建的索引之上
- 模版仅在一个索引被新创建时，才会产生作用。修改模版不会影响已创建的索引
- 可以设定多个索引模版，这些设置会被"merge"在一起
- 可以指定"order"的数值，控制"merging"的过程

```
PUT _template/template_default
{
  "index_patterns": ["*"],
  "order" : 0,
  "version": 1,
  "settings": {
    "number_of_shards": 1,
    "number_of_replicas":1
  }
}

PUT /_template/template_test
{
    "index_patterns" : ["test*"],
    "order" : 1,
    "settings" : {
    	"number_of_shards": 1,
        "number_of_replicas" : 2
    },
    "mappings" : {
    	"date_detection": false,
    	"numeric_detection": true
    }
}
```
## Index Template的工作方式
当一个索引被创建时，按照以下进行设置：
1. 应用Elasticsearch默认的settings和mappings
2. 应用order数值低的Index Template中的设定
3. 应用order数值高的Index Template中的设定，之前的设定会被覆盖
4. 应用创建索引时，用户所指定的settings和mappings，并覆盖之前模版中的设定

查看template信息
```
GET /_template/template_default
GET /_template/temp*
```

# Dynamic Template
Index Template是应用于所有的Index上的，Dynamic Template是应用与具体某个Index上的

根据Elasticsearch识别的数据额类型结合字段名称，来动态设置字段类型，设定了Dynamic Template就可以让文档中字段的推断符合预期了

使用场景例如：
- 所有的字符串类型都设定成keyword，或者关闭keyword字段
- is开头的字段都设置成boolean
- long开头的都设置成

```
# Dynaminc Mapping 根据类型和字段名
DELETE my_index

PUT my_index/_doc/1
{
  "firstName":"Ruan",
  "isVIP":"true"
}

GET my_index/_mapping

DELETE my_index

PUT my_index
{
  "mappings": {
    "dynamic_templates": [
            {
        "strings_as_boolean": {
          "match_mapping_type":   "string",
          "match":"is*",
          "mapping": {
            "type": "boolean"
          }
        }
      },
      {
        "strings_as_keywords": {
          "match_mapping_type":   "string",
          "mapping": {
            "type": "keyword"
          }
        }
      }
    ]
  }
}

DELETE my_index

# 结合路径
PUT my_index
{
  "mappings": {
    "dynamic_templates": [
      {
        "full_name": {
          "path_match":   "name.*",
          "path_unmatch": "*.middle",
          "mapping": {
            "type":       "text",
            "copy_to":    "full_name"
          }
        }
      }
    ]
  }
}

PUT my_index/_doc/1
{
  "name": {
    "first":  "John",
    "middle": "Winston",
    "last":   "Lennon"
  }
}

GET my_index/_search?q=full_name:John
```

- Dynamic Template是定义在某个索引的Mapping中
- Template有一个名称
- 匹配规则是一个数组
- 为匹配到字段设置Mapping