---
title: Configuring Logstash for Docker
date: 2020-07-01 10:00:00
tags: 
    - Logstash
    - docker
categories: Elastic Stack
---

通过Docker启动Logstash的一些需要注意的配置。主要都是从elastic.io官网上找的，翻译了下

<!-- more -->

# Pipeline Configuration
pipeline配置文件的路径
```
docker run --rm -it -v ~/pipeline/:/usr/share/logstash/pipeline/ docker.elastic.co/logstash/logstash:7.8.0
```

如果未提供任何配置，则会以最小配置运行，并且监听beats input插件的消息进行stdout，默认配置如下：
```
Sending Logstash logs to /usr/share/logstash/logs which is now configured via log4j2.properties.
[2016-10-26T05:11:34,992][INFO ][logstash.inputs.beats    ] Beats inputs: Starting input listener {:address=>"0.0.0.0:5044"}
[2016-10-26T05:11:35,068][INFO ][logstash.pipeline        ] Starting pipeline {"id"=>"main", "pipeline.workers"=>4, "pipeline.batch.size"=>125, "pipeline.batch.delay"=>5, "pipeline.max_inflight"=>500}
[2016-10-26T05:11:35,078][INFO ][org.logstash.beats.Server] Starting server on port: 5044
[2016-10-26T05:11:35,078][INFO ][logstash.pipeline        ] Pipeline main started
[2016-10-26T05:11:35,105][INFO ][logstash.agent           ] Successfully started Logstash API endpoint {:port=>9600}
```

# Bind-mounted settings files
```
docker run --rm -it -v ~/settings/:/usr/share/logstash/config/ docker.elastic.co/logstash/logstash:7.8.0
```

如果只挂载单个logstash.yml配置文件
```
docker run --rm -it -v ~/settings/logstash.yml:/usr/share/logstash/config/logstash.yml docker.elastic.co/logstash/logstash:7.8.0
```

安装的配置文件将在容器内保留与主机系统相同的权限。需要保证设置权限方便容器的Logstash可用户可以读取文件。理想情况下，容器的logstash用户应该是只读权限(UID 1000)

# Custom Images 自定义镜像
使用公共镜像绑定配置不是唯一选择，可以编写dockerfile定制镜像
```
FROM docker.elastic.co/logstash/logstash:7.8.0
RUN rm -f /usr/share/logstash/pipeline/logstash.conf
ADD pipeline/ /usr/share/logstash/pipeline/
ADD config/ /usr/share/logstash/config/
```
确保替换或删除logstash.conf自定义映像，以免保留基本映像中的示例配置。

# Environment variable configura 环境变量配置
在Docker启动Logstash的场景下，可以用过环境变量配置Logstash设置。容器启动时候，程序会在环境中检查可映射到Logstash设置的变量。

为了与容器编排系统兼容，这些环境变量以大写形式编写，下划线作为单词分隔符

| 环境变量 | Logstash配置 |
| -- | -- |
| PIPELINE_WORKERS | pipeline.workers |
| LOG_LEVEL | log.level |
| MONITORING_ENABLED | monitoring.enabled |

不建议安装版的logstash配置文件与环境变量配置结合使用

# Docker defaults
使用docker镜像时的默认配置，这些设置默认值设置在logstash.yml中，可以自定义logstash.yml或者环境变量进行修改
- http.host 0.0.0.0
- monitoring.elasticsearch.hosts http://elasticsearch:9200

# Loggin Configuration
在Docker下，Logstash日志默认情况下进入标准输出。要更改此行为，请使用上述任何技术替换处的文件
```
/usr/share/logstash/config/log4j2.properties
```