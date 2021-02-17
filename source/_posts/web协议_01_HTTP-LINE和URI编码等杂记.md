---
title: HTTP-line和URI编码等杂记
date: 2021-02-04 10:00:00
tags: web协议
categories: 网络
---

主要记录了http-line和URI编码信息，还记录了一些web协议相关杂乱的知识

<!-- more -->

# RFC文档，对网络协议的权威解释

# 基于ABNF描述的HTTP协议格式
ABNF语法 (扩充巴科斯-瑙尔范式)，是一种定义协议语法的原语言

> HTTP-message = start-line *( header-field CRLF) CRLF [message-body]

MAC->IP->TCP/port->session->TSL/SSL->http/https

# OSI模型/TCPIP模型
``` 
物理层-bit 01010
链路层-frame MAC|TCP+IP+Data|FCS*
网络层-Packet IP|TCP+Data
传输层-Datagram TCP|Data
会话层-
表示层-
应用层-  Header|Data
```
- TCP进程与进程之间的通信
- IP 机器与机器之间的通信

# 抓包工具
- wireshark
- tcpdump


# 浏览器加载时间
## 触发流程
- 解析HTML结构
- 加载外部脚本和样式表文件
- 解析并执行脚本代码（部分脚本可能会阻塞页面的加载
- DOM树构建完成（DOMContentLoaded事件
- 加载图片等外部文件
- 页面加载完毕（load事件

## 请求事件细节分布
- Queueing 浏览器会在以下情况下对请求排队
    - 存在更高优先级的请求
    - 此源已经打开六个TCP连接，达到阈值，仅适用于HTTP/1.0和HTTP/1.1
    - 浏览器正在短暂分配磁盘缓存中的空间
- Stalled 请求可能会因Queueing中描述的任何原因而停止
- DNS Lookup 浏览器正在解析请求中的IP地址
- Proxy Negotiation 浏览器正在与代理服务器协商请求
- Request Sent 正在发送请求
- ServiceWorker Preparation 浏览器正在启动Service Worker
- Request to ServiceWorker 正在将请求发送到Service Worker
- Waiting(TTFB) 浏览器正在等待响应的第一个字节。TTFB表示Time To First Byte。此时间包括1次往返延迟时间以及服务器准备响应所用的时间
- Content Download 浏览器正在接受响应
- Receiving Push 浏览器正在通过HTTP/2 服务器推送接收此响应数据
- Reading Push 浏览器正在读取之前收到的本地数据


# URI编码
传递数据中对可能产生歧义性的数据编码进行转换
## 范围
- 不在ASCII码范围内的字符
- ASCII码中不可显示的字符
- URI中规定的保留字符
- 不安全字符（传输环节中可能回被不正确处理），如空格、引号、尖括号等

## 保留字符 reserved = gen-delims/sub-delims
```
gen-delims = : / ? # [ ] @

sub-delims = ! $ & ' ( ) * + , ; =
```
## 非保留字符 unreserved = ALPHA/DIGIT / - . _ ~
```
ALPHA %41-%5A and %61-%7A

DIGIT %30-%39

- %2D %2E %5F

~ %7E （某些实现将其认为保留字符
```
## URI百分号编码
### 百分号编码方式
> pct-encoded = % HEXDIG HEXIDG
- US-ASCII 128个字符（95个可显示字符，33个不可显示字符）
- 对应HEXDIG十六进制中的字母，大小写等价

### 非ASCII码字符（如中文），建议先记性UTF8等编码后，再通过US-ASCII编码

### 对于URI合法字符，编码与不编码是等价的

# HTTP请求行 request-line
> request-line = method SP request-target SP HTTP-version CRLF
## method
指明操作目的，动词
### 常见方法(RFC7231)
- GET
- HEAD 服务器不发送BODY，用以获取HEAD元数据
- POST
- PUT
- DELETE
- CONNECT 建立tunnel隧道
- OPTIONS 显示服务器对访问资源支持的方法，Allow属性中返回
- TRACE 回显服务器收到的请求，用于定位问题，但有安全风险。在nginx 0.5.17后访问返回405

### 用于文档管理的WEBDAV方法(RFC2518)
- PROPFIND 从web资源中检索以XML格式存储的属性。它也被重载，以允许一个检索远程系统的集合结构（也叫目录层次结构）
- PROPPATCH 在单个原子性动作中更改和删除资源的多个属性
- MKCOL 创建集合或者目录
- COPY 将资源从一个URI复制到另一个URI
- MOVE 将资源从一个URI移动到另一个URI
- LOCK 锁定一个资源。WebDAV支持共享锁和互斥锁
- UNLOCK 解除资源的锁定

## request-target: origin-form/absolute-from/authority-form/asterisk-form
- origin-form: absolute-path["?" query] 向origin server发起的请求，path为空时必须传递
- absolute-form: absolute-URI 仅用于正向代理proxy发起请求时，详见正向代理与隧道
- authority-form: authority 仅用于CONNECT方法，例如CONNECT www.example.com:80 HTTP/1.1
- asterisk-form: "*" 仅用于OPTIONS方法

## HTTP-version版本号
- HTTP/0.9 只支持GET方法 已经过时 
- HTTP/1.0 RFC1945, 1996, 常见使用于代理服务器 如Nginx默认配置
- HTTP/1.1 RFC2616, 1999
- HTTP/2.0 2015.5


# HTTP响应行
> status-line = HTTP-version SP status-code SP reason-phrase CRLF
- status-code = 3DIGIT
- reason-phrase= *(HTAB/SP/VCHAR/obs-text)

