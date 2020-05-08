---
title: CAS
date: 2020-01-01 14:00:00
tags: Java
categories: Java
---

转眼间就2020年了，去年学习的东西甚少，今年要多看看书了。

<!-- more -->

# 概念
> In computer science, compare-and-swap (CAS) is an atomic instruction used in multithreading to achieve synchronization. It compares the contents of a memory location with a given value and, only if they are the same, modifies the contents of that memory location to a new given value. This is done as a single atomic operation. The atomicity guarantees that the new value is calculated based on up-to-date information; if the value had been updated by another thread in the meantime, the write would fail. The result of the operation must indicate whether it performed the substitution; this can be done either with a simple boolean response (this variant is often called compare-and-set), or by returning the value read from the memory location (not the value written to it).

在计算机科学中，比较和交换（Conmpare And Swap）是用于实现多线程同步的原子指令。 它将内存位置的内容与给定值进行比较，只有在相同的情况下，将该内存位置的内容修改为新的给定值。 这是作为单个原子操作完成的。 原子性保证新值基于最新信息计算; 如果该值在同一时间被另一个线程更新，则写入将失败。 操作结果必须说明是否进行替换; 这可以通过一个简单的布尔响应（这个变体通常称为比较和设置），或通过返回从内存位置读取的值来完成（摘自维基本科）

## 举例解释
字面意思“比较并交换”，一个CAS涉及到以下操作：
> 我们假设内存中的元数据V，旧的预期值A，需要修改的新值B。
> 1. 比较 A 与 V 是否相等。（比较）
> 2. 如果比较相等，将 B 写入 V。（交换）
> 3. 返回操作是否成功。

# JAVA中CAS的实现
## JDK工具类中的使用
在JDK的源码中，可以在java.util.concurrent的atomic包和locks包下看到使用到CAS。以AtomicInteger举例
``` java
/**
    * Atomically sets the value to the given updated value
    * if the current value {@code ==} the expected value.
    *
    * @param expect the expected value
    * @param update the new value
    * @return {@code true} if successful. False return indicates that
    * the actual value was not equal to the expected value.
    */
public final boolean compareAndSet(int expect, int update) {
    return unsafe.compareAndSwapInt(this, valueOffset, expect, update);
}
```
可以看到在compareAndSet中，通过unsafe对象调用了native修饰的compareAndSwapInt方法。
``` java
private static final Unsafe unsafe = Unsafe.getUnsafe();
```
``` java
public final native boolean compareAndSwapInt(Object var1, long var2, int var4, int var5);
```
## JVM底层调用
关于native修饰的底层调用本地方式实现的内容，我直接查看了一些文章。

我们发现在 /jdk9u/hotspot/src/share/vm/unsafe.cpp中有这样的代码：
```
{CC "compareAndSetInt", CC "(" OBJ "J""I""I"")Z", FN_PTR(Unsafe_CompareAndSetInt)},
```
这个涉及到JNI的调用，感兴趣的同学可以自行学习。我们搜索Unsafe_CompareAndSetInt后发现:
```
UNSAFE_ENTRY(jboolean, Unsafe_CompareAndSetInt(JNIEnv *env, jobject unsafe, jobject obj, jlong offset, jint e, jint x)) {
  oop p = JNIHandles::resolve(obj);
  jint* addr = (jint *)index_oop_from_field_offset_long(p, offset);

  return (jint)(Atomic::cmpxchg(x, addr, e)) == e;
} UNSAFE_END
```
最终我们终于看到了核心代码Atomic::cmpxchg。

继续向底层探索，在文件java/jdk9u/hotspot/src/os_cpu/linux_x86/vm/atomic_linux_x86.hpp有这样的代码:
```
inline jint     Atomic::cmpxchg    (jint     exchange_value, volatile jint*     dest, jint     compare_value, cmpxchg_memory_order order) {
  int mp = os::is_MP();
  __asm__ volatile (LOCK_IF_MP(%4) "cmpxchgl %1,(%3)"
                    : "=a" (exchange_value)
                    : "r" (exchange_value), "a" (compare_value), "r" (dest), "r" (mp)
                    : "cc", "memory");
  return exchange_value;
}
```
我们通过文件名可以知道，针对不同的操作系统,JVM 对于Atomic::cmpxchg应该有不同的实现。由于我们服务基本都是使用的是64位linux，所以我们就看看linux_x86的实现。
我们继续看代码：

