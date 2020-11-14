# ZooKeeper 之基本概念与使用

小猿接下来就要介绍 Zookeeper 的使用，各位童鞋要仔细阅读哦，小猿接下来的文章中的例子都是以 r3.5.8 这个版本的 Zookeeper 来的，各位童鞋可以在自己的项目中添加依赖，小猿以 gradle 作为列子，需要添加如下依赖

```
compile group: 'org.apache.zookeeper', name: 'zookeeper', version: '3.5.8'
compile group: 'org.apache.curator', name: 'curator-framework', version: '2.12.0'
compile group: 'org.apache.curator', name: 'curator-recipes', version: '2.12.0'
compile group: 'org.apache.curator', name: 'curator-test', version: '2.12.0'
```






### 节点类型
Zookeeper 中，每个数据节点都是有生命周期的，其生命周期的长短取决于数据节点的节点类型。Zookeeper 中数据节点的类型以下几种：

| CreateMode                     | 描述                                                         |
| ------------------------------ | ------------------------------------------------------------ |
| PERSISTENT                     | 持久节点，该类型的数据节点被创建后，会一直存在与 Zookeeper 服务器上，直到有删除操作来主动清除这个节点。 |
| PERSISTENT_SEQUENTIAL          | 持久顺序节点，基本特性与持久节点一致，额外的特性是有顺序性。<br>在 Zookeeper 中，每个父节点都会为它的第一级子节点维护一份顺序，用于记录每个子节点创建的先后顺序。<br>在创建该类型节点的子节点的时候，Zookeeper 会自动为给定节点名加上一个数字后缀，作为一个新的、完整的节点名。<br>**注意：这个数字后缀的上限是整型的最大值。** |
| EPHEMERAL                      | 临时节点，临时节点的生命周期和客户端的会话绑定在一起，即如果客户端会话失效，该类型的数据节点会被自动清理掉。<br>这里提到的客户端会话失效，并不是 TCP 连接断开。<br>另外，Zookeeper 规定了不能基于临时节点来创建子节点，即临时节点只能作为叶子节点。 |
| EPHEMERAL_SEQUENTIAL           | 临时顺序节点，基本特性和临时节点一致，额外的特性是有顺序性，与持久顺序节点的顺序特性一致。 |
| CONTAINER                      | 容器节点，容器节点是特殊用途的节点，可用于诸如 leader、lock等等。删除容器的最后一个子节点后，该容器将变为服务器将来要删除的候选对象。<br>所以，当对该类型的节点创建子节点的时候，需要捕获 KeeperException.NoNodeException 类型的异常，以防止该节点已经被服务器删除。 |
| PERSISTENT_WITH_TTL            | 具有过期时间的持久节点，该类型的数据节点创建后会一直存在，但是有一种情况除外：如果在给定的 TTL 时间内，并对该节点进行修改，并且该节点没有子节点，则将其删除。 |
| PERSISTENT_SEQUENTIAL_WITH_TTL | 具有过期时间的持久顺序节点，该类型节点具有持久性、顺序性和 TTL 过期删除的特性。 |



- 持久节点  PERSISTENT
  - 数据节点被创建后，一直存在zookeeper服务器上，直到有删除操作主动清除
- 持久顺序节点  PERSISTENT_SEQUENTIAL
  - 每个父节点会为它的第一级子节点维护一份顺序，用于记录每个子节点创建的先后顺序
  - 创建节点的时候，自动给节点名加上一个数字后缀，作为一个新的节点名
  - 这个数字后缀上限是整型的最大值
- 临时节点  EPHEMERAL
  - 客户端失效，节点会被自动清理
  - 临时节点不能创建子节点，临时节点只能作为叶子子节点
- 临时顺序节点   EPHEMERAL_SEQUENTIAL


###  状态信息 stat



###  数据节点版本
- 分别标识对数据节点的数据内容、子节点列表、节点ACL信息的修改次数
- 在一个数据节点/zk-book 被创建完毕之后，节点的version值为0，表示含义是“当前节点自从创建之后，被更新过0次”；如果修改该节点的数据内容，则version++
- 对数据节点数据内容的变更次数，强调的是变更次数，如果变更前后数据一样，version依然会变更
- zookeeper通过version来实现乐观锁（CAS）
