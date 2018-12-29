---
title: hexo
date: 2018-09-04 15:12:28
tags:
categories: Others
---

# Hexo&GitHub Pages

最初接触github pages之后，一直想尝试搭建一个属于自己的博客网站，根据朋友的博客网站搭建选择了jekyll，但由于选择的模板以及调试问题居多，最后放弃了。偶然间了解到了hexo和vuepress，了解了之后感觉vuepress的模板比较单一，再加上自己不是很了解vuejs（说的好像node.js自己就很懂一样），最后选择了hexo。

hexo是基于node.js的高效的静态站点生成框架，通过Hexo可以轻松地使用Markdown编写文章，除了Markdown本身的语法之外，还可以使用Hexo提供的标签插件来快速的插入特定形式的内容。使用起来非常方便。

从基于Ruby的jekyll，到hexo，再到vuepress。最后选择了hexo。真的是因为用起来简单，但是可能由于自己的电脑git出现了一些问题，导致不能使用hexo deploy，每次都要自己手动构建提交，这还是很麻烦的。

关于如何在使用github pages搭建博客网站，这里就不抄写细节了，能找到一大堆教程，这篇文章主要是记录下我在学习hexo的一些常用命令。

github pages是github提供的一个托管的公开网页，会自动将你id.github.io仓库的静态文件自动部署至：https://你的githubID.github.io/ 但由于是公开的仓库，所以大家要注意不要将敏感数据上传。

由于hexo是基于NodeJS的，所以要先安装NodeJS，具体教程有很多，就不做表述了，下面记录了一些搭建博客过程中常用的命令。

<!-- more -->

# 常用指令
## 清理
``` linux
$ hexo clean
```

## 构建服务
``` linux
$ hexo generate
```
也可以缩写为：
``` linux
$ hexo g
```

## 启动服务
``` linux
$ hexo server
```
缩写：
``` linux
$ hexo s
```

## 部署到远程站点
``` linux
$ hexo deploy
```
缩写：
``` linux
$ hexo d
```

## 新建博文
``` linux
$ hexo new "post name"
```
缩写：
``` linux
$ hexo n "post name"
```

之后会在source/\_posts下面生成对应的post name.md的文件。

## 创建新主页
``` linux
$ hexo new page "page name"
```

之后会在source/\_posts/page name下面生成对应的page index.md的文件。如：tags、categories的主页，然后再标题头中添加type。


# 选择主题
https://hexo.io/themes/

## 替换模板
github上clone各类模板到/themes/xxx

修改_config.yml中的theme: xxx

我个人使用的Theme是NexT，他有三种模式，分别可以在模板的_config.yml中设置schemes。
``` yml
# Schemes
scheme: Muse
#scheme: Mist
#scheme: Pisces
#scheme: Gemini
```


## 安装hexo git配置插件
npm install hexo-deployer-git --save
配置_config.yml中修改入下：
``` yml
deploy:
  type: git
  repo: gti仓库https地址或SSH地址
  branch: master
```

目前我是每一次generate之后，将构建好的文件从public中全部复制到本地仓库，然后再上传，其实嘛区别不大，就是自己打两个命令。