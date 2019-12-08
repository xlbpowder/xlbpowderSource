---
title: linux命令笔记
date: 2019-03-20 10:00:00
tags: Linux
categories: Linux
---

> 一直都在说要好好学习下linux命令，最近在学习docker的时候真的发现自己linux的能力太差了，基础也不行，暂时先记下学习docker过程中用到的一些命令行。

<!-- more -->

首先要先了解下自己的linux系统的操作版本，预防之后遇到的很多坑。

## 查看Linux系统版本与内核版本
* 查看内核版本的方式
1. uname -a
```
[root@iZwz91w0kp029z0dmueicoZ /root]#uname -a
Linux iZwz91w0kp029z0dmueicoZ 3.10.0-693.2.2.el7.x86_64 #1 SMP Tue Sep 12 22:26:13 UTC 2017 x86_64 x86_64 x86_64 GNU/Linux
```
2. cat /proc/version
```
[root@iZwz91w0kp029z0dmueicoZ /root]#cat /proc/version
Linux version 3.10.0-693.2.2.el7.x86_64 (builder@kbuilder.dev.centos.org) (gcc version 4.8.5 20150623 (Red Hat 4.8.5-16) (GCC) ) #1 SMP Tue Sep 12 22:26:13 UTC 2017
```

* 查看Linux系统版本命令
1. lsb_release
```
[root@iZwz91w0kp029z0dmueicoZ /root]#lsb_release -a
LSB Version:    :core-4.1-amd64:core-4.1-noarch
Distributor ID: CentOS
Description:    CentOS Linux release 7.4.1708 (Core)
Release:        7.4.1708
Codename:       Core
```
2. cat /etc/redhat-release
```
[root@iZwz91w0kp029z0dmueicoZ /root]#cat /etc/redhat-release
CentOS Linux release 7.4.1708 (Core)
```

还查到了一个说是cat /etc/issue但是这个文件打开后没什么东西，不清楚是不是我这个系统有问题。。

我这个是一个阿里云的服务器，系统内核是CentOS linux 7.4.1708 x86 64位，linux版本Linux version 3.10.0。


## 用户
今天在记笔记的时候，看到有的会是$ xxx的指令，而有的是# xxx，后来查了下才知道，原来root用户就会是#开头，而非root用户则是$开头。

一直用root用户其实也是有一定风险的，当然个人使用的话是没问题的，但是如果有多人使用，root用户权限会非常大，并不安全。所以先学习了下如何创建用户，并且分配相关权限。

## 网络
在windows中是使用ipconfig查看IP网络信息的，但是在linux系统中会提示没有这个指令，那相同能力的指令是什么呢，其实是ifconfig。
```
[root@iZwz91w0kp029z0dmueicoZ /root]#ifconfig
docker0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        ether 02:42:f9:91:0c:70  txqueuelen 0  (Ethernet)
        RX packets 3385  bytes 233447 (227.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 7300  bytes 448669 (438.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.18.149.46  netmask 255.255.240.0  broadcast 172.18.159.255
        ether 00:16:3e:02:d1:f0  txqueuelen 1000  (Ethernet)
        RX packets 5062352  bytes 1452046450 (1.3 GiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 3885791  bytes 441227116 (420.7 MiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vethe8247e8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether 76:33:08:8d:a1:f0  txqueuelen 0  (Ethernet)
        RX packets 3204  bytes 265137 (258.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 7105  bytes 434120 (423.9 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

vethfcf581a: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        ether d6:5a:8c:29:23:7e  txqueuelen 0  (Ethernet)
        RX packets 133  bytes 11230 (10.9 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 231  bytes 14338 (14.0 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

### iptables
防火墙配置规则

iptables --list-rules

### brctl
先引入工具包：yum install bridge-utils

brctl show

### 查看端口占用情况
netstat -tunlp
```
[root@iZwz91w0kp029z0dmueicoZ /root/elasticsearch]#netstat -tunlp
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      31413/sshd
tcp6       0      0 :::3306                 :::*                    LISTEN      28980/docker-proxy
udp        0      0 0.0.0.0:25940           0.0.0.0:*                           724/dhclient
udp        0      0 0.0.0.0:68              0.0.0.0:*                           724/dhclient
udp        0      0 172.20.0.1:123          0.0.0.0:*                           7939/ntpd
udp        0      0 172.19.0.1:123          0.0.0.0:*                           7939/ntpd
udp        0      0 172.17.0.1:123          0.0.0.0:*                           7939/ntpd
udp        0      0 172.18.149.46:123       0.0.0.0:*                           7939/ntpd
udp        0      0 127.0.0.1:123           0.0.0.0:*                           7939/ntpd
udp        0      0 0.0.0.0:123             0.0.0.0:*                           7939/ntpd
udp6       0      0 :::50357                :::*                                724/dhclient
udp6       0      0 :::123                  :::*                                7939/ntpd

```
## 硬盘使用情况
> df [OPTION]... [FILE]...
- -a, --all 包含所有的具有 0 Blocks 的文件系统
- --block-size={SIZE} 使用 {SIZE} 大小的 Blocks
- -h, --human-readable 使用人类可读的格式(预设值是不加这个选项的...)
- -H, --si 很像 -h, 但是用 1000 为单位而不是用 1024
- -i, --inodes 列出 inode 资讯，不列出已使用 block
- -k, --kilobytes 就像是 --block-size=1024
- -l, --local 限制列出的文件结构
- -m, --megabytes 就像 --block-size=1048576
- --no-sync 取得资讯前不 sync (预设值)
- -P, --portability 使用 POSIX 输出格式
- --sync 在取得资讯前 sync
- -t, --type=TYPE 限制列出文件系统的 TYPE
- -T, --print-type 显示文件系统的形式
- -x, --exclude-type=TYPE 限制列出文件系统不要显示 TYPE
- -v (忽略)
- --help 显示这个帮手并且离开
- --version 输出版本资讯并且离开
```
[root@iZwz91w0kp029z0dmueicoZ /root/elasticsearch]#df -hl
Filesystem      Size  Used Avail Use% Mounted on
/dev/vda1        40G   16G   22G  43% /
devtmpfs        1.9G     0  1.9G   0% /dev
tmpfs           1.9G     0  1.9G   0% /dev/shm
tmpfs           1.9G  428K  1.9G   1% /run
tmpfs           1.9G     0  1.9G   0% /sys/fs/cgroup
overlay          40G   16G   22G  43% /var/lib/docker/overlay2/15c11eb5a1a871c9e41ce861b6fcd11063a2d5dec965b75985b1068cf05f9ce5/merged
shm              64M     0   64M   0% /var/lib/docker/containers/1254821edc4c200cd6e899a70347623bb38276bde0db1591f7c9c4dbc208a692/mounts/shm
tmpfs           380M     0  380M   0% /run/user/0
```
