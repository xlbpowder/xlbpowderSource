---
title: JVM内存模型、调优与相关工具
date: 2020-03-21 10:00:00
tags: JVM
categories: Java
---

摘自公司培训资料，记录下主要学习的有关JVM的内容。纯手打的，手都要抽筋了。
<!-- more -->
# 内存模型

![JVM内存模型01-photo](/image/jvm/JVM7内存模型.png)

![JVM内存模型02-photo](/image/jvm/JVM8内存模型.png)

# 栈

![JVM内存模型03-photo](/image/jvm/JVM_栈.png)

- 本地方法栈(线程私有)：登记native方法，在Execution Engine执行时加载本地方法库
- 程序计数器（线程私有）：就是一个指针，指向方法区中的方法字节码（用来存储指向下一条指令的地址,也即将要执行的指令代码），由执行引擎读取下一条指令，是一个非常小的内存空间，几乎可以忽略不记。
- 方法区(线程共享)：类的所有字段和方法字节码，以及一些特殊方法如构造函数，接口代码也在此定义。简单说，所有定义的方法的信息都保存在该区域，静态变量+常量+类信息(构造方法/接口定义)+运行时常量池都存在方法区中，虽然Java虚拟机规范把方法区描述为堆的一个逻辑部分，但是它却有一个别名叫做 Non-Heap（非堆），目的应该是与 Java 堆区分开来。

- Java栈（线程私有）： Java线程执行方法的内存模型，一个线程对应一个栈，每个方法在执行的同时都会创建一个栈帧（用于存储局部变量表，操作数栈，动态链接，方法出口等信息）不存在垃圾回收问题，只要线程一结束该栈就释放，生命周期和线程一致

JVM对该区域规范了两种异常：
1. 线程请求的栈深度大于虚拟机栈所允许的深度，将抛出StackOverFlowError异常
2. 若虚拟机栈可动态扩展，当无法申请到足够内存空间时将抛出OutOfMemoryError，通过jvm参数–Xss指定栈空间，空间大小决定函数调用的深度


# 堆
1.7中堆分为永久代、新生代、旧生代。1.8与1.7最显著的区别就是去除了永久代，将永久代分为了常量池和方法区，方法区移动到了堆外称之为元空间，占用机器内存，不再占用堆内存。

新生代：
JDK1.7和1.8中绿色的部分称为新生代，新生代又分为Eden Space和2个Survivor Space，也叫From Space和To Space。其中Eden Space一般我们new的对象都会放在此处，Survivor Space用于Young GC时的存放还需要继续引用的对象。Eden:From:To的默认比例为8:1:1，由启动参数-XX:SurvivorRatio，默认为8。

旧生代：
JDK1.7和1.8中蓝色部分，用于存放在新生代中经过多次垃圾回收仍然存活的对象/继续引用的对象，从To Space全部移动到Old Generation。有一种情况当生成某个大对象，Eden Space空间不足，进行Young GC，此时如果Survivor空间不足，对象会直接放入Old Generation。

注：线程分配内存不在堆内，而是在堆外，-Xss是在JVM方法栈中划分，所以对于线程比较多的应用应预留相对较多的堆外内存。一般Xmx设置为总机器内存的3/5（个人经验）,-Xmn为Xmx的3/8（sun推荐）。

# Mate Space
元数据区取代了永久代(jdk1.8以前)，本质和永久代类似，都是对JVM规范中方法区的实现，区别在于元数据区并不在虚拟机中，而是使用本地物理内存，永久代在虚拟机中，永久代逻辑结构上属于堆，但是物理上不属于堆，堆大小=新生代+老年代。元数据区也有可能发生O utOfMemory异常。

- Jdk1.6及之前：有永久代, 常量池在方法区
- Jdk1.7：有永久代，但已经逐步“去永久代”，常量池在堆
- Jdk1.8及之后：无永久代，常量池在元空间

元数据区的动态扩展，默认–XX:MetaspaceSize值为21MB的高水位线。一旦触及则Full GC将被触发并卸载没有用的类（类对应的类加载器不再存活），然后高水位线将会重置。新的高水位线的值取决于GC后释放的元空间。如果释放的空间少，这个高水位线则上升。如果释放空间过多，则高水位线下降。

## 为什么jdk1.8用元数据区取代了永久代
官方解释：移除永久代是为融合HotSpot JVM与 JRockit VM而做出的努力，因为JRockit没有永久代，不需要配置永久代

# GC

![GC01-photo](/image/jvm/GC.png)

