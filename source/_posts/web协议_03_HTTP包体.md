---
title: HTTP包体
date: 2021-02-18 14:00:00
tags: web协议
categories: 网络
---

主要记录HTTP请求包体内容的格式协议，包含确定和不确定时包体长度、媒体类型的传输、FORM表单提交等协议格式。
<!-- more -->

# HTTP包体：承载的消息内容
请求或者响应都可以携带包体
> HTTP-message = start-line *( header-field CRLF ) CRLF [ message-body]
>   - message-body = *OCTET: 二进制字节流

## 以下消息不能含有包体
- HEAD方法请求对应的响应
- 1xx、204、304对应的响应
- CONNECT方法对应的2xx响应

# 两种传输HTTP包体的方式

## 确定包体的全部长度
使用Content-Length头部明确指明包体长度
> Content-Length = 1*DIGIT
>   - 用10进制（不是16进制）表示包体中的字节个数，且必须与实际传输的包体长度一致

### 优点
接受端处理更简单

## 不能明确包体的全部长度
使用Transfer-Encoding头部指明使用Chunk传输方式
- 含Transfer-Encoding头部后Content-Length头部应被忽略

### Transfer-Encoding头部
> transfer-coding = "chunked"/"compress"/"deflate"/"gzip"/transfer-extension

使用Chunked transfer encoding分块传输编码：Transfer-Encoding: chunked
```
chunked-body = *chunk
                last-chunk
                trailer
                CRLF
```
> chunk = chunk-size [ chunk-ext] CRLF chunk-data CRLF
>   - chunk-size = 1*HEXDIG （注：这里是16进制 不同于Content-Lenght DIGIT的10进制）
>   - chunk-data = 1*OCTET

> last-chunk = 1*("0") [chunk-ext] CRLF（1个或多个0，表明chunk已经结束了）

> trailer-part = *(header-field CRLF )（在chunk-body已经传输后，可以再次发送header）

### 优点
- 基于长连接持续推送动态内容
- 压缩提及较大的包体时，不必完全压缩完（计算出头部）再发送，可以边发送边压缩
- 传递必须在包体传输完才能计算出Trailer头部

### Trailer头部传输
TE 头部:客户端在请求在声明是否接收Trailer头部 
> TE: trailers

Trailer头部:服务器告知接下来chunk包体后会传输哪些Trailer头部 
> Trailer: Date

#### 以下头部不允许出现在Trailer的值中
- 用于信息分帧的首部 (例如 Transfer-Encoding 和 Content-Length)
- 用于路由用途的首部 (例如 Host)
- 请求修饰首部 (例如控制类和条件类的，如 Cache-Control，Max-For wards，或者 TE)
- 身份验证首部 (例如 Authorization 或者 Set-Cookie)
- Content-Encoding, Content-Type, Content-Range，以及 Trailer 自身

Trailer头部HTTP/1.1中并不是所有浏览器都支持

# MIME媒体类型(Multipurpose Internet Mail Extensions)
> content := "Content-Type" ":" type "/" subtype *(";" parameter)
> - type := discrete-type / composite-type
>   - discrete-type := "text" / "image" / "audio" / "video" / "application" / extension-token
>   - composite-type := "message" / "multipart" / extension-token
>   - extension-token := ietf-token / x-token
> - subtype := extension-token / iana-token
> - parameter := attribute "=" value

大小写不敏感，但通常是小写。例如: Content-type: text/plain; charset="us-ascii"

## Media Types查阅地址
*** https://www.iana.org/assignments/media-types/media-types.xhtml ***

# Content-Disposition头部(RFC6266)
当传输的包体是附件的形式给浏览器显示时比较有用

> disposition-type = "inline" | "attachment" | disp-ext-type
- inline: 指定包体是以 inline 内联的方式，作为页面的一部分展示
- attachment:指定浏览器将包体以附件的方式下载
    - 例如: Content-Disposition: attachment
    - 例如: Content-Disposition: attachment; filename="filename.jpg"
- 在多包体multipart/form-data 类型应答中，可以用于子消息体部分
    - 如 Content-Disposition: form-data; name="fieldName"; filename="filename.jpg"

# HTML FORM表单时包体的协议格式

## 表单提交请求时的关键属性
- action: 提交时发起HTTP请求的URI
- method: 提交时发起HTTP请求的http方法
    - GET: 将表单数据以URI参数的方式提交
    - POST: 将表单数据放在请求包体中提交
- enctype: 在POST方法下，对表单内容在请求包体中的编码方式 
    - application/x-www-form-urlencoded 
        - 数据被编码成以‘&’分隔的键-值对, 同时以‘=’分隔键和值，字符以URL编码方式编码
    - multipart/form-data
        - boundary 分隔符
        - 每部分表述皆有HTTP头部描述子包体，例如Content-Type
        - last boundary结尾

## multipart(RFC1521):一个包体中多个资源表述
Content-type 头部指明这是一个多表述包体 
> Content-type: multipart/form-data;
> - boundary=----WebKitFormBoundar yRRJKeWfHPGrS4LKe 

## Boundary 分隔符的格式
- boundary := 0*69&lt;bchars&gt; bcharsnospace（不能超过70个字符）
    - bchars := bcharsnospace / " "
    - bcharsnospace:=DIGIT/ALPHA/"'"/"("/")"/"+"/"_"/","/"-"/"."/"/"/":" / "=" / "?"

## multipart-body(RFC822)
> multipart-body = preamble 1*encapsulation close-delimiter epilogue

前后两段通常不使用，一般也会要求服务端丢弃掉
- preamble := discard-text
- epilogue := discard-text
    - discard-text := *(*text CRLF)

结束分隔符，注意和每一部分资源表述的的分隔符不同，在最后也要有"--"
- close-delimiter = "--" boundary "--" CRLF
### 每部分包体格式
一个或者多个，表示每一个资源表述
> encapsulation = delimiter body-part CRLF
- delimiter = "--" boundary CRLF
- body-part = fields *( CRLF *text )
    - field = field-name ":" [ field-value ] CRLF
        - content-disposition: form-data; name="xxxxx“
        - content-type 头部指明该部分包体的类型
