# Abstract Queued Synchronizer AQS

## 定义

Abstract Queued Synchronizer (AQS) 是一个抽象同步框架，可以用来实现一个依赖状态的同步器。Java中提供的大多数的同步器如 Lock, Latch, Barrier等，都是基于 AQS 框架来实现的。

- 一般是通过一个内部类 Sync 继承 AQS
- 将同步器所有调用都映射到Sync对应的方法

## AQS 特性

- AQS 定义两种资源共享方式
    - Exclusive-独占，只有一个线程能执行，如ReentrantLock
    - Share-共享，多个线程可以同时执行，如Semaphore/CountDownLatch
- AQS 维护属性 state 表示资源的可用状态（volatile int state）
    - getState() 获取资源状态
    - setState() / compareAndSetState() 设置状态
- AQS 定义两种队列
  ![img.png](../../../../resources/image/concurrency/AQS同步队列&条件队列.png)
    - 同步等待队列： 主要用于维护获取锁失败时入队的线程。它一种基于双向链表数据结构的队列，是FIFO先进先出线程等待队列
        - 当前线程获取同步状态失败时，AQS则会将当前线程信息构造成一个节点（Node）并将其加入到同步队列，同时会阻塞当前线程
        - 当同步状态释放时，会把首节点唤醒，使其再次尝试获取同步状态。
        - 通过 signal 或 signalAll 将条件队列中的节点转移到同步队列。
    - 条件等待队列： 调用 await() 的时候会释放锁，然后线程会加入到条件队列，调用 signal() 唤醒的时候会把条件队列中的线程节点移动到同步队列中，等待再次获得锁

- AQS 可以实现公平或非公平
- AQS 具备可重入性
- AQS 允许中断

# ReentrantLock
