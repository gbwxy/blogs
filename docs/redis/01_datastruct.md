# Redis 5种基础数据结构

Redis 的数据结构都以唯一 Key 字符串作为名称，然后通过这个唯一 Key 值来获取响应的 value 数据。不同类型的数据结构的差异就在 value 的结构

Redis 有5种基础数据结构，string、list、hash、set、zset

## 字符串 string
字符串 string 是 Redis 最简单的数据结构，它内部标识是一个字符数组。Redis 的字符串是动态字符串，是可以修改的字符串，内部结构实现类似于 Java 的 ArrayList，采用预分配冗余空间的方式来减少内存的频繁分配。当字符串长度小于 1 MB 的时候，扩容都是加倍现有的空间；当字符串长度超过 1 MB，扩容时一次只会多扩 1 MB 的空间。string 类型最大长度是 512 MB。

![](https://note.youdao.com/yws/api/personal/file/63980F8F9EC34565A42539F99794ED3D?method=download&shareKey=03bab7d4feef5d19d60af4b7b6697725)

如图，内部为当前字符串分配的实际空间 capacity 一般要高于实际字符串长度 len。

字符串结构是使用非常广泛、最常见的数据结构。一个典型的使用场景就是缓存用户信息，我们将用户信息结构体使用 JSON 序列化成字符串，然后将序列化后的字符串塞进 Redis 来缓存。同样，取用户信息的时候回经过一次反序列化的过程。

## 列表 list
Redis 的列表相当于 Java 语言中的 LinkedList，注意它是链表而不是数组。这意味着 list 的插入和删除操作非常快，时间复杂度 O(1)，但是索引定位很慢，时间复杂度 O(n)。当列表弹出最后一个元素之后，该数据结构被自动删除，内存被回收。

![](https://note.youdao.com/yws/api/personal/file/E0AE5E8B7B604F34A040970CF5DF36C3?method=download&shareKey=33d05582394f580335490dfe7a8a66bf)

如图所示，List 的结构是一个双向链表。

Redis 的列表结构常用来做异步队列使用。将需要延后处理的任务结构体序列化成字符串，塞进 Redis 的列表，另一个线程从这个列表中轮询数据进行处理。


## 字典 hash
Redis 的字典相当于 Java 语言里面的 HashMap，它是无序字典，内部存储了很多键值对。实际结构与 Java 的 HashMap 也是一样的，都是**数组+链表**二维结构。第一维 hash 的数组位置碰撞时，就会将碰撞的元素使用链表串联起来，如下图所示：
![](https://note.youdao.com/yws/api/personal/file/0F6E645E36DF4EF69740077359E49427?method=download&shareKey=fe99077c5cf255f13280cd14c09de3e3)

与 Java 的 HashMap 不同的是，Redis 的字典的值只能是字符串，另外它们 rehash 方式不一样。Java 的 HashMap 在字典很大时，rehash 是耗时的操作，需要一次全部rehash；而 Redis 为了追求高性能，不能阻塞服务，所以采用了渐进式 rehash 策略。

渐进式 rehash 会在 rehash 的同时，保留新旧两个 hash 结构，查询时会同时查询两个 hash 结构，然后在后续的定时任务以及 hash 操作指令中，循序渐进地将旧 hash 的内容一点点地迁移到新的 hash 结构中，当搬迁完成后，就会使用新的 hash 结构取而代之。

当 hash 移除了最后一个元素之后，该数据结构被自动删除，内存被回收。

hash 结构也可以用来存储用户信息，与字符串需要一次性全部序列化整个对象不同，hash 可以对用户结构中的每个字段单独存储。这样我们就能获取用户的部分信息；而以整个字符串的形式保存用户信息的话，就只能一次性全部读取，这样就浪费网络流量。

hash 也有缺点，hash 结构的存储消耗高于单个字符串。

## 集合 set
Redis 的 set 相当于 Java 中的 HashSet，它内部的键值对是无序的、唯一的。它的内部实现相当于一个特殊的字典，字典中所有的 value 都是 NULL.

当集合中最后一个元素被移除之后，数据结构被自动删除，内存被回收。

set 结构可以用来存储在某个活动中，中奖用户 ID，因为有去重功能，可以保证同一个用户不会中奖两次。


## 有序集合 zset
zset 可能是 Redis 提供的最有特色的数据结构，它也是面试中最喜欢问的数据结构。它类似于 Java中的 HashMap 和 SortedSet 的合体，一方面它是一个 set，保证内部 value 的唯一性，另一方面它可以给每个 value 赋予一个 score，代表这个 value 的排序权重。它的内部实现是“跳跃列表”。

zset 中最后一个 value 被移除后，数据结构被自动删除，内存被回收。

zset 可以用来存储粉丝列表， value 值是粉丝的用户 ID，score 是关注时间，我们可以按照关注时间对粉丝进行排序。
zset 还可以用来存储学生的成绩，value 是学生 ID，score 是考试成绩，按照考试成绩对其进行排序。


## 注意
list、set、hash、zset 这四种数据结构似乎肉鳍类型数据结构，它们共享下面两条通用规则
- create if not exists ：如果容器不存在，就创建一个再进行操作。
- drop if no element：如果容器里的元素没有了，就自动删除容器，释放内存。

过期时间：
Redis 所有的数据结构都可以设置过期时间，时间到了，Redis 会自动删除响应的对象。需要注意的是，过期是**以对象为维度的**。还有一个注意的地方，**如果一个字符串已经设置了过期时间，然后再调用 set 修改，则过期时间失效。**

## 参考
《Redis 深度历险：核心原理与应用实践》
