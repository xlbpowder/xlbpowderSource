---
title: Clojure 基础语法
date: 2020-11-03 19:00:00
tags: Clojure
categories: Clojure
---

在学习clojure中发现了很多语法同其他语言有很大差异，本篇主要记录了clojure相关的语法。
<!-- more -->

# log
``` clojure 
(use 'clojure.tools.logging)

(info "something happened")
(warn "something bad happened")
(error "something error") 
```

并且可以直接输入多个入参
``` clojure
(let [str "abc"
   _ (info str "d" )
])
=> abc d
```

# ->
以下是我在stackoverflow中搜索到的关于`->`的语法介绍，非常简洁易懂。

-> uses the result of a function call and send it, in sequence, to the next function call.

So, the easier example would be:
``` clojure
(-> 2 (+ 3))
```
Returns 5, because it sends 2, to the next function call (+ 3)

Building up on this,
``` clojure
(-> 2 
  (+ 3) 
  (- 7))
```
Returns -2. We keep the result of the first call, (+ 3) and send it to the second call (- 7).

As noted by @bending, the accepted answer would have been better showing the doto macro.
``` clojure
(doto person
  (.setFName "Joe")
  (.setLName "Bob")
  (.setHeight [6 2]))
```