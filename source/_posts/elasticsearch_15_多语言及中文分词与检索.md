---
title: ElasticSearch 多语言及中文分词与检索
date: 2020-08-04 14:00:00
tags: ElasticSearch
categories: Elastic Stack
---

<!-- more -->
# 自然语言与查询Recall

## 一些可以采取的优化
- 归一化词语元：消除变音富豪，如`rôle`也会匹配`role`
- 抽取词根：清除单复数和时态的差异
- 包含同义词
- 拼写错误：拼写错误，或者同音异形词

# 混合多语言的挑战
一些多语言场景
- 不同的索引使用不同的语言/同一个索引中
- 不同的字段使用不同的语言/一个文档的一个字段內混合不同的语言

- 词干提取：以色列文档，包含了希伯来语、阿拉伯语、俄语和英语
- 不正确的文档词频： 英文为主的文章中，德文算分高，因为德文单词稀有
- 需要判断用户搜索时使用的语言，语言识别（Compact Language Detector）。例如，根据语言查询不同的索引

# 分词的挑战
## 英文分词
`You're`分成一个还是多个，`Half-baked`是否要拆分

## 中文分词
### 分词标准
- 哈工大标准 姓名是分开的
- HanLP标准 姓名在一起

### 歧义
- 组合型歧义
- 交集型歧义
- 真歧义

# 中文分词方法的演变
## 字典法
查字典，最容易想到的分词方法（北京航空大学的梁南元教授提出的）
- 一个句子从左到右扫描一遍，遇到有的词就标示出来。找到复合词，就找最长的
- 不认识的字符串就分割成单字词

## 最小词数的分词理论（哈工大王晓龙博士）字典方法理论化
- 一句话应该分成数量最少的词串
- 遇到二义性的分割，无能为力
- 用各种文化规则来解决二义性，都并不成功

## 统计语言模型 - 1990年前后，清华大学电子工程系郭进博士
- 解决了二义性问题，将中文分词的错误率降低了一个数量级。概率问题，动态规划+利用维特比算法快速找到最佳分词

## 基于统计法的机器学习算法
这类目前最常用的算法是HMM、CRF、SVM、深度学习等算法。比如HanLP分词工具是基于CRF算法。
以CRF为例，基本思路是对汉字进行标注训练，不仅考虑了词语出现的频率，还考虑上下文，具备较好的学习能力，因此其对歧义词和未登录词的识别都具有良好的效果

随着深度学习的兴起，也出现了基于神经网络的分词器。有人尝试过使用双向LSTM+CRF实现分词器，其本质上是序列标注，据报道其分词器自负准确率可高达97.5%

常见的分词器都是使用机器学习算法和字典相结合，一方面能够提高分词准确率，另一方面能够改善领域适应性

# 一些中文分词器
## HanLP 面向生产环境的自然语言处理工具包
- http://hanlp.com/
- https://github.com/KennFalcon/elasticsearch-analysis-hanlp

## IK分词器
- https://github.com/medcl/elasticsearch-analysis-ik


## 安装插件
```
$ ./elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.1.0/elasticsearch-analysis-ik-7.1.0.zip

$ bin/elasticsearch install https://github.com/KennFalcon/elasticsearch-analysis-hanlp/releases/download/v7.1.0/elasticsearch-analysis-hanlp-7.1.0.zip

```

## HanLP示例
### 分类
- hanlp: hanlp默认分词
- hanlp_standard: 标准分词
- hanlp_index: 索引分词
- hanlp_nlp: NLP分词
- hanlp_n_short: N-最短路分词
- hanlp_dijkstra: 最短路分词
- hanlp_crf: CRF分词（在hanlp 1.6.6已开始废弃）
- hanlp_speed: 极速词典分词
``` json
POST _analyze {
	"analyzer": "hanlp_standard",
	"text": ["剑桥分析公司多位高管对卧底记者说，他们确保了唐纳德·特朗普在总统大选中获胜"]

}

PUT / artists / {
	"settings": {
		"analysis": {
			"analyzer": {
				"user_name_analyzer": {
					"tokenizer": "whitespace",
					"filter": "pinyin_first_letter_and_full_pinyin_filter"
				}
			},
			"filter": {
				"pinyin_first_letter_and_full_pinyin_filter": {
					"type": "pinyin",
					"keep_first_letter": true,
					"keep_full_pinyin": false,
					"keep_none_chinese": true,
					"keep_original": false,
					"limit_first_letter_length": 16,
					"lowercase": true,
					"trim_whitespace": true,
					"keep_none_chinese_in_first_letter": true
				}
			}
		}
	}
}

GET / artists / _analyze {
	"text": ["刘德华 张学友 郭富城 黎明 四大天王"],
	"analyzer": "user_name_analyzer"
}
```

# 相关资源
- Elasticsearch IK分词插件 https://github.com/medcl/elasticsearch-analysis-ik/releases
- Elasticsearch hanlp 分词插件 https://github.com/KennFalcon/elasticsearch-analysis-hanlp

- 分词算法综述 https://zhuanlan.zhihu.com/p/50444885

## 一些分词工具，供参考：
- 中科院计算所NLPIR http://ictclas.nlpir.org/nlpir/
- ansj分词器 https://github.com/NLPchina/ansj_seg
- 哈工大的LTP https://github.com/HIT-SCIR/ltp
- 清华大学THULAC https://github.com/thunlp/THULAC
- 斯坦福分词器 https://nlp.stanford.edu/software/segmenter.shtml
- Hanlp分词器 https://github.com/hankcs/HanLP
- 结巴分词 https://github.com/yanyiwu/cppjieba
- KCWS分词器(字嵌入+Bi-LSTM+CRF) https://github.com/koth/kcws
- ZPar https://github.com/frcchang/zpar/releases
- IKAnalyzer https://github.com/wks/ik-analyzer
