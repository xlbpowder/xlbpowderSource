---
title: JAVA程序常见问题与JVM内存模型关系
date: 2018-12-14 10:00:00
tags:
categories: Java
---

> 本文是前段时间公司培训讲到的内容，个人做了笔记进行了总结。通过各类JAVA程序的OOM问题，结合JVM内存模型进行定位以及调优，具体调试的工具以及内容后续会进行补充。

# OOM

## 内存模型
![JVM内存模型01-photo](/image/JVM内存模型01.png)

![JVM内存模型02-photo](/image/JVM内存模型02.png)

## 非堆内存
### 调优参数
-XX:MaxPremSize=256MB
* jdk1.7 持久代 使用的虚拟机内存
* jdk1.8之后 源空间 使用的是本地内存
### 对应OOM错误信息
PremGen Space
### 问题处理
1. 调大PermSize
2. 是否有动态加载Groovy脚本
3. 是否有大量动态生成类的逻辑，如字节码框、或动态代理的使用。

## 堆内存
### 调优参数
-Xmx2G
* 年轻代：Eden Survior
* 老年代
### 对应OOM错误信息
Java heap space/GC overhead limit exceeded
### 问题处理
1. 产生heapdump 

    1) 启动参数-XX:+HeapDumpOnOutOfMemoryError XX:HeapDumpPath=

    2) jmap -dump:format=b,file=文件名 [pid] 
2. 使用mat工具分析heapdump
3. 确定内存占用的代码进行优化
4. 如果内存占用不多

    1) 可能是创建了一个大对象导致，根据日志分析何时会创建大对象。

    2) 死循环，jstack分析。

## 栈内存
### 调优参数
-Xss128，默认2m
* 使用的是操作系统的剩余内存，与其他JVM内存区域无关
### 对应OOM错误信息
StackOverflowError,unable to create new native thread
### 问题处理
1. 调大-Xss，使每个线程栈的内存增大
2. 调小-Xmx 等参数，给栈留更多内存空间
3. 分析是否代码中有不合理的递归

## 堆外内存
### 调优参数
-XX:MaxDirectMemorySize=1G
* DiectBuffer
* 如netty直接缓冲区，io操作不需要进行内存的拷贝，性能较优
### 对应OOM错误信息
direct buffer memory
### 问题处理
1. 默认占用-Xmx相同内存，可以通过增加参数XX:MaxDirectMemorySize=1G设定
2. 络通信使用Netty但是未限流
3. 分析代码中是否使用DirectBuffer未合理控制

## 最终占用内存=MaxPermSize+Xmx+MaxDirectMemorySize+n*xss

## OutofMemory-Out of swap space解决方案
### 问题处理
1. 地址空间不够，调整系统为64位
2. 物理内存不足

    1) jmap -histo:live pid，如果内存明显减少说明是DirectBuffer问题，通过设置-XX:MaxDirectMemorySize=1G设定

    2) btrace Inflater/Deflater

## OutofMemory- unable to create new native thread解决方
1. 线程数超过ulimit限制

    1) ulimit -a 查看max user process
    
    2) 临时调大ulimit -u unlimited

    3) 永久增加 
        a. * vi /etc/security/limits.conf # 添加如下的行

        b. * soft noproc 11000

        c. * hard noproc 11000

        d. * soft nofile 4100

        e. * hard nofile 4100

2. 线程数超过kernel.pid_max

    1) /proc/sys/kernel/pid_max #操作系统线程数限制

    2) /proc/sys/vm/max_map_count #单进程mmap的限制会影响当个进程可创建的线程数

3. 线程创建太多

    1) jstack、pstree查看线程数量，排查谁创建过多线程

    2) 调小-xss，使每个栈内存占用变小

## OutofMemory-补充
1. 只有heap或Perm区满，才会产生heapDump，其他oom不会产生
2. 如何分析定位问题

    1) Jvm监控工具（JavaMelody）

    2) 其他工具 

        a. Greys https://github.com/oldmanpushcart/greys-anatomy

        b. TProfile https://github.com/alibaba/TProfiler

# Java进程退出

# CPU占用高

# 应用无响应

# 环境变量异常

# 调用超时
