---
title: mybatis源码学习
date: 2019-03-20 10:00:00
tags: mybatis
categories: Java
---

朋友介绍说mybatis源码比较适合入门的源码学习，一直以来mybatis也只是停留在最基础的使用阶段，那接下来就打算学习下mybatis的源码，记录下笔记。
<!-- more -->

# 核心组成
- Configuration
- SqlSessionFactory
- Session
- Executor
- MappedStatement
- StatementHandler
- ResultSetHandler

# 包目录结构
- annotations 注解相关，如slect insert
- binding mapper相关
- builder dom操作、xml相关
- cache 缓存
- cursor 返回结果resultset
- datasourcer 数据源管理
- exceptions 自定义异常
- executor 执行器
- io classloader
- jdbc jdbc
- lang jdk7、jdk8
- logging 日志相关 
- mapping mapper相关的封装
- parsing xml解析
- plugin 拦截器
- reflection 反射相关
- scripting 
- session
- transaction 事务相关
- type

# 大概的执行流程
```
SqlSesionFactoryBuilder -> parse()
    Configuration -> build()
        SqlSessionFactory —> openSession() 
            SqlSession -> query()
                Executor -> newStatementHandler()
                    StatementHandler -> handlerResultSets()
                        ResultSetHandler
```
# SqlSessionFactoryBuilder
根据配置或者类，使用build()方法生成SqlSessionFacotry

主要使用的为
- InpuStream字节流 XMLConfigBuilder，解析XML配置创建DefaultSqlSessionFactory
- Reader字符流 同上
- Configuration 通过类的方式直接创建

## 设计模式
SqlSessionFactoryBuilder创建SqlSessionFactory采用了建造者的设计模式，相信大家一定非常熟悉，这里SqlSessionFactoryBuilder扮演具体的建造者，Configuration类则负责建造的细节工作，SqlSession则是构造出来的产品

# SqlSessionFactory
作用：通过openSession()生产SqlSession

# SqlSession
## 作用
1. 获取映射器，让映射器通过命名空间和方法名称找到对应的SQL，发送给数据库执行后返回结果
2. 通过update、insert、select、delete等方法，带上SQL的id来操作在XML中配置好的SQL，从而完成工作，与此同时它也支持事务，通过commit、rollback方法提交或者回滚事务。

## 四个主要对象            
### Executor
调度StatementHandler、ParameterHandler、ResultHandler等来执行对应的SQL。

ExecutorType
- SIMPLE 简易执行器，默认执行器
- REUSE 执行器重用预处理语句
- BATCH 执行器重用语句和批量更新，针对批量专用的执行器

### StatementHandler
使用数据库的Statement（PrepareStatement）执行操作

StatementHandler实现抽象类BaseStatementHandler的子类有以下三种，分别对应了不同类型的Executor
- SimpleStatementHandler：对应SIMPLE执行器
- PrepareStatementHandler：对应REUSE执行器
- CallableStatementHandler：对应BATCH执行器

### ParameterHandler
用于SQL对参数的处理

### ResultSetHandler
进行最后数据集（ResultSet）的封装返回处理


# Sql Mapper
作用：
1. 定义参数
2. 描述缓存
3. 描述SQL语句
4. 定义查询结果和POJO的映射关系

mapper接口类的全路径
mapper接口包的全路径
mapper接口全路径配置文件
xml配置文件引入映射器

# cache
``` java
CacheKey cacheKey = new CacheKey();
// 设置 id、offset、limit、sql 到 CacheKey 对象中
cacheKey.update(ms.getId());
cacheKey.update(rowBounds.getOffset());
cacheKey.update(rowBounds.getLimit());
cacheKey.update(boundSql.getSql());
```
mybatis缓存是一次数据库会话中的，commit等操作之后就不会存在了。


# InterceptorChain
在公司前段时间做数据权限就是基于InterceptorChain做的，是mybatis很重要的组成部分