## 1. Java 内存泄露
 - static字段引起的内存泄露：静态集合类，如HashMap、LinkedList等等。如果这些容器为静态的，那么它们的生命周期与程序一致，则容器中的对象在程序结束之前将不能被释放，从而造成内存泄漏。简单而言，长生命周期的对象持有短生命周期对象的引用，尽管短生命周期的对象不再使用，但是因为长生命周期对象持有它的引用而导致不能被回收。
 - 未关闭的资源导致内存泄露：比如数据库连接（dataSourse.getConnection()），网络连接(socket)和io连接，除非其显式的调用了其close（）方法将其连接关闭，否则是不会自动被GC 回收的。
 - 当集合里面的对象属性被修改后，再调用remove()方法时不起作用。
```java
public static void main(String[] args)
{
    Set<Person> set = new HashSet<Person>();
    Person p1 = new Person( "唐僧" , "pwd1" , 25 );
    Person p2 = new Person( "孙悟空" , "pwd2" , 26 );
    Person p3 = new Person( "猪八戒" , "pwd3" , 27 );
    set.add(p1);
    set.add(p2);
    set.add(p3);
    //结果：总共有:3 个元素!
    System.out.println( "总共有:" +set.size()+ " 个元素!" ); 
    p3.setAge( 2 ); //修改p3的年龄,此时p3元素对应的hashcode值发生改变
    set.remove(p3); //此时remove不掉，造成内存泄漏
    set.add(p3); //重新添加，居然添加成功
    //结果：总共有:4 个元素!
    System.out.println( "总共有:" +set.size()+ " 个元素!" ); 
    for (Person person : set)
    {
    	System.out.println(person);
    }
}
```
 - 队列或栈，从队列或栈中取出元素的时候，没有对取出的元素做置null 操作
```java
public class Stack {
    private Object[] elements;
    private int size = 0;
    private static final int DEFAULT_INITIAL_CAPACITY = 16;

    public Stack() {
        elements = new Object[DEFAULT_INITIAL_CAPACITY];
    }

    public void push(Object e) {
        ensureCapacity();
        elements[size++] = e;
    }

    public Object pop() {
        if (size == 0)
            throw new EmptyStackException();
        return elements[--size];
    }

    private void ensureCapacity() {
        if (elements.length == size)
            elements = Arrays.copyOf(elements, 2 * size + 1);
    }
}
```
pop 方法有问题。正确应该是
```java
public Object pop() {
    if (size == 0)
    throw new EmptyStackException();
    Object result = elements[--size];
    elements[size] = null;
    return result;
}
```
 - 常量字符串造成的内存泄露：如果我们读取一个很大的String对象，并调用了inter(），那么它将放到字符串池中，位于PermGen中，只要应用程序运行，该字符串就会保留，这就会占用内存，可能造成OOM。
 - 使用ThreadLocal造成内存泄露：ThreadLocals没有显示的删除时，就会一直保留在内存中，不会被垃圾回收。 
## 2. 反射机制的底层实现是什么？动态呢？动态的实现原理？

## 3. java类加载器的工作机制？类加载在那个区域进行的
类加载的流程：类加载、连接、初始化
![](https://note.youdao.com/yws/api/personal/file/1346A1F9233F4BD88FA242FA0DA4CA3A?method=download&shareKey=f3845e50d25437335b32984e19d50bdc)
如果一个类收到了类加载的请求，不会自己先尝试加载，先找父类加载器去完成。当顶层启动类加载器表示无法加载这个类的时候，子类才会尝试自己去加载。当回到最开的发起者加载器还无法加载时，并不会向下找，而是抛出ClassNotFound异常。（如果类A中引用了类B，Java虚拟机将使用加载类A的类加载器来加载类B）
![](https://note.youdao.com/yws/api/personal/file/985D6F089D0D4527BCE0A7A9B5C06FE6?method=download&shareKey=8e57cf4018a3f655216835e550d5df93)

## 4. 数据库
### 数据库的索引有哪几种？
索引列的个数：单列索引和复合索引
按照索引列值的唯一性，索引可分为唯一索引和非唯一索引
聚集索引和非聚集索引：
 - 聚集索引一个表只能有一个，而非聚集索引一个表可以存在多个
 - 聚集索引存储记录是物理上连续存在，而非聚集索引是逻辑上的连续，物理存储并不连续
![](https://note.youdao.com/yws/api/personal/file/F0FEA05D1C854C4D838147A4E457740C?method=download&shareKey=e7964fbadb23db69da99c853a70b26ca)

### 组合索引和几个单个的索引有什么区别？
(1)联合索引本质：
当创建(a,b,c)联合索引时，相当于创建了(a)单列索引，(a,b)联合索引以及(a,b,c)联合索引
想要索引生效的话,只能使用 a和a,b和a,b,c三种组合；当然，我们上面测试过，a,c组合也可以，但实际上只用到了a的索引，c并没有用到！
(2)多列索引：----不建议使用
多个单列索引在多条件查询时只会生效第一个索引！所以多条件联合查询时最好建联合索引！

### 为什么要用B+树来做索引？
- 更少的IO次数**：B+树的非叶节点只包含键，而不包含真实数据，因此每个节点存储的记录个数比B数多很多（即阶m更大），因此**B+树的高度更低**，访问时所需要的IO次数更少。此外，由于每个节点存储的记录数更多，所以对访问局部性原理的利用更好，缓存命中率更高。
- **更适于范围查询**：在B树中进行范围查询时，首先找到要查找的下限，然后对B树进行中序遍历，直到找到查找的上限；而B+树的范围查询，只需要对链表进行遍历即可。（B+树通过链表把叶子节点连接起来）
- **更稳定的查询效率**：B树的查询时间复杂度在1到树高之间(分别对应记录在根节点和叶节点)，而B+树的查询复杂度则稳定为树高，因为所有数据都在叶节点。


### 数据库的大表查询优化了解吗？
- 建立索引
- 分区（MySQL,如按时间分区）
- 尽量使用固定长度字段和限制字段长度。
- 减少比较次数，限制返回条目数

#### 分区

https://blog.csdn.net/xiaocai9999/article/details/79782782

https://www.zhihu.com/question/19719997/answer/574410444

![](https://note.youdao.com/yws/api/personal/file/D63313EA38DD475A96096B47A253A7F8?method=download&shareKey=0fc45c1087ea8f0977e84a8145f3d29f)


### mysql慢语句调优做过吗？说说你是怎么做的？
explain 


### MVCC机制了解不？MVCC机制有什么问题？怎么去解决这个问题？


## 5. 分布式锁：基于zookeeper实现和redis实现在性能上有什么差异？
## 6. spring中Bean的作用域，springMVC的controller是线程安全的吗？怎么去保证线程安全呢？
## 7. String，StringBuffer，StringBuilder的区别，为什么String是不可变的，StringBuffer和StringBuilder哪个是线程安全的，他们分别适用于什么场景。
## 8. 并发包了解吗？假如几个线程之间相互等待，可以用哪个并发类来实现，他的原理是什么？
## 9. kafka如何保证不丢消息又不会重复消费
## 10. hashmap了解吗？他的set和get的时间复杂度是多少？为什么是O(1),说下详细过程，hashmap是线程安全的吗？
## 11. Jvm了解吗？jvm中哪些可以作为垃圾回收的gcroot?为什么呢？
