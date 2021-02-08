---
title: web架构基础
date: 2021-02-02 10:00:00
tags: web协议
categories: 架构
---

了解REST架构是如何从WEB五种架构推演而来的，以及在推演过程中放弃了什么，选择了什么

<!-- more -->
# 网络架构属性
## 性能
### 网络性能 Network Performance
- Through 吞吐量：小于等于带宽bandwidth
- Overhead 开销：首次开销、每次开销

### 用户感知到的性能 User-perceived Performance
- Latency 延迟：发起请求到接收到响应的时间
- Completion 完成时间：完成一个应用动作所花费的时间

### 网络效率 network Efficiency
- 重用缓存
- 减少交互次数
- 数据传输举例更近
- COD

## 可修改性
### 可进化性 Evolvability 
一个组件独立升级而不影响其他组件

### 可扩展性 Extensibility
向系统添加功能，而不会影响到系统的其他部分

### 可定制性 Customizability
临时性、定制性地更改某一要素来提供服务，不对常规客户产生影响

### 可配置性 Configurability
应用部署后可通过修改配置提供新的功能

### 可重用性 Reusability
组件可以不做修改在其他应用再使用

# 五类架构风格推导出HTTP的REST架构
## 数据流风格 Data-flow Styles
优点：简单、可进化、可扩展、可配置、可重用
### 管道与过滤器 Pipe And Filter（PF）
- 每一个Filter都有输入端和输出端，只能从输入端读取数据，处理后再从输出端产生数据

### 统一接口的管道与过滤器 Uniform Pipe And Filter（UPF）
- 在PE上增加统一接口的约束，所有的Filter过滤器必须具备同样的接口

## 复制风格 Replication Styles
优点：用户可察觉性、可伸缩、网络效率、可靠性
### 复制仓库 Replicated Respository（RR）
- 多个进程提供相同服务，通过反向代理对外提供集中服务

### 缓存（$）
- RR的变体，通过复制请求的结果，为后续请求复用

## 分层风格 Hierarchical Styles
优点：简单、可进化、可伸缩
### 客户端服务器 Client-Server（CS）
- 用Client触发请求，Server监听到请求后产生响应，Client一直等待收到响应后会话才结束
- 分离关注点，隐蔽细节，简单并且具有有良好的可伸缩性、可进化性、
### 分层服务 Layered System（LS）
- 每一层为其上一层服务，并使用在其下一层所提供的服务，同时还为下一层提供的服务隐藏细节，例如TCP/IP
### 分层客户端服务器 Layered Client-Server（LCS）
- LS+CS 例如正向代理和反向代理，从空间上分为外部层和内部层
### 无状态 客户端服务器 Client-Stateless-Server（CSS）
- 基于CS，服务器上不允许有session state会话状态
- 提升了可见性、可伸缩性、可靠性，但重复数据可能会导致降低网络性能
### 缓存 无状态 客户端服务器 Client-Cache-Stateless-Server（C$SS）
- 提升性能
### 分层 缓存 无状态 客户端服务器 Layered-Client-Cache-Stateless-Server（LC$SS）

> 分层架构中没有使用的两类分层风格
### 远程会话 Remote Session（RS）
- CS变体，服务器保存Application State应用状态
- 可伸缩性、可见性差
### 远程数据访问 Remote Data Access（RDA）
- CS变体，Application State应用状态同时分布在客户端与服务器
- 巨大的数据集有可能通过迭代而减少
- 简单性、可伸缩性较差

## 移动代码风格 Mobile Code Styles
> 代码与执行过程或执行结果分离，如JavaScript

优点：可移植、可扩展、网络效率

### 虚拟机 Virtual Machine（VM）
- 指令与实现
### 远程求值 Remote Evaluation（REV）
- 基于CS的VM，将代码发送至服务器执行
### 按需代码 Code on Demand（COD）- 服务器在响应中发回处理代码，在客户端执行
- 优秀的可扩展性和可配置性，提升用户可察觉性能和网络效率
### 分层、按需代码、缓存、无状态、客户端服务器 Layered-Code-on-Demand-Client-Cache-Stateless-Server（LCODC$SS）
- LC$SS + COD
### 移动代理 Mobile Agent（MA）
- 相当于REV + CODE

## 点对点风格 Peer-to-Peer Styles
> 未REST架构中，但在分布式网络架构中经常使用

优点：可进化、可重用性、可扩展性、可配置性

### Event-based Integration（EBI）
- 基于事件集成系统，如消息中间件，通过分发订阅来消除耦合
- 优秀的可重用性、可扩展性、可进化性
- 缺乏可理解性
- 由于消息广播等因素造成消息风暴，可扩展性差
### Chiron-2（C2）
- 相当于EBI + LCS，可以控制消息的方向
### Distributed Objects（DO）
- 组件结对交互
### Brokered Distributed objects（BDO）
- 引入名字解析组件来简化DO，例如CORBA

# REST架构对于WEB五种架构的融合
![00](/image/web/REST架构对于WEB架构的融合.png)
