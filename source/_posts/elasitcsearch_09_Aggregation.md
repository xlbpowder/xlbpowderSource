---
title: ElasticSearch 聚合
date: 2020-07-15 14:00:00
tags: ElasticSearch
categories: Elastic Stack
---

Elasticsearch Aggregation聚合
<!-- more -->

# 什么是Aggregation聚合
Elasticsearch除了搜索以外，提供了针对ES数据进行统计分析的功能，就称为Aggregation

- 实时性高，例如Hadoop通常为T+1
- 通过聚合，我们会得到一个数据的概览，是分析和总结全套的数据，而不是寻找单个文档
- 高性能，只需要一条语句，就可以通过Elasticsearch得到分析的结果，无需在客户端自己去实现分析逻辑

Kibana可视化报表，大量的可视化报表都是用es的聚合分析实现的

# 集合的分类
- Bucket Aggregation: 一些列满足特定条件的文档集合
- Metric Aggregation: 一些数学运算，可以对文档字段进行统计分析
- Pipeline Aggregation: 对其他的聚合结果进行二次聚合
- Matrix Aggregation: 支持对多个字段的操作并提供一个结果矩阵

## Bucket
一组满足条件的文档，相当于SQL中的GROUP BY的条件，Elasticsearch提供了很多类型的Bucket，比如Term&Range（时间/年龄区间/地理位置）

## 例子
按照字段的Terms进行分桶
```
# 按照目的地进行分桶统计
GET kibana_sample_data_flights/_search
{
	"size": 0,
	"aggs":{
		"flight_dest":{
			"terms":{
				"field":"DestCountry"
			}
		}
	}
}
```

## Metric
一系列的统计方法，相当于SQL中的列函数

Metric会基于数据集计算结果，除了支持在字段上进行计算，同样也支持在脚本（painless script）产生的结果之上进行计算。

大多数Metric是数学计算，仅输入一个值
- min
- max
- sum
- avg
- cardinality

部分metric支持输出多个数值
- stats
- percentiles
- percentile_ranks

### 例子
```
# 查看航班目的地的统计信息，增加平均，最高最低价格
GET kibana_sample_data_flights/_search
{
	"size": 0,
	"aggs":{
		"flight_dest":{
			"terms":{
				"field":"DestCountry"
			},
			"aggs":{
				"avg_price":{
					"avg":{
						"field":"AvgTicketPrice"
					}
				},
				"max_price":{
					"max":{
						"field":"AvgTicketPrice"
					}
				},
				"min_price":{
					"min":{
						"field":"AvgTicketPrice"
					}
				}
			}
		}
	}
}
```
- aggs 关键词-aggs
- average_price/max_price/min_price 自定义名字
- avg/max/min 不同的分析类型

## 嵌套
```
# 价格统计信息+天气信息
GET kibana_sample_data_flights/_search
{
	"size": 0,
	"aggs":{
		"flight_dest":{
			"terms":{
				"field":"DestCountry"
			},
			"aggs":{
				"stats_price":{
					"stats":{
						"field":"AvgTicketPrice"
					}
				},
				"wather":{
				  "terms": {
				    "field": "DestWeather",
				    "size": 5
				  }
				}

			}
		}
	}
}
```