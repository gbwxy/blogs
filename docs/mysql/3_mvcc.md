# MVCC 多版本并发控制
MVCC，全称 Multi-Version Concurrency Control，即多版本并发控制。MVCC 是一种并发控制的方法，一般在数据库管理系统中，实现对数据库的并发访问，在编程语言中实现事务内存。

https://zhuanlan.zhihu.com/p/340600156
https://www.jianshu.com/p/8845ddca3b23


## Read View(读视图)
事务进行快照读操作的时候生产的读视图(Read View)，在该事务执行的快照读的那一刻，会生成数据库系统当前的一个快照

## 问题：
1. RC 的 MVCC 为啥依然不能解决不可重复读？RR 的 MVCC 为啥能解决？
2. MVCC 是什么
3. MVCC 能解决什么问题，好处是？
4. MVCC 的原理

