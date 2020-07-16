---
title: ElasticSearch Search API
date: 2020-06-23 10:00:00
tags: ElasticSearch
categories: Elastic Stack
---

已经有一段时间没有学习ES了，最近因为要使用SkyWalking所以还是重新抓起来ES进行学习。

<!-- more -->

# Search API概览
- URI Search 在URL中使用查询参数
- Request Body Search 使用ElasticSearch提供的，基于JSON格式，更加完备的Query Domain Specific Language(DSL)

## 指定查询的索引
| 语法 | 范围 | 
| -- | -- |
| /_search | 集群上的所有索引 |
| /index_1/_search | index_1 |
| /index_1,index_2/_search | index_1和index_2 |
| /index*/_search | 以index开头的索引 |

## URI查询
- 使用"q"指定查询字符串
- "query string syntax" KV键值对
```
curl -XGET
"http://elasticsearch:9200/index_name/_search?q=customer_first_name:xxx"

搜索属性customer_first_name为xxx的数据
```

## Request Body查询
- 支持GET和POST
```
curl -XGET
"http://elasticsearch:9200/index_name/_search"
-H 'Content-Type: application/json' 
-d '
{
    "query": {
        "match_all": {}
    }
}
'
```

## 搜索后Response
- took 花费的时间
- total 符合条件的总文档数
- hits 结果集，默认前10个文档
- _index 索引名称
- _id 文档的ID
- _score 相关度评分
- _source 文档原始信息

## 搜索的相关性 Relevance
- 搜索是用户和搜索引擎的对话
- 用户关心的是搜索结果的相关性
    - 是否可以找到所有相关的内容
    - 有多少不相关的信息被返回了
    - 文档打分是否合理
    - 结合业务需求，平衡结果排名

## Page Rank算法
- 不仅仅是内容
- 更重要的是内容的可信度

## 衡量相关性 Information Retrieval
- Precision(查准率) 尽可能返回较少的无关文档
- Recall(查全率) 尽量返回较多的相关文档
- Ranking 是否能够按相关度进行排序

# profile API
通过在query部分中加入"profile":"true"，来启用profile API，返回结果中会有profile属性，表示本次查询是如何执行的

## profile API响应说明

每个分片都被分配一个唯一的ID，ID的格式是[nodeID][indexName][shardID]。现在在"shards"数组里还有另外三个元素
### Query
Query 段由构成Query的元素以及它们的时间信息组成。Profile API结果中Query 部分的基本组成是：

- type 它向我们显示了哪种类型的查询被触发。此处是布尔值。因为多个关键字匹配查询被分成两个布尔查询
- description 该字段显示启动查询的lucene方法
- time lucene 执行此查询所用的时间。单位是毫秒
- time_in_nanos lucene 执行此查询所用的时间。单位是微秒
- breakdown 有关查询的更详细的细节，主要与lucene参数有关
- children 具有多个关键字的查询被拆分成相应术语的布尔查询，每个查询都作为单独的查询来执行。每个子查询的详细信息将填充到Profile API输出的子段中。下面给出查询时间和其他breakdown参数等详细信息。从查询中的子段中，我们可以得到关于哪个搜索项在总体搜索中造成最大延迟的信息

### Rewrite Time
由于多个关键字会分解以创建个别查询，所以在这个过程中肯定会花费一些时间。将查询重写一个或多个组合查询的时间被称为“重写时间”。(以纳秒为单位)

### Collector
在Lucene中，收集器是负责收集原始结果，收集和组合结果，执行结果排序等的过程。例如，在上面的执行的查询中，当查询语句中给出size:0时，使用的收集器是"totalHitCountCollector"。这只返回搜索结果的数量(search_count)，不返回文档。此外，收集者所用的时间也一起给出了

# URI Search
- q 指定查询语句，使用Query String Syntax
- df 默认字段，不指定时会对所有字段进行查询
- Sort 排序
- from、size 用于分页
- profile 是否查看执行计划

```
# 基本查询
GET /movies/_search?q=2012&df=title&sort=year:desc&from=0&size=10&timeout=1s

# 带profile
GET /movies/_search?q=2012&df=title
{
	"profile":"true"
}

# 泛查询，正对_all,所有字段
GET /movies/_search?q=2012
{
	"profile":"true"
}

# 指定字段
GET /movies/_search?q=title:2012&sort=year:desc&from=0&size=10&timeout=1s
{
	"profile":"true"
}

# 查找美丽心灵, Mind为泛查询
GET /movies/_search?q=title:Beautiful Mind
{
	"profile":"true"
}

# 泛查询
GET /movies/_search?q=title:2012
{
	"profile":"true"
}

# 使用引号，Phrase查询
GET /movies/_search?q=title:"Beautiful Mind"
{
	"profile":"true"
}

# 分组，Bool查询
GET /movies/_search?q=title:(Beautiful Mind)
{
	"profile":"true"
}

# 布尔操作符
# 查找美丽心灵
GET /movies/_search?q=title:(Beautiful AND Mind)
{
	"profile":"true"
}

# 查找美丽心灵
GET /movies/_search?q=title:(Beautiful NOT Mind)
{
	"profile":"true"
}

# 查找美丽心灵
GET /movies/_search?q=title:(Beautiful %2BMind)
{
	"profile":"true"
}

# 范围查询 ,区间写法
GET /movies/_search?q=title:beautiful AND year:[2002 TO 2018%7D
{
	"profile":"true"
}

# 通配符查询
GET /movies/_search?q=title:b*
{
	"profile":"true"
}

# 模糊匹配&近似度匹配
GET /movies/_search?q=title:beautifl~1
{
	"profile":"true"
}

GET /movies/_search?q=title:"Lord Rings"~2
{
	"profile":"true"
}
```