## 响应码
响应码规范：RFC6585（2012.4）、RFC7231（2014.6）

### 1XX
请求已接受到，需要进一步处理才能完成，HTTP1.0后支持
- 100 Continus 上传大文件前使用，由客户端发起请求中卸载Expect： 100-continue头部触发
- 101 Switch Protocols 协议升级使用，由客户端发起请求中携带Upgrade头部触发，如升级websocket或者http/2.0
- 102 Processing WebDAV请求可能包含许多涉及文件操作的子请求，需要很长时间才能完成请求。该代码表示服务器已经收到并正在处理请求，但无响应可用。这样可以防止客户端超时，并假设请求丢失

### 2xx
- 200 OK 成功返回响应
- 201 Created 有新资源在服务器端被成功创建
- 202 Accepted 服务器接收并开始处理请求，但请求为处理完成。这样一个模糊的概念是有意设计的，可以覆盖更多的场景。例如一步、需要长时间处理的任务
- 203 Non-Authoritative Information 当代理服务器修改了origin server的原始响应包体时（例如更换了HTML中的元素值），代理服务器可以通过修改200为203的方式告知客户端这一事实，方便客户端为这一行为作出相应的处理。203响应可以被缓存。
- 204 No Content 成功执行了请求且不携带响应体，并暗示客户端无需更新当前页面的视图
- 205 Reset Content 成功执行了请求且不携带响应包体，同时指明客户端需要更新当前视图
- 206 Partial Content 使用range协议时返回部分响应内容时的响应码
- 207 Multi-Status RFC4918 在WebDAV协议中以XML返回多个资源的状态
- 208 Already Reported RFC5842 为避免相同集合下资源在207响应码下重复上报，使用208可以使用集合的响应码

### 3xx
重定向使用Location指向的资源或者缓存中的资源。在RFC2068中规定客户端重定向次数不应超过5次，以防止死循环
- 300 Multiple Choices 资源有多种表述，通过300返回给客户端后由其自行选择访问哪一种表述。由于缺乏明确的细节，300很少用
- 301 Moved Permanently 资源永久性的重定向到林一个URI中
- 302 Found 资源临时的重定向到另一个URI中
- 303 See Other 重定向到其他资源，常用于POST/PUT等方法的响应中
- 304 Not Modified 当客户端拥有可能过期的缓存时，会携带缓存的标识etag、时间等信息询问服务器缓存是否仍可复用，而304是告诉客户端可以复用缓存
- 307 Temporary Redirect 类似302，但明确重定向后请求方法必须与原方法请求相同，不得改变
- 308 Permanent Redirect 类似301，但明确重定向后请求方法必须与原方法请求相同，不得改变

### 4xx
客户端错误
- 400 Bad Request 服务器认为客户端出现了错误，但不能明确判断为以下哪种错误时使用此代码。例如HTTP请求格式错误
- 401 Unauthorized 用户认证信息缺失或不正确，导致服务器无法处理请求
- 407 Proxy Authentication Required 对需要经由代理的请求，认证信息未通过代理服务器的验证
- 403 Forbidden 服务器理解请求的含义，但没有权限执行此请求
- 404 Not Found 服务器没有找到对应的资源
- 410 Gone 服务器没有找到对应的资源，且明确的知道该位置永久性的找不到该资源
- 405 Method Not Allowed 服务器不支持请求行中的Method方法
- 406 Not Acceptable 对客户端指定的资源表述不存在（例如对语言或者编码有要求），服务器返回表述列表供客户端选择
- 408 Request Timeout 服务器接受请求超时
- 409 Conflict 资源冲突，例如上传文件时目标位置已经存在版本更新的资源
- 411 Length Required 如果请求含有包体且未携带Content-Length头部，且不属于chunk类请求时，返会411
- 412 Precondition Failed 复用缓存时传递的If-Unmodified-Since或If-None-Match头部不被满足
- 413 Payload Too large/Request Entity Too large 请求的包体超出服务器能处理的最大长度
- 414 URI Too Long 请求的URI超出服务器能接受的最大长度
- 415 Unsupported Media Type 上传的文件类型不被服务器支持
- 416 Range Not Satisfiable 无法提供Range请求中指定的那段包体
- 417 Expectation Failed 对于Expect请求头部期待的情况无法满足时的响应码
- 421 Misdirected Request 服务器认为这个请求不该发给它，因为它没有能力处理
- 426 Upgrade Required 服务器拒绝基于当前HTTP协议提供服务，通过Upgrade头部告知客户端必须升级协议才能继续处理
- 428 Precondition Required 用户请求中缺失了条件类头部，例如If-Match
- 429 Too Many Requests 客户端发送请求的速率过快
- 431 Request Header Fields Too Large 请求的HEADER头部大小超过限制
- 451 Unavailable For Legal Reasons RFC7725，由于法律原因资源不可访问

### 5xx
服务端错误
- 500 Internal Server Error 服务器内部错误，且不属于以下错误类型
- 501 Not Implemented 服务器不支持实现请求所需要的功能
- 502 Bad Gateway 代理服务器无法获取到合法响应
- 503 Service Unavailable 服务器资源尚未准备好处理当前请求
- 504 Gateway Timeout 代理服务器无法及时的从上游获取响应
- 505 HTTP Version Not Supported 请求使用的HTTp协议版本不支持
- 507 Insufficient Storage 服务器没有足够的空间处理请求
- 508 Loop Detected 访问资源时检测到循环
- 511 Network Authentication Required 代理服务器发现客户端需要进行身份验证才能获得网络访问权限
