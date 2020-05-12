---
title: redis客户端源码
date: 2020-03-13 10:00:00
tags: redis
categories: 中间件
---

学习一下Redis客户端Jedis源码，简单的API经常用已经很熟了，稍微学习一下底层的原理和设计。
<!-- more -->

- 创建Client->BinaryJedis-Connection，创建了一个DefaultJedisSocketFactory
- checkIsInMultiOrPipeline，进行无事务检查，使用事务要用jedis.Transaction
- 向RedisOutputStream写入字节数据
- 使用sendCommand发送指令，get、set、其他的指令最终都是使用该方法进行发送的。

``` java
  public void sendCommand(final ProtocolCommand cmd, final byte[]... args) {
    try {
      connect();
      Protocol.sendCommand(outputStream, cmd, args);
    } catch (JedisConnectionException ex) {
      /*
       * When client send request which formed by invalid protocol, Redis send back error message
       * before close connection. We try to read it to provide reason of failure.
       */
      try {
        String errorMessage = Protocol.readErrorLineIfPossible(inputStream);
        if (errorMessage != null && errorMessage.length() > 0) {
          ex = new JedisConnectionException(errorMessage, ex.getCause());
        }
      } catch (Exception e) {
        /*
         * Catch any IOException or JedisConnectionException occurred from InputStream#read and just
         * ignore. This approach is safe because reading error message is optional and connection
         * will eventually be closed.
         */
      }
      // Any other exceptions related to connection?
      broken = true;
      throw ex;
    }
  }
```

# RESP protocol redis序列化协议
进行一次set操作，key是'test'，value是'abc'，本地创建Jedis Client后通过socket.accept获取写出的信息为
```
*3
$3
SET
$4
test
$3
abc
```

大致看上去好像和appendOnly.aof文件中保存的东西类似，其实AOF文件中其实保存的就是操作指令转化为该协议的内容。对于词内容是什么，其实redis官方文档中就有这方面的解释 https://redis.io/topics/protocol

The RESP protocol was introduced in Redis 1.2, but it became the standard way for talking with the Redis server in Redis 2.0. This is the protocol you should implement in your Redis client.

RESP is actually a serialization protocol that supports the following data types: Simple Strings, Errors, Integers, Bulk Strings and Arrays.

The way RESP is used in Redis as a request-response protocol is the following:

- Clients send commands to a Redis server as a RESP Array of Bulk Strings.
- The server replies with one of the RESP types according to the command implementation.

In RESP, the type of some data depends on the first byte:
- For Simple Strings the first byte of the reply is "+"
- For Errors the first byte of the reply is "-"
- For Integers the first byte of the reply is ":"
- For Bulk Strings the first byte of the reply is "$"
- For Arrays the first byte of the reply is "*"
Additionally RESP is able to represent a Null value using a special variation of Bulk Strings or Array as specified later.

In RESP different parts of the protocol are always terminated with "\r\n" (CRLF).

google翻译了下，有点奇怪，但是也能理解，其实就是分别对String、error、整形、字符串、数组设置对应的标识
- 对于简单字符串，答复的第一个字节为“ +”
- 对于错误，回复的第一个字节为“-”
- 对于整数，答复的第一个字节为“：”
- 对于批量字符串，答复的第一个字节为“ $”
- 对于数组，回复的第一个字节为“ *”

由此解析出：
```
*3 传入数组长度为3 
$3 字符串长度3
SET 字符串内容
$4 字符串长度4
test 字符串内容
$3 字符串长度3
abc 字符串内容
```

## 响应信息获取
redis.clients.jedis.Connection#getBulkReply
- redis.clients.jedis.Connection#flush
- redis.clients.jedis.Connection#readProtocolWithCheckingBroken
- 读入RedisInputStream中响应写入的信息，而后进行Protocol.read()

``` java
  private static Object process(final RedisInputStream is) {
    final byte b = is.readByte();
    switch (b) {
    case PLUS_BYTE:
      return processStatusCodeReply(is);
    case DOLLAR_BYTE:
      return processBulkReply(is);
    case ASTERISK_BYTE:
      return processMultiBulkReply(is);
    case COLON_BYTE:
      return processInteger(is);
    case MINUS_BYTE:
      processError(is);
      return null;
    default:
      throw new JedisConnectionException("Unknown reply: " + (char) b);
    }
  }
```
读第一个字节判断返回的数据是某种RESP协议数据类型。然后以对应的方式进行解析。

# redis.clients.jedis.JedisMonitor
实现JedisMonitor，监控Redis Client的指令动作，但会大幅降低性能。