## Query String Syntax
### 指定字段与泛查询
```
q=title:2020 
q=2020
```

### Term与Phrase
```
Beautiful Mind，等效于Beautiful OR Mind
"Beautiful Mind"，等效于Beautiful AND Mind，同时Phrase查询还要求前后顺序保持一致
```

### 分组与引号
```
title:(Beautiful AND Mind)
title="Beautiful Mind"
```

### 布尔操作
AND / OR / NOT 或者&& / || / ! 必须大写
```
title:(matrix NOT reloaded)
```

### 分组
- "+" 表示must
- "-" 表示must_not
```
title:(+matrix -reloaded)
```

### 查询范围
- [] 闭区间
- {} 开区间
```
year:[* TO 2020]
year:{2020 TO 2025}
```

### 算数符号
```
year:>2020
year:(>2020 && <=2025)
year:(+>2020 +<=2025)
```

### 通配符查询
通配符查询效率底，占用内存大，不建议使用。
- "?" 代表一个字符
- "*" 代表多个字符
```
title:mi?d
title:be*
```

### 正则表达式
```
title:[bt]oy
```

### 模糊匹配与相近查询
```
title:befutifl~1
title:"lord rings"~2
```

# Request Body Search
- 将查询语句通过HTTP Request Body发送给Elasticsearch
- 使用Query DSL
```
GET /my_index/_search?ignore_unavailable=true
{
  "profile": "true",
  "query": {
    "match_all": {}
  }
}
```

## 分页
从0开始，默认返回10个结果，获取靠后的记录翻页成本较高
- from 开始位置
- size 页码大小

## 排序
- 最好在"数字型"与"日期型"字段进行排序
- 因为对于多值类型或分析过的字段排序，系统会选一个值，无法得知该值
```
GET /my_index/_search?ignore_unavailable=true
{
  "profile": "false",
  "sort": [
    {
      "updated_at":  "asc"
    }
  ], 
  "from": 0,
  "size": 10, 
  "query": {
    "match_all": {}
  }
}
```
语法有两种
```
"sort": [
  {
    "FIELD": {
      "order": "desc"
    }
  }
]
或者
"sort": [
  {
    "FIELD": "desc"
  }
]
```

## _Source Filtering
如_source没有存储，那就只返回匹配文档的元数据，另外_source支持使用通配符，如_source["name*","type*"]

```
GET /my_index/_search?ignore_unavailable=true
{
  "profile": "false",
  "_source": ["type", "updated_at"], 
  "from": 0,
  "size": 10, 
  "query": {
    "match_all": {}
  }
}

单字段
"_source": "type", 

多字段
"_source": ["type", "updated_at"], 
```

## 脚本字段
script_fields，对多个列进行函数操作。可以方便对字段进行函数操作后排序等
```
GET /my_index/_search?ignore_unavailable=true
{
  "profile": "false",
  "script_fields": {
    "new_field": {
      "script": {
        "lang": "painless",
        "source": "doc['updated_at'].value+'_Hello'"
      }
    }
  }, 
  "from": 0,
  "size": 10, 
  "query": {
    "match_all": {}
  }
}
```

## 查询表达式query match

### match query
match的key是field，value是值，value可以用空格分割，相当于or。
```
POST /logstash-2020.07.02-000001/_search
{
  "profile":false,
  "query": {
    "match": {
      "message": "1996"
    }
  }
}
```

也可以match某个field，query指具体查询内容，operator是条件类型
```
POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "match": {
      "message": {
        "query": "Love 1964",
        "operator": "and"
      }
    }
  }
}
```

### match_phrase query
指定feild进行词组查询
```
POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "match_phrase": {
      "message": "Fair Game"
    }
  }
}
```

也可以使用slop来控制在词组插入指定数量的term进行查询
```
POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "match_phrase": {
      "message": {
        "query": "Fair Game",
        "slop": 1
      }
    }
  }
}
```

## Query String Query
类似URI Query
```
POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "query_string": {
      "default_field": "message",
      "query": "Love AND 1964"
    }
  }
}


POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "query_string": {
      "fields": ["message"],
      "query": "(Roses AND 1996)"
    }
  }
}
```

## Simple Query String Query
- 类似Query String，但是会忽略错误的语法，同时只支持部分查询语法
- 不支持AND OR NOT，会当作字符串处理
- Term之间默认的关系是OR，可以指定Operator
- 支持部分逻辑
```
+ 替代 AND
| 替代 OR
- 替代 NOT
```

```
POST /logstash-2020.07.02-000001/_search
{
  "query": {
    "simple_query_string": {
      "query": "Roses -1996", 
      "fields": ["message"]
      , "default_operator": "AND"
    }
  }
}
```