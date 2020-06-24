---
title: 倒排索引
date: 2020-06-23 11:00:00
tags: ElasticSearch
categories: Elastic Stack
---

倒排索引的简单介绍

<!-- more -->
# 正排索引

书本的目录页，大致就可以得知这本书的内容分布结构，以及每个章节的页码数。所以书本的目录，就是这本书的简单索引。

![es01](/image/ElasticSearch/inverted_index_01.png)

## 正排索引和倒排索引

### 正排索引举例
| 文档ID | 文档内容 |
| -- | -- |
| 1 | Mastering Elasticsearch |
| 2 | Elasticsearch Server |
| 3 | Elasticsearch Essentials |

### 倒排索引举例
| Term | Count | DocumentId:Position |
| -- | -- | -- |
| Elasticsearch | 3 | 1:1, 2:0, 3:0 |
| Mastering | 1 | 1:0 |
| Server | 1 | 2:1 |
| Essentials | 1 | 3:1 |

```
正排索引  --索引--> 倒排索引
正排索引 <--查询--  倒排索引
```

# 倒排索引核心组成
## 单词词典(Term Dictionary)
记录所有文档的单词，记录单词到倒排列表的关联关系。单词词典一般比较大，可以通过B+树或者哈希拉链法实现，以满足高性能的插入与查询

## 倒排列表(Posting List)
记录了单词对应的文档结合，由倒排索引项组成

### 倒排索引项(Posting)
- 文档ID
- 词频TF 该单词在文档中出现的次数，用于相关性评分
- 位置(Position) 单词在文档中分词的位置，用于语句搜索(phrase query)
- 偏移(Offset) 记录单词的开始结束位置，实现高亮显示

![es02](/image/ElasticSearch/inverted_index_02.png)

# Elasticsearch的倒排索引
- Elasticsearch的JSON文档中的那个字段，都有自己的倒排索引
- 可以指定对某些字段不做索引，优点是节省存储空间，缺点是字段无法被搜索到
