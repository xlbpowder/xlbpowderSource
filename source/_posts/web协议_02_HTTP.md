---
title: HTTP长短连接、代理服务器转、请求上下文、内容协商与资源表述等头部
date: 2021-02-14 10:00:00
tags: web协议
categories: 网络
---

主要记录一些HTTP协议的小知识点，长连接与短连接、HOST头部、代理服务器转发相关头部、请求响应上下文、内容协商与资源表述
<!-- more -->

# HTTP 连接的简易流程
![01](/image/web/HTTP连接请求流程.png)

# 从TCP编程上看TP请求处理流程
![02](/image/web/TCP编程上看HTTP请求流程.png)

# 长连接与短连接
Connection头部，客户端、服务端都使用该属性作为是否长连接标示。客户端发起表示请求长连接，服务端响应该头部标示支持长连接，并且复用该连接。

HTTP/1.1默认支持长连接。

Connection的其他作用：不转发Connection列出头部，该头部仅与当前连接相关。

- Keep-Alive 长连接
- Close 短链接

![03](/image/web/短连接与长连接.png)

## Proxy-Connection
- 陈旧的代理服务器不识别该头部：退化为短连接
- 新版本的代理服务器理解该头部
    - 与客户端建立长连接
    - 与服务器使用Connection替代Proxy Connect头部

# HOST头部
> Host = uri-host[":" port]
>   - HTTP/1.1规范要求，不传递Host头部则返回400错误响应码
>   - 为了防止陈旧的代理服务器发向正向代理的请求，request-target必须以absolute-form形式出现
>   - request-line = method SP request-target SP HTTP-version CRLF
>   - absolute-form = absolute-URI (absolute-URI = scheme ":" hier-part ["?" query])

# 代理服务器转发消息时的相关头部
客户端与源服务器之间存在多个代理

## 如何传递IP地址？
1. TCP连接四元组(src ip, src port, dst ip, dst port)
2. HTTP头部X-Forwarded-For 用于传递IP
3. HTTP头部X-Real-IP用于传递用户IP（Nginx）

## 消息的转发
### Max-Forwards
限制Proxy代理服务器的最大转发次数，仅对TRACE/OPTIONS方法有效

### Via
指明经过的代理服务器名称及版本
> Via = 1#(received-protocol RWS received-by [RWS comment])

## Cache-Control:no-transform
禁止代理服务器修改响应包体

# 请求与响应的上下文

## 请求上下文
### User-Agent
指明客户端的类型信息，服务器可以根据此资源的表述作出抉择
> User-Agent = product *(RWS ( product / comment))
>    - product = token["/" product-version]
>    - RWS = 1*( SP / HTAB)
### Referer
浏览器对来自某一页面的请求自动添加的头部。
服务器端常用于统计分析、缓存优化、防盗链等功能。
- Referer = absolute-URI / partial-URI
#### Referer不会被添加的场景
1. 来源页面采用的协议为标示本地文件的“file”或“data” URI
2. 当前请求页面采用的http协议，而来源页面采用的是https协议

## From
主要用于网络爬虫，告诉服务器如何通过邮件联系到爬虫的负责人
> From = mailbox

## 响应上下文 
### Server
指明服务器上所用软件的信息，用于帮助客户端定位问题或统计数据

### Allow
告诉客户端，服务器上该URI对应资源允许哪些方法的执行

### Accept-Ranges
告诉客户端服务器上该资源是否允许range请求

# 内容的协商与资源表述
## 内容协商
内容协商将决定服务器端生成不同的包体传输给客户端

每个URI指向的资源可以是任何事物，可以有多种不同的表述，例如一份文档可以有不同语言的翻译(en, fr, de)、不同的媒体格式(text/html, text/pdf)、可以针对不同的浏览器提供不同的压缩编码(gzip, br)等。

### Proactive 主动式内容协商
指由客户端先在请求头部中提出需要的表述形式，而服务器根据这些请求头部提供特定的representation表述


![04](/image/web/主动式内容协商流程.png)

- Accept 接受格式
- Accept 接受语言
- Accept-Encoding 接受压缩编码格式
- Content-* 响应的格式、语言、压缩编码格式


### Reactive 响应式内容协商
指服务器返回300 Multiple Choices或406 Not Acceptable，由客户端选择一种表述URI使用

存在一定的弊端，增加交互次数，且RFC规范中没有明确告诉Clent规则，各大浏览器无法按照统一策略响应，所以使用较少。

![05](/image/web/响应式内容协商流程.png)

## 常见协商要素
质量因子q：内容的质量、可接受类型的优先级，例如现在发起请求一张高清图片的缩略图，让用户快速浏览用，现在可以做非常高的压缩比，质量因子就比较小。请求一张医学等清晰图片，不能容忍做大范围的压缩，就要使用质量较大因子。也可以设置多种语言等场景。

- 媒体资源的MIME类型及质量因子
> Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8

- 字符编码(由于UTF-8格式广为使用，Accept-Charset已被废弃)
> Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7

- 表述语言
> Accept-Language: zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.5

- 内容编码
> Accept-Encoding: gzip, deflate, br

## 国际化与本地化

- internationalization(i18n) 指设计软件时，在不同的国家、地区可以不做逻辑实现层面的修改便能够以不同语言显示
- localization(l10n) 指内容协商时，根据请求中的语言及区域信息，选择特定的语言作为资源表述

## 资源表述的元数据头部
- 媒体类型、编码 content-type: text/html;charset=utf-8
- 内容编码 content-encoding: gzip
- 语言 Content-Language: de-DE, en-CA

