---
title: docker 存储
date: 2019-08-28 10:45:00
tags: docker
categories: DevOps
---

> 在通过docker创建mysql的过程中，遇到了一些关于docker存储的知识盲区，趁着上次临时学的东西还没忘，尽快学习下关于docker存储的知识。

<!-- more -->
在使用docker过程中，往往需要对数据进行持久化，或者需要在多个容器之间共享数据，这就涉及到了容器的数据管理存储操作。

容器中管理数据的主要方式有两种：
- 数据卷(Data Volnumes): 容器内数据直接映射到本地主机环境
- 数据容器卷(Date Volnume Containers): 使用特定容器维护数据卷

# 数据卷
数据卷是一个可供容器使用的特殊目录，它将主机操作系统目录直接映射进容器，类似于Linux中的mount操作。

数据卷可以提供很多有用的特性，如下所示：
- 数据卷可以在容器之间共享和重用，容器间传递数据将变得高效方便
- 对数据卷内数据的修改会立马生效，无论是容器内操作还是本地操作
- 对数据卷的更新不会影响镜像，解耦了应用和数据
- 卷会一直存在，直到没有容器使用，可以安全地卸载它

## 创建数据卷
在用docker run命令的时候，使用-v标记可以在容器内创建一个数据卷。多次重复使用-v标记可以创建多个数据卷。

下面使用training/webapp镜像创建一个web容器，并创建一个数据卷挂载到容器的/webapp目录：
```
$ docker run -d -P --name web -v /webapp training/webapp python app.py
```
## 挂载一个主机目录作为数据卷
使用-v标记也可以指定挂载一个本地的已有目录到容器中去作为数据卷
```
$ docker run -d -P --name web -v /src/webapp:/opt/webapp training/webapp python app.py
```
上面的命令加载主机的/src/webapp目录到容器的/opt/webapp目录。

这个功能在进行测试的时候十分方便，比如用户可以将一些程序或数据放到本地目录中，然后在容器内运行和使用。另外，本地目录的路径必须是绝对路径，如果目录不存在Docker，会自动创建。

Docker挂载数据卷的默认权限是读写（rw），用户也可以通过ro指定为只读：
```
$ docker run -d -P --name web -v /src/webapp:/opt/webapp:ro training/webapp python app.py
```
加了:ro之后，容器内对所挂载数据卷内的数据就无法修改了。

## 挂载一个本地主机文件作为数据卷
-v标记也可以从主机挂载单个文件到容器中作为数据卷（不推荐）。
```
$ docker run --rm -it -v ~/.bash_history:/.bash_history ubuntu /bin/bash
```
这样就可以记录在容器输入过的命令历史了。

# 数据卷容器
如果用户需要在多个容器之间共享一些持续更新的数据，最简单的方式是使用数据卷容器。数据卷容器也是一个容器，但是它的目的是专门用来提供数据卷供其他容器挂载。

首先，创建一个数据卷容器dbdata，并在其中创建一个数据卷挂载到/dbdata：
```
$ docker run -it -v /dbdata --name dbdata ubuntu
root@3ed94f279b6f:/#
```

查看/dbdata目录：
```
root@3ed94f279b6f:/# ls
bin  boot  dbdata  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  
    sbin  srv  sys  tmp  usr  var
```

然后，可以在其他容器中使用--volumes-from来挂载dbdata容器中的数据卷，例如创建db1和db2两个容器，并从dbdata容器挂载数据卷：
```
$ docker run -it --volumes-from dbdata --name db1 ubuntu
$ docker run -it --volumes-from dbdata --name db2 ubuntu
```
此时，容器db1和db2都挂载同一个数据卷到相同的/dbdata目录。三个容器任何一方在该目录下的写入，其他容器都可以看到。

例如，在dbdata容器中创建一个test文件，如下所示：
```
root@3ed94f279b6f:/# cd /dbdata
root@3ed94f279b6f:/dbdata# touch test
root@3ed94f279b6f:/dbdata# ls
test
```

