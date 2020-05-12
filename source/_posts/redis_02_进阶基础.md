---
title: redis持久化、淘汰策略、高可用方案的基础
date: 2020-03-12 10:00:00
tags: redis
categories: 中间件
---

学习一些redis的进阶知识基础
<!-- more -->

3.x
4.x ruby 
5.0 C语言 集群配置等更简单


# 持久化
## RDB快照 snapshop
dump.rdb二进制文件保存

redis.conf中，save seconds changes进行配置，设置为save ""则为关闭

## AOF append-only file
redis.conf中
- appendonly no 修改为yes开启
- appendfilename 默认appendonly.aof，保存的都是命令 resp协议 
- appendfsync 持久化方式和频率
    - always 每次新命令都追加到AOF文件时候执行一次fsync，效率低，数据安全
    - everysec 每秒fsync一次
    - no 从不fsync

RDB可能会存在数据丢失
AOF大数据量恢复速度相比RDB要慢

AOF rewirte重写
- bgrewriteaof 手动触发重写指令

- auto-aof-rewrite-percentage 100 AOF自动重写百分比
- auto-aof-rewrite-min-size 64mb AOF自动重写最小容量


### 4.0后支持混合持久化
aof-use-rdb-preamble yes
appendonly.aof文件中记录的RDB格式 + AOF格式

如果RDB和AOF都开启，默认会使用AOF进行数据恢复


# 缓存淘汰策略
当redis内存超过物理内存限制的时候，内存数据会开始与磁盘产生频繁的交换(swap)，由于涉及到磁盘IO操作，redis的性能会急剧下降。

当实际内存超出maxmemory时，redis提供了几种可选策略(maxmemory-policy)来让来决定该如何调整出新的空间继续提供读写服务
- LRU（Least Recently Used，最近最少使用）
- LFU（Least Frequently Used ，最不频繁使用）

- volatile 设置了失效时间
- allkeys 全部key
```
# volatile-lru -> Evict using approximated LRU among the keys with an expire set.
# allkeys-lru -> Evict any key using approximated LRU.
# volatile-lfu -> Evict using approximated LFU among the keys with an expire set.
# allkeys-lfu -> Evict any key using approximated LFU.
# volatile-random -> Remove a random key among the ones with an expire set.
# allkeys-random -> Remove a random key, any key.
# volatile-ttl -> Remove the key with the nearest expire time (minor TTL)
# noeviction -> Don't evict anything, just return an error on write operations.
```

# 高可用
## Redis Sentinel(哨兵模式)
由若干sentinel节点组成的分布式集群，可以实现故障发现、故障自动转移、配置中心和客户端通知。sentinel的节点数量要满足2n+1(n>=1)个的奇数个。

两个集群在同时工作，一个是sentinel集群，一个是数据节点的集群(master-slave)

客户端会先连接一个sentinel实例，使用SENTINEL get-master-addr-by-name master-name 获取Redis地址信息。连接返回的Redis地址信息，通过ROLE命令查询是否是Master。如果是，连接进入正常的服务环节。否则应该断开重新查询。

配置文件sentinel.conf
- min-slaves-to-write 1
- min-slaves-max-lag 10

## Redis Cluster(集群模式)
redis官方提供的新的集群配置。由多个主从节点群组成的分布式服务群，具有复制、高可用、分片的特性。不需要sentinel哨兵也能完成节点的移除和故障转移的功能。

至少要有三个Master节点

修改配置文件
- cluster-enabled yes 启动集群模式
- cluster-config-file 集群节点配置文件
- cluster-node-timeout ms 集群节点的超时时间
- 去除客户端访问 # bind 127.0.0.1
- protected-mode no 关闭保护模式
需要密码则配置
- requirepass xxx 设置密码
- masterauth xxx 集群通信设置master密码

4.0用/src/redis-trib.rb 一个ruby脚本，5.0使用redis-cli --cluster就可以配置集群了


```
[root@iZwz9bvlfc3n574x9ygoj9Z /root/redis-5.0.3]$./src/redis-cli --cluster help
Cluster Manager Commands:
  create         host1:port1 ... hostN:portN
                 --cluster-replicas <arg>
  check          host:port
                 --cluster-search-multiple-owners
  info           host:port
  fix            host:port
                 --cluster-search-multiple-owners
  reshard        host:port
                 --cluster-from <arg>
                 --cluster-to <arg>
                 --cluster-slots <arg>
                 --cluster-yes
                 --cluster-timeout <arg>
                 --cluster-pipeline <arg>
                 --cluster-replace
  rebalance      host:port
                 --cluster-weight <node1=w1...nodeN=wN>
                 --cluster-use-empty-masters
                 --cluster-timeout <arg>
                 --cluster-simulate
                 --cluster-pipeline <arg>
                 --cluster-threshold <arg>
                 --cluster-replace
  add-node       new_host:new_port existing_host:existing_port
                 --cluster-slave
                 --cluster-master-id <arg>
  del-node       host:port node_id
  call           host:port command arg arg .. arg
  set-timeout    host:port milliseconds
  import         host:port
                 --cluster-from <arg>
                 --cluster-copy
                 --cluster-replace
  help

For check, fix, reshard, del-node, set-timeout you can specify the host and port of any working node in the cluster.

```

常用详解
- redis-cli -a 输入启动节点的密码
- create 
    - ip:prot ipN:protN
    - --cluster-replicas 复制因子，每个主从节点的比例

访问集群模式
- /src/redis-cli -a xxx -c -h host -p port
- cluster info 查询集群信息
- cluster nodes 查看集群各个节点信息


> HASH_CLOT = CRC16(key)mod 16384
 
> 共16384 sloat


### 添加节点（水平扩展）
- add-node 添加节点
- reshard host:port 重新分片

### 删除节点
- reshard 将分配的sloat分配到其他可用主节点中
- del-node
- rebalance 集群内部做迁移，可以设置节点的权重（weight），迁移过程中sloat都会阻塞

## 集群选举原理
当Slave发现自己的Master变成FAIL状态时，便尝试进行Fallover，以聘成为新的Master。由于挂掉的Master可能会有多个Slave，从而存在多个Slave竞争的过程，其过程如下：
1. slave发现自己的Master变为FAIL
2. 将自己记录的集群CurrentEpoch加1，并广播FAILOVER_AUTH_REQUEST信息
3. 其他节点收到该信息，只有Master响应，判断请求者的合法性，并发送FAILOVER_AUTH_ACK，对每一个epoch只发送一次ACK
4. 尝试FAILOVER的Slave收集FAILOVER_AUTH_ACK
5. 超过半数后变成新的Master
6. 广播Pong通知其他集群节点

从节点并不是在主节点一进入FAIL状态就马上尝试发起选举的，而是有一定延迟，一定的延迟确保我们等待FAIL状态在集群中传播，Slave如果立即尝试选举或许尚未意识到FAIL状态，可能会拒绝投票

延迟计算公式：
```
DELAY = 500ms + random(0 -500ms) + SLAVE_RANK + 1000ms
```
- SLAVE_RANK表示此Slave已经从Master复制数据的总量的Rank。Rank越小代表已复制的数据越新，持有最新数据的Slave将会首先发起选举。