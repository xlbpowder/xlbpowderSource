---
title: GC调优参数
date: 2020-05-03 10:00:00
tags: JVM
categories: Java
---

记录下学习GC的各个收集器对应的相关调优参数

<!-- more -->
# 调优的两个指标
- 停顿时间: 垃圾收集器做垃圾回收中断应用执行的时间。-XX:MaxGCPauseMillis
- 吞吐量: 花在垃圾收集的时间和花在应用时间的占比 -XX:GCTimeRatio=<n>,垃圾收集时间占比：1/(1+n)

# GC调优步骤
打印GC日志
```
-XX:+PrintGCDetails  -XX:+PrintGCTimeStamps  -XX:+PrintGCDateStamps  -Xloggc:./gc.log
```
- 分析日志得到关键性指标
- 分析GC原因，调优JVM参数
## 可视化分析
### GCeasy 
一个可以对GC日志进行可视化分析的网站

https://www.gceasy.io/

### GCViewer 

# Parallel Scavenge收集器(默认)
设置了该收集器后，年轻代默认为Parallel Scavenge，老年代则为Parallel Old

分析parallel-gc.log
- 第一次调优，设置Metaspace大小：增大元空间大小-XX:MetaspaceSize=64M  -XX:MaxMetaspaceSize=64M
- 第二次调优，添加吞吐量和停顿时间参数：-XX:MaxGCPauseMillis=100   -XX:GCTimeRatio=99
- 第三次调优，修改动态扩容增量：-XX:YoungGenerationSizeIncrement=30

# 配置CMS收集器
设置了老年代收集器为CMS后，年轻代默认为ParNew收集器
```
-XX:+UseConcMarkSweepGC
```

分析cms-gc.log

# 配置G1收集器
```
-XX:+UseG1GC
```
分析g1-gc.log 
查看发生MixedGC的阈值：jinfo -flag InitiatingHeapOccupancyPercent 进程id

分析工具：gceasy，GCViewer 

## G1调优常用参数
- -XX:+UseG1GC 开启G1
- -XX:G1HeapRegionSize=n,region的大小，1-32M，2048个
- -XX:MaxGCPauseMillis=200 最大停顿时间
- -XX:G1NewSizePercent   -XX:G1MaxNewSizePercent
- -XX:G1ReservePercent=10 保留防止to space溢出（）
- -XX:ParallelGCThreads=n SWT线程数（停止应用程序）
- -XX:ConcGCThreads=n 并发线程数=1/4*并行

# 总结
- 年轻代大小：避免使用-Xmn、-XX:NewRatio等显示设置Young区大小，会覆盖暂停时间目标（常用参数3）
- 暂停时间目标：暂停时间不要太严苛，其吞吐量目标是90%的应用程序时间和10%的垃圾回收时间，太严苛会直接影响到吞吐量

## 是否需要切换到G1
- 50%以上的堆被存活对象占用
- 对象分配和晋升的速度变化非常大
- 垃圾回收时间特别长，超过1秒

## G1调优目标
- 6GB以上内存
- 停顿时间是500ms以内
- 吞吐量是90%以上

# GC常用参数汇总
## 堆栈设置
- -Xss:每个线程的栈大小
- -Xms:初始堆大小，默认物理内存的1/64
- -Xmx:最大堆大小，默认物理内存的1/4
- -Xmn:新生代大小
- -XX:NewSize:设置新生代初始大小
- -XX:NewRatio:默认2表示新生代占年老代的1/2，占整个堆内存的1/3。
- -XX:SurvivorRatio:默认8表示一个survivor区占用1/8的Eden内存，即1/10的新生代内存。
- -XX:MetaspaceSize:设置元空间大小
- -XX:MaxMetaspaceSize:设置元空间最大允许大小，默认不受限制，JVM Metaspace会进行动态扩展。
## 垃圾回收统计信息
- -XX:+PrintGC
- -XX:+PrintGCDetails
- -XX:+PrintGCTimeStamps 
- -Xloggc:filename
## 收集器设置
- -XX:+UseSerialGC:设置串行收集器
- -XX:+UseParallelGC:设置并行收集器
- -XX:+UseParallelOldGC:老年代使用并行回收收集器
- -XX:+UseParNewGC:在新生代使用并行收集器
- -XX:+UseParalledlOldGC:设置并行老年代收集器
- -XX:+UseConcMarkSweepGC:设置CMS并发收集器
- -XX:+UseG1GC:设置G1收集器
- -XX:ParallelGCThreads:设置用于垃圾回收的线程数
## 并行收集器设置
- -XX:ParallelGCThreads:设置并行收集器收集时使用的CPU数。并行收集线程数。
- -XX:MaxGCPauseMillis:设置并行收集最大暂停时间
- -XX:GCTimeRatio:设置垃圾回收时间占程序运行时间的百分比。公式为1/(1+n)
## CMS收集器设置
- -XX:+UseConcMarkSweepGC:设置CMS并发收集器
- -XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况。
- -XX:ParallelGCThreads:设置并发收集器新生代收集方式为并行收集时，使用的CPU数。并行收集线程数。
- -XX:CMSFullGCsBeforeCompaction:设定进行多少次CMS垃圾回收后，进行一次内存压缩
- -XX:+CMSClassUnloadingEnabled:允许对类元数据进行回收
- -XX:UseCMSInitiatingOccupancyOnly:表示只在到达阀值的时候，才进行CMS回收
- -XX:+CMSIncrementalMode:设置为增量模式。适用于单CPU情况
- -XX:ParallelCMSThreads:设定CMS的线程数量
- -XX:CMSInitiatingOccupancyFraction:设置CMS收集器在老年代空间被使用多少后触发
- -XX:+UseCMSCompactAtFullCollection:设置CMS收集器在完成垃圾收集后是否要进行一次内存碎片的整理	
## G1收集器设置 
- -XX:+UseG1GC:使用G1收集器
- -XX:ParallelGCThreads:指定GC工作的线程数量
- -XX:G1HeapRegionSize:指定分区大小(1MB~32MB，且必须是2的幂)，默认将整堆划分为2048个分区
- -XX:GCTimeRatio:吞吐量大小，0-100的整数(默认9)，值为n则系统将花费不超过1/(1+n)的时间用于垃圾收集
- -XX:MaxGCPauseMillis:目标暂停时间(默认200ms)
- -XX:G1NewSizePercent:新生代内存初始空间(默认整堆5%)
- -XX:G1MaxNewSizePercent:新生代内存最大空间
- -XX:TargetSurvivorRatio:Survivor填充容量(默认50%)
- -XX:MaxTenuringThreshold:最大任期阈值(默认15)
- -XX:InitiatingHeapOccupancyPercen:老年代占用空间超过整堆比IHOP阈值(默认45%),超过则执行混合收集
- -XX:G1HeapWastePercent:堆废物百分比(默认5%)
- -XX:G1MixedGCCountTarget:参数混合周期的最大总次数(默认8)