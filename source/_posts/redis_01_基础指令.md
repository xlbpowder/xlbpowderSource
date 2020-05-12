---
title: redis基础指令
date: 2019-03-11 10:00:00
tags: redis
categories: 中间件
---

学习一些基础指令

<!-- more -->

# string
- get
- set
- exists 是否存在
- del
- mget

失效时间设置
- EXPIRE key seconds为给定 key 设置过期时间，以秒计。
- EXPIREAT key timestamp EXPIREAT 的作用和 EXPIRE 类似，都用于为 key 设置过期时间。 不同在于 EXPIREAT 命令接受的时间参数是 UNIX 时间戳(unix timestamp)。
- PEXPIRE key milliseconds 设置 key 的过期时间以毫秒计。

- PERSIST key 移除 key 的过期时间，key 将持久保持。
- PTTL key 以毫秒为单位返回 key 的剩余的过期时间。
- TTL key 以秒为单位，返回给定 key 的剩余生存时间(TTL, time to live)。

- setex key s value 相当于set+expire
- setnx key value 如果key不存在就执行set

# 原子计数
- set key num
- incr key +1
- decr key -1
- incrby key num +num
范围 signed long


# 列表 list链表，插入删除O(1)，查询慢o(n)
队列 进先出(FIFO-first in first out):
> <- x,x,x <-
- rpush key val1 val2 vals
- llen key
- lpop key

栈 后进先出(LIFO-last in first out):
> x,x,x <=>
- rpush key val1 val2 vals
- rpop

# Hash
- hset key field1 value1
- hget key field1
- hgetall key 查看全部属性、值
- hmset key field1 val1 field2 val2 

# set
- sadd key value
- smembers key
- sismember key value 是否存在
- scard key 获取长度
- spop key


# zset


# keys
- KEYS pattern
- scan 游标 match 表达式 count 数量


# redis服务信息
- info 查看redis服务运行信息，server、client、memory、persistence 状态 主从复制信息 cpu 集群信息，键值对数据统计
...
