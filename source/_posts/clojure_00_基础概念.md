---
title: Clojure 基础概念
date: 2020-10-30 10:00:00
tags: Clojure
categories: Clojure
---

忘记了记录一些Clojure的基础认识，正好这次从头阅读《Clojure编程乐趣》，补足一下基础知识。由于Clojure是Lisp语言，其实从语法和阅读编写上，有一些逻辑和JAVA/C++/go这些还是有点不太一样的

<!-- more -->
# helloworld
``` clojure
(ns first-demo.core)

(defn foo
  "I don't do a whole lot. "
  [x]
  (println x "Hello, World!"))

(foo "liubo")

=> liubo Hello, World!
```
# 函数式

# LISP


# 关键字
# ns

## def

## defn

## defprotocol

# 工具
## leiningen

## REPL

# 在Clojure中，计算顺序始终如一——从内到外，从左到右：
``` clojure
(< (+ 1 (* 2 3))
   (* 2 (+ 1 3)))
=> true
```

# 函数结构
在Clojure中，括号只是用于求值的结构（scheme）：把大量事物聚合成一个列表，第一个元素代表函数名，其他的作为函数的参数。
``` clojure
(a-function arg1 arg2)
```

# 算数运算符也是函数
## +
在Clojure中，算术运算符也是函数。但是在其他一些语言中，例如Java，算术运算符是特殊符号而且只会出现在数值计算表达式中。正因为Clojure中的运算符也是函数，所以函数的使用方式同样适用于运算符，包括使用一系列参数：

``` clojure
(+ 1 2 3 4 5 6 7 8 9 10)
=> 55
```

## <
小于符号同加号一样，但Clojure中的<函数可以接收多个参数，因此可以应用于判断序列是否单调递增。如果不是单调递增，返回值会是false。
``` clojure
(< 0 42)
=> true

(< 0 1 3 5 7 9)
=> true

(< 0 1 3 -5 7 9)
=> false
```

# apply函数
在Clojure中，可以用apply函数把一个由数字组成的sequence传给另外一个函数，看上去就像传递给函数多个参数一样。
``` clojure
(def numbers [1 2 3 4 5 6 7 8 9 10])
(apply + numbers)
=> #'first-demo.core/numbers
=> 55
```