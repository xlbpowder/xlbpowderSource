---
title: HTTP Range
date: 2021-02-20 16:00:00
tags: web协议
categories: 网络
---

本文记录结合断点续传、多线程下载等场景了解HTTP Range的协议规范

<!-- more -->

# 问题场景
- 客户端明确任务:从哪开始下载
- 本地是否已有部分文件
- 文件已下载部分在服务器端发生改变?
- 使用几个线程并发下载
- 下载文件的指定部分内容
- 下载完毕后拼装成统一文件

# HTTP Range规范(RFC7233)
允许服务器基于客户端的请求只发送响应包体的一部分给到客户端，而客户端自动将多个片断的包体组合成完整的体积更大的包体

- 支持断点续传
- 支持多线程下载
- 支持视频播放器实时拖动

# Accept-Range
服务器通过 Accept-Range 头部表示是否支持Range请求
> Accept-Ranges = acceptable-ranges
- Accept-Ranges: bytes 支持
- Accept-Ranges: none  不支持

# Range请求范围的单位
通过Range头部传递请求范围，","分割表示分两段获取，“-”表示获取范围
> Range: bytes=0-499

## 举例
基于字节，设包体总长度为 10000
- 第1个500字节: bytes=0-499
- 第2个500字节:
    - bytes=500-999
    - bytes=500-600,601-999
    - bytes=500-700,601-999
- 最后1个500字节: 
    - bytes=-500 
    - bytes=9500
- 仅要第1个和最后1个字节: bytes=0-0,-1

# Range条件请求
如果客户端已经得到了Range响应的一部分，并想在这部分响应未过期的情况下，获取其他部分的响应。
常与If-Unmodified-Since或者If-Match头部共同使用。

可以仅使用If-Range = entity-tag / HTTP-date。entity-tag和HTTP-date都是由服务端生成的。
也可以使用 Etag 或者 Last-Modified
- entity-tag 实体的标示
- HTTP-date  实体生成的时间


# HTTP响应
## 206 Partial Content
如果只获取一段body，服务器会返回206 Partial Content，而不是200。

## Content-Range 头部
显示当前片断包体在完整包体中的位置
> Content-Range = byte-content-range / other-content-range
- byte-content-range = bytes-unit SP ( byte-range-resp / unsatisfied-range ) 
    - byte-range-resp = byte-range "/" ( complete-length / "*" )
        - complete-length = 1*DIGIT （完整资源的大小，如果未知则用*号替代） 
        - byte-range = first-byte-pos "-" last-byte-pos

### 举例
- Content-Range: bytes 42-1233/1234 
- Content-Range: bytes 42-1233/*

## 412 Precondition Failed
请求过一次服务器端后，响应头部会返回一个Etag，将该Etag放入if-Match头部中再次请求。
如果匹配的话就会正常返回对应范围，如果不匹配则会返回412 Precondition Failed。就不能使用之前下载那部分进行合成文件。

## 416 Range Not Satisfiable
请求范围不满足实际资源的大小，其中Content-Range中的complete-length显示完整响应的长度。

## 200 OK
服务器不支持Range请求时，则以200返回完整的响应包体

# 多重范围与multipart
用逗号分割范围
> Range: bytes=0-50, 100-150

## 响应
头部响应为multipart/byteranges，并且响应分隔符。与FORM响应类似，会分段标示，且每一段都有Content-Rnage
- Content-Type:multipart/byteranges; boundary=...