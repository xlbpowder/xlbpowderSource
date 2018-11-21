---
title: Lambda、函数式接口、引用表达式
date: 2018-11-21 14:00:01
tags:
categories: Java
---

# Lambda、函数式接口、引用表达式

## 写在前面
>最近在学习Stream的api，发现Java推出的函数式接口、Lambda表达式、引用表达式等大都服务于Stream的api使用，但其实并不一定，所以收集整理了下关于相关特性的用法。
在这只会讲解下基本的用法，关于函数编程框架的详细解读，大家可以参考下这篇 [Java8 函数式编程探秘](http://www.importnew.com/27901.html "Java8 函数式编程探秘")，介绍的非常全面。

## 函数式接口
先讲一个注解 ***@FunctionalInterface***

```java
@Documented
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
public @interface FunctionalInterface {}
```

@FunctionalInterface 注解要求接口有且只有一个抽象方法，JDK中有许多类用到该注解，比如 Runnable，它只有一个 Run 方法。（注：默认方法并不是抽象方法）

```java
@FunctionalInterface
public interface Runnable {
    /**
     * When an object implementing interface <code>Runnable</code> is used
     * to create a thread, starting the thread causes the object's
     * <code>run</code> method to be called in that separately executing
     * thread.
     * <p>
     * The general contract of the method <code>run</code> is that it may
     * take any action whatsoever.
     *
     * @see     java.lang.Thread#run()
     */
    public abstract void run();
}
```
Java8中接口可以定义静态方法，直接通过类名调用，并且接口中可以通过default为抽象方法提供默认的实现。接口继承接口时，如果默认方法相同，则需要进行重写

Java8推出的Lambda表达式只能针对函数式接口使用。


## Lambda的语法

首先Lambda可以认为是一种特殊的匿名内部类，其次lambda只能用于函数式接口。

lambda语法：

```java
([形参列表，不带数据类型])-> {
    //执行语句
    [return..;]
}
```

要注意的点：
1. 如果形参列表是空的，只需要保留（）即可
2. 如果没有返回值。只需要在{}写执行语句即可
3. 如果接口的抽象方法只有一个形参，（）可以省略，只需要参数的名称即可
4. 如果执行语句只有一行，可以省略{}，但是如果有返回值时，情况特殊。
5. 如果函数式接口的方法有返回值，必须给定返回值，如果执行语句只有一句，还可以简写，即省去大括号和return以及最后的；号。
6. 形参列表的数据类型会自动推断，只需要参数名称。

eg:

```java
public class TestLambda {
     public static void main(String[] args) {
           TestLanmdaInterface1 t1 = new TestLanmdaInterface1() {
                @Override
                public void test() {
                     System.out.println("使用匿名内部类");
 
                }
           };
           //与上面的匿名内部类执行效果一样
           //右边的类型会自动根据左边的类型进行判断
           TestLanmdaInterface1 t2 = () -> {
                System.out.println("使用lanbda");
           };
           t1.test();
           t2.test();
 
           //如果执行语句只有一行，可以省略大括号
           TestLanmdaInterface1 t3 = () -> System.out.println("省略执行语句大括号，使用lanbda");
           t3.test();
 
           TestLanmdaInterface2 t4 = (s) -> System.out.println("使用lanbda表达式，带1个参数，参数为："+s);
           t4.test("字符串参数1");
 
           TestLanmdaInterface2 t5 = s -> System.out.println("使用lanbda表达式，只带1个参数，可省略参数的圆括号，参数为："+s);
           t5.test("字符串参数2");
 
           TestLanmdaInterface3 t6 = (s,i) -> System.out.println("使用lanbda表达式，带两个参数，不可以省略圆括号，参数为："+s+"  "+ i);
           t6.test("字符串参数3",50);
     }
}
 
@FunctionalInterface
interface TestLanmdaInterface1 {
     //不带参数的抽象方法
     void test();
}
@FunctionalInterface
interface TestLanmdaInterface2 {
     //带参数的抽象方法
     void test(String str);
}
@FunctionalInterface
interface TestLanmdaInterface3 {
     //带多个参数的抽象方法
     void test(String str,int num);
}
```

```java
@FunctionalInterface
interface IDemo {
    void doSomething();
}

class Demo {
    public void doSomething(IDemo c) {
        System.out.println(c);
        c.doSomething();
    }
}

public class Test {

    public static void main(String[] args) {
        Demo demo = new Demo();
        demo.doSomething(new IDemo() {
            @Override
            public void doSomething() {
                System.out.println("使用匿名内部类实现");

            }
        });
        demo.doSomething(() -> System.out.println("使用lambda表达式实现"));
        /*
        demo.doSomething(() -> {
            System.out.println("使用lambda表达式实现");
            System.out.println("使用lambda表达式实现");
        });
        */
    }
```

可以看出，lambda表达式和匿名内部类并不完全相同

观察生成的class文件可以看出，lambda表达式并不会生成额外的.class文件，而匿名内部类会生成Test$1.class
```java
cn.lb.Test$1@4554617c
使用匿名内部类实现
cn.lb.Test$$Lambda$1/1324119927@404b9385
使用lambda表达式实现
```


## 函数式接口引用表达式

* 引用实例方法：
    自动把调用方法的时候的参数，全部传给引用的方法

```java
<函数式接口> <变量名> = <实例> :: <实例方法名>
//自动把实参传递给引用的实例方法
<变量名>.<接口方法>（[实参]）
```
* 引用类方法（静态方法）：
    自动把调用方法的时候的参数，全部传给引用的方法

* 引用类的实例方法：
    定义、调用接口方法的时候需要多一个参数，并且参数的类型必须和引用实例方法的类型必须一致，把第一个参数作为引用的实例，后面的每个参数全部传递给引用的方法。

```java
interface <函数式接口> {
    <返回值> <方法名>(<类名><名称> [,其它参数...])    
}
<变量名>.<方法名>（<类名的实例>[,其它参数]）
```

eg:
```java
public class TestMethodRef {
    public static void main(String[] args) {
        MethodRef r1 = (s) -> System.out.println(s);
        r1.test("普通方式");

        //使用方法的引用：实例方法的引用
        //System.out是一个实例  out是PrintStream 类型，有println方法
        MethodRef r2 = System.out::println;
        r2.test("方法引用");

        //MethodRef1 r3 =(a)-> Arrays.sort(a);
        //引用类方法
        MethodRef1 r3 = Arrays::sort;
        int[] a = new int[]{4, 12, 23, 1, 3};
        r3.test(a);
        //将排序后的数组输出
        r1.test(Arrays.toString(a));

        //引用类的实例方法
        MethodRef2 r4 = PrintStream::println;
        //第二个之后的参数作为引用方法的参数
        r4.test(System.out, "第二个参数");

        //引用构造器
        MethodRef3 r5 = String::new;
        String test = r5.test(new char[]{'测', '试', '构', '造', '器', '引', '用'});
        System.out.println(test);
        //普通情况
        MethodRef3 r6 = (c) -> {
            return new String(c);
        };
        String test2 = r6.test(new char[]{'测', '试', '构', '造', '器', '引', '用'});
        System.out.println(test2);
    }
}

interface MethodRef {
    void test(String s);
}

interface MethodRef1 {
    void test(int[] arr);
}

interface MethodRef2 {
    void test(PrintStream out, String str);
}

//测试构造器引用
interface MethodRef3 {
    String test(char[] chars);
}

```

## 参考资料

* https://blog.csdn.net/zymx14/article/details/70175746
* https://blog.csdn.net/kegaofei/article/details/80582356
* https://edu.aliyun.com/lesson_1012_9096?spm=5176.10731542.0.0.xGlbkv#_9096
* http://www.importnew.com/27901.html
* http://www.importnew.com/10360.html