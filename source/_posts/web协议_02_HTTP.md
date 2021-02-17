---
title: HTTP杂记
date: 2021-02-14 10:00:00
tags: web协议
categories: 网络
---

主要记录一些HTTP协议的细节
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
ABNF定义：Host = uri-host[":" port]
- HTTP/1.1规范要求，不传递Host头部则返回400错误响应码
- 为了防止陈旧的代理服务器发向正向代理的请求，request-target必须以absolute-form形式出现
    - request-line = method SP request-target SP HTTP-version CRLF
    - absolute-form =absolute-URI (absolute-URI = scheme ":" hier-part ["?" query])

# 代理服务器转发消息时的相关头部
客户端与源服务器之间存在多个代理，

## 如何传递IP地址？
1. TCP连接四元组(src ip, src port, dst ip, dst port)
2. HTTP头部X-Forwarded-For 用于传递IP
3. HTTP头部X-Real-IP用于传递用户IP（Nginx）