在db1容器内查看它：
```
$ docker run -it --volumes-from dbdata --name db1  ubuntu
root@4128d2d804b4:/# ls
bin  boot  dbdata  dev  etc  home  lib  lib64  media  mnt  opt  proc  root  run  
    sbin  srv  sys  tmp  usr  var
root@4128d2d804b4:/# ls dbdata/
test
```

可以多次使用--volumes-from参数来从多个容器挂载多个数据卷。还可以从其他已经挂载了容器卷的容器来挂载数据卷。

## 注意
使用--volumes-from参数所挂载数据卷的容器自身并不需要保持在运行状态。

如果删除了挂载的容器(包括dbdata、db1和db2)，数据卷并不会被自动删除。如果要删除一个数据卷，必须在删除最后一个还挂载着它的容器时显式使用docker rm-v命令来指定同时删除关联的容器。

# 利用数据卷容器来迁移数据
可以利用数据卷容器对其中的数据卷进行备份、恢复，以实现数据的迁移
## 备份
使用下面的命令来备份dbdata数据卷容器内的数据卷：
```
$ docker run --volumes-from dbdata -v $(pwd):/backup --name worker ubuntu tar cvf /backup/backup.tar /dbdata
```
这个命令稍微有点复杂，具体分析一下。首先利用ubuntu镜像创建了一个容器worker。使用--volumes-from dbdata参数来让worker容器挂载dbdata容器的数据卷（即dbdata数据卷）；使用-v$(pwd):/backup参数来挂载本地的当前目录到worker容器的/backup目录。

worker容器启动后，使用了tar cvf/backup/backup.tar/dbdata命令来将/dbdata下内容备份为容器内的/backup/backup.tar，即宿主主机当前目录下的backup.tar。

## 恢复
如果要将数据恢复到一个容器，可以按照下面的步骤操作。首先创建一个带有数据卷的容器dbdata2：
```
$ docker run -v /dbdata --name dbdata2 ubuntu /bin/bash
```

然后创建另一个新的容器，挂载dbdata2的容器，并使用untar解压备份文件到所挂载的容器卷中：
```
$ docker run --volumes-from dbdata2 -v $(pwd):/backup busybox tar xvf
/backup/backup.tar
```

## 总结
以上都是从书中直接抄来的，总结下其实就是：

容器的数据存储方式就是使用数据卷。数据卷可以创建在容器内部，也可以挂载宿主机的目录或文件到容器中作为数据卷使用。

一般如果需要对数据进行持久化，则为了数据安全考虑，会选择挂载宿主机目录到容器中作为数据卷来进行存储。

如果不需要数据进行持久化，则直接在容器中创建数据卷即可。

不建议挂载宿主机某个文件到容器中使用。

可以通过数据卷容器实现容器之间的数据共享，数据备份与恢复。

数据是非常重要的资源，docker在设计上充分考虑了这点，为数据的管理做了充分的支持。数据卷和数据卷容器提供了共享、备份、恢复即使是容器运行时出现了故障，也不同担心数据丢失。同时解耦了数据与容器。

## 总结之前搭建mysql时候进行数据持久化遇到的问题

挂载可以挂载文件夹、也可以挂载文件

挂载文件夹的话，文件夹下的内容修改了，会同步修改容器中的内容

但是如果挂载文件的话，这个文件如果inode修改了，比如用vim，vim修改了之后，wq保存了文件，文件的inode就会修改，这时host的这个挂载的文件就和容器的不同步了

之前搭建mysql挂载配置文件遇到的坑，一般应用镜像都会提供给可配置或者需要持久化的信息一个可以挂载的文件入口，可能和以前的配置不一样。

mysql5.6这个官方镜像，默认的配置就和普通我们启动的mysql的配置文件不太一样。他默认my.cnf 中是
```
!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/
```
conf.d/ mysql.conf.d/这两个文件夹 就可以用来挂载配置的

所以做法就是，先在宿主机配置好conf.d/路径下的三个配置文件和mysql.conf.d/下的配置文件，然后docker run的时候挂载这两个路径


# 参考资料
* 《Docker技术入门与实战》
* https://www.cnblogs.com/breezey/p/9589288.html