---
title: Clojure 数据类型
date: 2020-10-26 10:00:00
tags: Clojure
categories: Clojure
---

开了一个新的坑，记录下之前学习clojure的笔记。
<!-- more -->
- 基本 scalars 
- 组合 collections

数据类型的特定
- immutable 不可变的
- lazy 惰性加载
- persistent 持久性


# 基本数据类型
- Number(long, double, ratio)
- Bool
- String
- Character
- Symbol(符号)/Keyword(关键字) Lisp语言特有的两种类型

使用type可以得知变量的数据类型，clojure中数字默认是long类型（不同于java是int）。
``` clojure
(type 2)
=> java.lang.Long

(type 1/3)
=> clojure.lang.Ratio

(type 3.14)
=> java.lang.Double

(type "hello world")
=> java.lang.String

(type \a)
=> java.lang.Character

(type true)
=> java.lang.Boolean
(type false)
=> java.lang.Boolean

(type 'a)
=> clojure.lang.Symbol

(type :a)
=> clojure.lang.Keyword
```

# nil与false
nil相当于null;
不同与C/C++，在C/C++中一般0代表false，1代表true。

Clojure中除nil和false以外，其他值均为真值(truthiness)。所以下面输出结果为true，因为0是真值。
``` clojure
(if 0 true false)
=> true
```

# 整型
在clojure中，整数类型不同于JAVA，java中整数类型默认是int/Integer，而clojure中是long/Long

# Numbers
Clojure中的 Numbers 数据类型派生自Java类。

Clojure的Numbers类型支持整型和浮点型。

整型是不包含分数的值。

浮点型是包含小数部分的十进制值。

Numbers包含JAVA中的Byte、Double、Float、Integer、Short、Long

# Ratio


# Symbol & Keyword
- Symbol标识符(identifiers)，指向其他值。在macro中非常游泳
- Keyword: 与Symbol类似，区别在于其他值指向自身，fast equality tests。一般用在map中