## Minor GC(Young GC)
发生在新生代，会造成应用的暂停，发生过程：
1. 每个对象Eden Space分配内存，当Eden Space空间满，或者不能放入新产生的对象后，进行Young GC进行回收，并将回收后剩余的对象放入To Space，如果To Space空间不足以放入剩余的对象，超出空间的部分对象将直接放入Old Space。
2. 第二次Young GC时，To Space会转换为From Space，将To Space和Eden Space的对象垃圾回收后放入From Space，此时From Space变为To Space
3. 运行一段时间后，经过指定次数Young GC仍然存活（被引用）的对象，会放入到Old Space，次数由-XX:MaxTenuringThreshold决定，默认值15。

## Major GC(Full GC)
对新生代和老年代都按其GC配置类型进行GC。Full GC产生时，会造成应用暂停STW(Stop The World 所有java应用其他线程全部挂起)，且时间远远大于Young GC，是我们需要尽量避免或减少其触发频率。

触发情况如下：
1. 调用System.gc()
2. 旧生代空间不足。旧生代在新生代转入对象、大数组时会出现空间不足现象，此时会进行Full GC。当Full GC后仍不能存放时，会抛出OOM。因此为了避免这两种情况下Full GC的产生，调优时应尽量让对象在Young GC时回收，即让对象在新生代多存活一段时间，使其能回收;不要创建过大的对象和数组。
3. CMS GC时出现promotion failed和concurrent mode failure
    - promotion filed：在进行Young GC时，Survivor Space放不下，对象只能放入旧生代，而此时旧生代也放不下，此时就会出现promotion failed错误。
    - concurrent mode failure：在执行CMS GC过程中同时由对象放入Old Space，而此时Old Space空间不足，会粗线此类错误

    优化措施：增加Survivor Space、Old Space空间，降低CMS GC产生的几率
 
## CMS
Concurrent Mark-Sweep 目标是尽量减少应用的暂停时间，减少full gc发生的几率，利用和应用程序线程并发的垃圾回收线程来标记清除年老代

1. 请求进行一次Full GC，如调用System.gc时
2. 当没有设置UseCMSInitiatingOccupancyOnly时，会动态计算。如果完成CMS回收所需要的预计时间小于预计的CMS回收的分代填满的时间，就进行回收
3. 调用should_concurrent_collect()方法返回true
4. 如果预计增量式回收会失败时，也会触发一次回收
5. 如果MetaSpace认为需要回收MetaSpace区域，也会触发一次CMS回收

CMS GC是并发GC，可以和应用并发进行，所以大部分时间不会造成程序暂停。

# 各代大小调优
各代大小的调优，会直接影响Young GC和Full GC触发的时机和触发的频率，在代大小的调优上，最关键的几个参数为：

参数 | 说明 |
-- | -- |
-Xms –Xmx                  | JVM能使用的最小内存和最大内存，通常设置为相同的值，避免运行时要不断的扩展JVM空间，造成性能上的损失 |
–Xmn                       | 新生代大小 |
–XX:SurvivorRatio          | 新生代中Eden、From、To的比例，默认8 | 
–XX:MaxTenuringThreshold   | 对象经历多少次Young GC后放入Old Space，默认15 | 

设置这些值时，应考虑的方面：
1. 避免新生代设置过小
    - Young GC频率过高
    - 可能导致Young GC的对象直接进入旧年代，若此时进入旧年代的对象大于旧年代剩余空间，将会触发Full GC
2. 避免新生代设置过大
    - Old Space变小，Full GC频繁发生
    - Young GC耗时大幅度增长
3. 避免Survivor区过小/过大
    - 调大SurvivorRatio值，Young GC的频率会下降，也会造成Survivor Space过小，如有Young GC后的对象没有被回收且大于Survivor空间，则会直接放入Old Space，引发Full GC的频率提高
4. 适当设置新生代对象的存活周期，可充分的回收对象，避免对象进入Old Space

# 调优工具
以前在华为使用的IBM JDK，IHS生成的dump文件比较特别，要用IBM的HeapAnalyzer分析dump文件，用JavaCoreAnalyzer分析JavaCore文件。后来脱离了IBM后，还是要找一些可以更通用的分析调优工具。

## profile
对JVM调优时，JDK提供的工具不细致，推荐一款工具profile，既可实施监控JVM应用运行情况，也可以对Jmap抓取的内存文件进行分析。

1. 抓取当前JVM内存快照： jmap -F -dump:live,file=jmap.heap[PID]
2. OutOfMemoryError时自动生成dump文件，启动参数中加入：-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/path

使用起来比较简单
![profile_01-photo](/image/jvm/profile_01.png)

![profile_02-photo](/image/jvm/profile_02.png)

![profile_03-photo](/image/jvm/profile_03.png)