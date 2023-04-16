# ZooKeeper 原理与实战

小猿最近工作中要用到ZooKeeper来实现分布式协调相关的功能，所以小猿利用碎片时间较为系统的学习了下，于是就总结了下知识点和学习过程中遇到的问题。

在这里你将学习到什么：

* [Zookeeper](./docs/zookeeper/)
* [ZooKeeper-是什么](./docs/zookeeper/01_zookeeper_what.md)
  * 从 ACID 到 CAP/BASE
  * ZooKeeper 的由来
  * ZooKeeper 概览
  * 面试题总结
* [ZooKeeper  之 Paxos 算法和 ZAB 协议 ](./docs/zookeeper/01_zookeeper_zab.md)
* [ZooKeeper 之基本概念与使用](./docs/zookeeper/02_zookeeper_use.md)
* [ZooKeeper 之 Watcher](./docs/zookeeper/06_zookeeper_watcher.md)
* [ZooKeeper 之 ACL](./docs/zookeeper/06_zookeeper_acl.md)
* [ZooKeeper 之客户端 API 的使用](./docs/zookeeper/03_zookeeper_client.md)
* [ZooKeeper 之 Curator](./docs/zookeeper/04_zookeeper_curator.md)
* [ZooKeeper 之使用场景总结](./docs/zookeeper/05_zookeeper_scenes.md)
* [ZooKeeper 之 Leader 选举](./docs/zookeeper/06_zookeeper_leader.md)
* [ZooKeeper 之数据同步](./docs/zookeeper/06_zookeeper_data.md)
* [ZooKeeper 之 Session](./docs/zookeeper/06_zookeeper_session.md)
* [ZooKeeper 之其他核心知识点](./docs/zookeeper/06_zookeeper_core.md)

咱们可以带着常见的一些问题去学习上面的内容，并且在上面的内容中可以找到下列问题的答案。

1. ZooKeeper 是什么？解决了什么问题？
2. 请简单介绍下ACID、CAP和BASE
3. ZooKeeper 提供了什么，有什么？
4. Paxos 和 ZAB 协议
   - 什么是 ZAB 协议？
   - ZAB 和 Paxos 算法的联系与区别？	
5. Zookeeper 文件系统
6. Zookeeper 数据节点的类型
7. Zookeeper Watcher 机制
   - 哪些操作可以注册Watcher 机制？
   - 哪些操作触发监听？
   - 客户端注册 Watcher 如何实现的？
   - 服务端处理 Watcher 如何实现的？
8. Zookeeper ACL 权限控制机制
   - 有哪些权限？
   - 超级权限怎么设置？
9. Zookeeper Chroot 特性是什么？
10. Zookeeper 的会话管理
11. Zookeeper 的服务器角色有哪些？
12. Zookeeper 下 Server工作状态有哪些？
13. Zookeeper 的 Leader  的选举过程
14. Zookeeper 的数据同步
15. Zookeeper 是如何保证事务的顺序一致性的？
16. ZooKeeper 节点宕机如何处理？
17. ZooKeeper 负载均衡和 Nginx 负载均衡有什么区别？
18. Zookeeper 有哪几种几种部署模式？
19. Zookeeper 集群最少要几台机器，集群规则是怎样的? 支持动态扩展吗，为什么？
20. Chubby 是什么，和 Zookeeper 比你怎么看？
21. Zookeeper 的典型应用场景有哪些，你是用过哪些，怎么用的？