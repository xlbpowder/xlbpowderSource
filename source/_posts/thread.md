---
title: Java Thread
date: 2018-11-28 14:12:17
tags:
categories: Java
---

> 本篇是在对线程基础进行学习时的概念知识的随笔

<!-- more -->

## 线程
每一个java进程，都伴随着N个线程进行执行，入口main函数为主线程。

## 线程的状态
线程启动使用的start()方法，但是启动的时候，线程将进入一种就绪状态，现在并没有立刻执行。

进入到就绪状态之后就需要等待进行资源调度，当某一个线程的调度成功之后，则回进入到运行状态（run方法）

但是所有的线程不可能一致执行下去，中间需要产生一些暂停的状态，例如：某个线程执行一段时间之后就需要让出资源，这个线程将会进入阻塞状态

run()方法执行结束后，实际该线程的主要任务也就结束了，此时将会直接进入到停止状态

1. start() 就绪
2. run() 运行状态
3. 阻塞状态
4. 停止状态

注：线程的停止等相关方法在jdk1.2就已经废弃，如果想停止线程应当自定义编写线程推出的条件对线程进行退出，而不是外部的暴力退出线程。

## 线程休眠
希望一个线程可以暂缓执行，进行休眠的时候可能会产生中断异常

休眠的特点是可以自动实现线程的唤醒，以继续进行后续的处理，但休眠也是有先后顺序的

## 线程中断
所有正在执行的线程都是可以被中断的，中断线程必须进行异常的处理
* 判断线程是否被中断：public static boolean interrupted()
* 中断线程执行：public void interrupt()

interrupt()不能中断在运行中的线程，它只能改变中断状态

## 线程的强制执行
当满足于某些条件之后，某一个线程对象可以一直独占资源，一直到该线程的程序执行结束

通过需要进行join的线程对象调用
* public final void join() throws InterruptedException 
  
## 线程的礼让
将资源让出给其他线程先执行
* public static native void yield();

## 线程优先级
* 线程优先级越高，越有可能先执行（先抢占到资源），在Thread类中针对于优先级有两个方法：
* 设置优先级：public final void setPriority(int newPriority)
* 获取优先级：public final void getPriority()
* 优先级常量，分别为低、中、高优先级
```java
    /**
     * The minimum priority that a thread can have.
     */
    public final static int MIN_PRIORITY = 1;

   /**
     * The default priority that is assigned to a thread.
     */
    public final static int NORM_PRIORITY = 5;

    /**
     * The maximum priority that a thread can have.
     */
    public final static int MAX_PRIORITY = 10;
```
主线程、子线程默认的优先级为NORM_PRIORITY，中优先级

设置高优先级后，该线程有可能，但并不是必定会优先执行


## 线程同步问题

* 关键字：synchronized，同步代码块、同步方法中只允许一个线程执行，大都使用同步方法。
```java
synchronized(同步对象){
    同步代码操作;
}
```
一般要进行同步对象处理的时候可以采用当前对象this进行同步。

同步会造成程序性能的整体降低


## 线程死锁

死锁造成的主要原因是因为彼此都在互相等待，等待对方先让出资源。

若干个线程访问同一资源时一定要进行同步处理，而过多的同步处理可能会造成死锁。

如何避免死锁：

    避免在对象的同步方法种调用其他对象的同步方法

    死锁的根本原因1）是多个线程涉及到多个锁，这些锁存在着交叉，所以可能会导致了一个锁依赖的闭环；2）默认的锁申请操作是阻塞的。所以要避免死锁，就要在一遇到多个对象锁交叉的情况，就要仔细审查这几个对象的类中的所有方法，是否存在着导致锁依赖的环路的可能性。要采取各种方法来杜绝这种可能性。


一旦我们在一个同步方法中，或者说在一个锁的保护的范围中，调用了其它对象的方法时，就要十而分的小心：

1）如果其它对象的这个方法会消耗比较长的时间，那么就会导致锁被我们持有了很长的时间；

2）如果其它对象的这个方法是一个同步方法，那么就要注意避免发生死锁的可能性了；

## 守护线程
守护线程的生命周期紧随用户线程，JVM最大的守护线程是GC线程，程序执行中GC线程将一直存在，如果程序执行完毕，GC线程也会消失

* 设置为当前线程的守护线程 public final void setDaemon(boolean on)

* 是否是守护线程 public final boolean isDaemon()

## volatile关键字
用于修饰关键字，表示该属性为直接属性操作，不进行副本拷贝处理。
一些文档和书中错误的讲其描写为同步属性。

在正常进行变量处理的时候一般会经历以下几个步骤：
1. 获取变量原有的数据内容副本
2. 利用副本为变量进行数学计算
3. 将计算后的变量保存到原始空间之中

如果加上了volatile关键字，表示不使用副本，直接操作原始变量，相当于节约了拷贝副本

![volatile-photo](/image/volatile.png)

volatile与synchronized的区别：

    volatile只能描述属性，而synchronized可以用于代码块与方法。
    volatile无法描述属性进行同步处理，只是一种直接内存的处理，避免了副本处理。

对于volatile的详细解释，可以参考

https://www.ibm.com/developerworks/cn/java/j-jtp06197.html

https://www.cnblogs.com/dolphin0520/p/3920373.html