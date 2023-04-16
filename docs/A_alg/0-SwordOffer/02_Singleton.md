## 面试题2：实现 Singleton 模式
### 单例模式的特点
- 构造方法私有化；
- 实例化的变量引用私有化；
- 获取实例的方法共有。

### 双重校验模式
```java
/**
 * 双重检验锁模式-线程安全
 */
public class A_02_Singleton {
    //volatile可以使instance变量不会在多线程中存在副本，直接从内存中读
    private volatile static A_02_Singleton INSTANCE;
    //即：volatile的赋值操作后面会有个“内存屏障”，防止读操作被JVM重排序到内存屏障之前。
    private A_02_Singleton() {
    }
    public static A_02_Singleton getInstance() {
        if (INSTANCE == null) {
            synchronized (A_02_Singleton.class) {
                if (INSTANCE == null) {
                    return new A_02_Singleton();
                }
            }
        }
        return INSTANCE;
    }
}
```

### 枚举模式

```java
public enum  EnumSingleton {
    INSTANCE;
    public void doSomething() {
        System.out.println("doSomething");
    }
}
```
调用方法：
```java
public class Main {
    public static void main(String[] args) {
        Singleton.INSTANCE.doSomething();
    }
}
```

### 枚举类型为什么是线程安全的，为什么可以用枚举实现单例
我们定义的一个枚举，在第一次被真正用到的时候，会被虚拟机加载并初始化，而这个初始化过程是线程安全的。而我们知道，解决单例的并发问题，主要解决的就是初始化过程中的线程安全问题。
所以，由于枚举的以上特性，枚举实现的单例是天生线程安全的。

### 破坏单例模式的方法及解决办法
1、除枚举方式外, 其他方法都会通过反射的方式破坏单例,反射是通过调用构造方法生成新的对象，所以如果我们想要阻止单例破坏，可以在构造方法中进行判断，若已有实例, 则阻止生成新的实例，解决办法如下:
```java
private SingletonObject1(){
    if (instance !=null){
        throw new RuntimeException("实例已经存在，请通过 getInstance()方法获取");
    }
}
```
2、如果单例类实现了序列化接口Serializable, 就可以通过反序列化破坏单例，所以我们可以不实现序列化接口,如果非得实现序列化接口，可以重写反序列化方法readResolve(), 反序列化时直接返回相关单例对象。
```java
public Object readResolve() throws ObjectStreamException {
        return instance;
}
```

### 参考
https://www.jianshu.com/p/d9d9dcf23359





