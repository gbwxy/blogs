# ZooKeeper知识总结

小猿最近工作中要用到ZooKeeper来实现分布式协调相关的功能，所以小猿利用碎片时间较为系统的学习了下，于是就总结了下知识点和学习过程中遇到的问题。

在这里你将学习到什么：

- [ZooKeeper-是什么](./docs/zookeeper/01_zookeeper_what.md)
- [ZooKeeper-使用](./docs/zookeeper/02_zookeeper_use.md)
- [ZooKeeper-客户端api使用](./docs/zookeeper/03_zookeeper_client.md)
- [ZooKeeper-Curator](./docs/zookeeper/04_zookeeper_curator.md)
- [ZooKeeper-使用场景总结](./docs/zookeeper/05_zookeeper_scenes.md)
- [ZooKeeper-核心知识点](./docs/zookeeper/06_zookeeper_core.md)

咱们可以带着常见的一些问题去学习上面的内容：

1. ZooKeeper 是什么？
2. ZooKeeper 提供了什么？
3. Paxos 和 ZAB 协议
   - 什么是 ZAB 协议？
   - ZAB 和 Paxos 算法的联系与区别？	
4. Zookeeper 文件系统
5. Zookeeper 数据节点的类型
6. Zookeeper Watcher 机制
   - 哪些操作可以注册Watcher 机制？
   - 哪些操作触发监听？
   - 客户端注册 Watcher 如何实现的？
   - 服务端处理 Watcher 如何实现的？
7. Zookeeper ACL 权限控制机制
   - 有哪些权限？
   - 超级权限怎么设置？
8. Zookeeper Chroot 特性是什么？
9. Zookeeper 的会话管理
10. Zookeeper 的服务器角色有哪些？
11. Zookeeper 下 Server工作状态有哪些？
12. Zookeeper 的 Leader  的选举过程
13. Zookeeper 的数据同步
14. Zookeeper 是如何保证事务的顺序一致性的？
15. ZooKeeper 节点宕机如何处理？
16. ZooKeeper 负载均衡和 Nginx 负载均衡有什么区别？
17. Zookeeper 有哪几种几种部署模式？
18. Zookeeper 集群最少要几台机器，集群规则是怎样的? 支持动态扩展吗，为什么？
19. Chubby 是什么，和 Zookeeper 比你怎么看？
20. Zookeeper 的典型应用场景有哪些，你是用过哪些，怎么用的？