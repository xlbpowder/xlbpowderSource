---
title: hexo与node版本问题
date: 2020-06-24 18:30:00
tags: hexo
categories: 其他
---

一直都是用以前的机器更新个人站相关的代码，自从换了新的电脑后，安装了node和hexo之后，就没用这个机器更新过个人站的东西

<!-- more -->
# 现象
hexo g构建了public文件后，该文件夹下全部文件为0KB，但hexo s本地启动http服务却有效，可以正常访问

所以将该文件发布上去之后，自然也访问不到任何内容

# 排查
node版本，操作系统是MacOS，直接在node官网安装的node版本是14，其实是非常新的。考虑到以前使用的hexo和NexT theme都是老版本的东西，所以想通过降版本的方式来解决

# 解决
npm全局安装工具n
``` linux
npm install -g n 
```

替换为稳定版本
``` linux
sudo n stable
```

查看版本，已经降低为12.18.1了
``` linux
node -v
v12.18.1
```

然后再次hexo clean&hexo g之后，查看public目录下已经生成了有内容的文件了