- __asm__的意思是这个是一段内嵌汇编代码。也就是在C语言中使用汇编代码。
- 这里的volatile和JAVA有一点类似，但不是为了内存的可见性，而是告诉编译器对访问该变量的代码就不再进行优化。
- LOCK_IF_MP(%4)的意思就比较简单，就是如果操作系统是多核的，那就增加一个LOCK。
- cmpxchgl就是汇编版的“比较并交换”。但是我们知道比较并交换，有三个步骤，不是原子的。所以在多核情况下加一个 LOCK，由CPU硬件保证他的原子性。
- 我们再看看LOCK是怎么实现的呢？我们去Intel的官网上看看，可以知道LOCK在的早期实现是直接将cup的总线阻塞，这样的实现可见效率是很低下的。后来优化为X86 cpu 有锁定一个特定内存地址的能力，当这个特定内存地址被锁定后，它就可以阻止其他的系统总线读取或修改这个内存地址。

关于CAS的底层探索我们就到此为止。我们总结一下JAVA的CAS是怎么实现的：
1. java的cas利用的的是unsafe这个类提供的cas操作。
2. unsafe的cas依赖了的是jvm针对不同的操作系统实现的 Atomic::cmpxchg
3. Atomic::cmpxchg的实现使用了汇编的cas操作，并使用cpu硬件提供的lock信号保证其原子性

# CAS带来的问题
## ABA
以下是维基百科定义：

In multithreaded computing, the ABA problem occurs during synchronization, when a location is read twice, has the same value for both reads, and "value is the same" is used to indicate "nothing has changed". However, another thread can execute between the two reads and change the value, do other work, then change the value back, thus fooling the first thread into thinking "nothing has changed" even though the second thread did work that violates that assumption.

he ABA problem occurs when multiple threads (or processes) accessing shared data interleave. Below is the sequence of events that will result in the ABA problem:

1. Process P1 reads value A from shared memory,
2. P1 is preempted, allowing process P2 to run,
3. P2 modifies the shared memory value A to value B and back to A before preemption,
4. P1 begins execution again, sees that the shared memory value has not changed and continues.

Although P1 can continue executing, it is possible that the behavior will not be correct due to the "hidden" modification in shared memory.

A common case of the ABA problem is encountered when implementing a lock-free data structure. If an item is removed from the list, deleted, and then a new item is allocated and added to the list, it is common for the allocated object to be at the same location as the deleted object due to optimization. A pointer to the new item is thus sometimes equal to a pointer to the old item which is an ABA problem.

简而言之，当两个线程访问同一个地址时，将“值相同”用于表示“没有变化”。
 - 线程P1从内存中取出A
 - 线程P2也从内存中取出A
 - 线程P2进行操作并且将值修改为B，而后又修改为A。
 - 线程P1进行CAS操作时候发现值仍为A，便可以进行操作。

其实在一般情况下，看似以最终结果来看可以认为是没有问题的，但是整个操作的过程是有问题的，比如：链表的头在变化了两次后恢复了原值，但并不代表链表没有发生过变化。
### 解决思路
Tagged state reference 标记状态参考：使用某个标识来表示是否有过变更的版本信息。JDK中有提供AtomicStampedReference/AtomicMarkableReference用于解决ABA问题。

还有两种不常用的解决方案：
- Intermediate nodes 中间节点
- Deferred reclamation

# 参考资料
* https://segmentfault.com/a/1190000013127775
* https://en.wikipedia.org/wiki/Compare-and-swap
* https://en.wikipedia.org/wiki/ABA_problem