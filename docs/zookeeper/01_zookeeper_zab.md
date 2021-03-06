# ZooKeeper 之 Paxos 和 ZAB
------
为了解决分布式一致性问题，在长期的探索研究过程中，涌现出一大批经典的一致性协议和算法，其中最著名的是 2PC 两阶段提交协议、3PC 三阶段提交协议和 Paxos算法。

一致性协议可以有多种分类方法，关键要看我们选取的是哪个观察角度，这里我们从单主和多主的角度对协议进行分类。单主协议，即整个分布式集群中只存在一个主节点，采用这个思想的主要有2PC, Paxos, Raft等. 另一类是多主协议，即整个集群中不只存在一个主节点，Pow协议以及著名的Gossip协议。

单主协议由一个主节点发出数据，传输给其余从节点，能保证数据传输的有序性。而多主协议则是从多个主节点出发传输数据，传输顺序具有随机性，因而数据的有序性无法得到保证，只保证最终数据的一致性。这是单主协议和多主协议之间最大的区别。本篇综述选取单主协议中具有代表性的Paxos, Raft两大协议进行介绍，多主协议则选择经典且应用广泛的Gossip和Pow协议。

这里咱们只介绍单主的情况，如果有童鞋对多主的情况有兴趣，可以参考 [分布式一致性协议概述](https://zhuanlan.zhihu.com/p/130974371) 

## 2PC
------
两阶段提交又称2PC（two-phase commit protocol）,2pc是一个非常经典的**强一致、中心化的原子提交协议**。这里所说的中心化是指协议中有两类节点：一个是中心化协调者节点（coordinator）和N个投票者节点（voter）。

下面进一步描述下具体哪两阶段

**第一阶段：请求/投票阶段**
1. 事务询问
	协调者向所有的投票者发送事务内容，询问是否可以执行事务提交操作，并开始等待各投票者的响应。对应图中步骤  2.Propose。
2. 执行事务
	各投票者节点执行事务操作。对应图中步骤 3.本地事务(uncommit)。
3. 各投票者向协调者反馈询问的响应
	如果投票者成功执行了事务操作，那么就反馈给协调者 YES，标识事务可以提交；否则返回 NO，表示事务不可以执行。对应图中步骤 4.commit_ready。

**第二阶段：提交/执行阶段**
假如协调者从所有的投票者获得的反馈都是 YES 响应，那么就会执行事务提交：
1. 发送提交请求
	协调者向所有的投票者发出 commit 请求。对应图中步骤 5.Commit。
2. 事务提交
	投票者接收到 Commit 请求后，会正式执行事务提交操作，并在完成提交之后释放在整个事务执行期间占用的事务资源。对应图中步骤 6.提交本地事务。
3. 反馈事务提交结果
	投票者在完成事务提交之后，向协调者发送 ACK 消息。对应与图中步骤 7.ACK。
4. 完成事务
	协调者接收到所有参与者反馈的 ACK 消息后，完成事务。

假如协调者从任何一个投票者获得的反馈是 NO 响应；或者在等待超时之后，协调者尚无法接收到所有投票者的反馈响应。那么就会执行事务中断：
1. 发送回滚请求
	协调者向所有的投票者发出 Rollback 请求。对应图中步骤 5.Commit。
2. 事务提交
	投票者接收到 Rollback 请求后，会执行回滚操作，并在完成提交之后释放在整个事务执行期间占用的事务资源。对应图中步骤 6.回滚本地事务。
3. 反馈事务提交结果
	投票者在完成事务回滚之后，向协调者发送 ACK 消息。对应与图中步骤 7.ACK
4. 完成事务
	协调者接收到所有参与者反馈的 ACK 消息后，完成事务

举例说明，例如：在一个分布式架构的系统中事务的发起者通过分布式事务协调者分别向应用服务1(voter1) 、应用服务 2 (voter2) 发起处理请求，二者在处理的过程中会分别操作自身服务的数据库，现在要求应用服务 1、应用服务 2 的数据处理操作要在一个事务里。如果采用 2PC 的方式，如下：

在正常的情况下，应该是这样的
![2PC](https://note.youdao.com/yws/api/personal/file/1F24B86E659B4D979C87903101561079?method=download&shareKey=46f04310fc8d8c76867e65c5eb7ff23f)

在失败的情况下，应该是这样的
![2PC](https://note.youdao.com/yws/api/personal/file/9B25C21E3E0E4735ACECB955DD008B4F?method=download&shareKey=a7c512628c9ce5544587108e7df42b40)

#### 2PC 优缺点
**优点：**
- 原理简单
- 实现方便

**缺点：**
- **同步阻塞**：2PC 提交协议存在的最明显也是最大的问题就是同步阻塞，这会极大的限制分布式系统的性能。在 2PC 执行过程中，所有投票者的逻辑都处于阻塞状态，也就是说，各个投票者在等待其他投票者响应的过程中将无法进行其他任何操作。
- **单点问题**：在 2PC 过程中协调者起到了至关重要的作用，一旦协调者出现问题，整个 2PC 提交过程将无法运作，更为严重的是，如果协调者在 2PC 过程中出现问题的话，那么其他参与者将会一直处于锁定事务资源状态，无法继续完成事务操作。
- **数据不一致**：在 2PC 阶段二，执行事务提交的时候，当协调者向所有投票者发送 commit 请求之后，发生了局部网络或者协调者在尚未发送完 commit 请求之前自身发生了崩溃，导致最终只有部分投票者接收到了 commit 请求。则收到 commit 的投票者提交了事务，没有收到的则不会提交事务，于是整个分布式系统便出现了数据不一致的现象。
- **太过保守**：如果在协调者指示投票者进行事务提交询问的过程中，投票者出现故障而导致协调者始终无法获取到所有投票者的响应信息的话，这是协调者只能依靠其自身的超时机制来判断是否需要中断事务，这样的策略比较保守。换句话说，2PC 没有完善的容错机制，任一个节点失败都导致整个事务的失败。

## 3PC
------
三阶段提交又称3PC，是 2PC 的改进版，将 2PC 提交事务请求一分为儿，增加了CanCommit阶段。

下面进一步描述下具体哪三阶段

**第一阶段：CanCommit**
1. 事务询问
	协调者向所有的参与者发送一个包含事务内容的 canCommit 请求，询问是否可以执行事务提交操作，并开始等待各个投票者的响应。
	
2. 各投票者向协调者反馈事务询问的响应
	各投票者在接收到来自协调者的 canCommit 请求后，正常情况下，如果自身认为可以顺利执行事务，那么会反馈 YES ，并进入预备状态，否则反馈 NO 响应。

**第二阶段：PreCommit**
假如协调者从所有的投票者获得的反馈都是 YES 响应，那么就会执行事务提交：
1. 发送预提交请求
	协调者向所有投票者节点发出 preCommit 的请求，并进入 Prepared 阶段。
2. 事务预提交
	投票者接收到 preCommit 请求后，会执行事务操作。并将 Undo 和 Redo 信息记录到事务日志中。
3. 各投票者向协调者反馈事务执行响应
	如果投票者成功执行了事务操作，那么就会反馈给 ACK 响应，同时等待最终指令。

假如协调者从任何一个投票者获得的反馈是 NO 响应；或者在等待超时之后，协调者尚无法接收到所有投票者的反馈响应。那么就会执行事务中断：
1. 发送中断请求
	协调者向所有投票者发送 abort 请求
2. 中断事务
	无论是收到来自协调者的 abort 请求，或者是在等待协调者请求过程中出现超时，投票者都会中断事务。

**第三阶段：DoCommit**
假如协调者从所有的投票者获得的反馈都是 YES 响应，那么就会执行事务提交：
1. 发送提交请求
	进入这一阶段，假设协调者处于正常工作状态，并且它收到了来自所有投票者的 ACK 响应，那么它将从 ”预提交“ 状态转换到 ”提交“ 状态，并向所有的投票者发送 doCommit 请求。
2. 事务提交
	投票者收到 doCommit 请求后，会正式执行事务提交操作，并在完成提交之后释放在整个事务执行期间占用的事务资源。
3. 反馈事务提交结果
	投票者在完成事务提交之后，向协调者发送 ACK 消息。
4. 完成事务
	协调者接收到所有投票者反馈的 ACK 消息后，完成事务。

假如协调者从任何一个投票者获得的反馈是 NO 响应；或者在等待超时之后，协调者尚无法接收到所有投票者的反馈响应。那么就会执行事务中断：
1. 发送中断请求
	协调者向所有投票者发送 abort 请求
2. 事务回滚
	投票者收到 abort 请求后，会正式执行事务回滚操作，并在完成回滚之后释放在整个事务执行期间占用的事务资源。
3. 反馈事务回滚结果
	投票者在完成事务回滚之后，向协调者发送 ACK 消息。
4. 中断事务
	协调者接收到所有投票者反馈的 ACK 消息后，中断事务。

根据上面的例子，在正常的情况下，应该是这样的
![3PC](https://note.youdao.com/yws/api/personal/file/0CA531305B9048D59D9CE1B03A1D1257?method=download&shareKey=a9cb1946a4820355cbdb64b8cb6af2ba)

在第一阶段失败的情况下，应该是这样的
![3PC](https://note.youdao.com/yws/api/personal/file/AF175B40CF204B5F85B46144A25AA012?method=download&shareKey=21c15dc6d367cfe7fc1281e1d70f11da)

在第二阶段失败（投票者等待协调者通知超时，自动执行中断事务）的情况下，应该是这样的
![3PC](https://note.youdao.com/yws/api/personal/file/4234450D5D98424EAEC7C5308C60CA7E?method=download&shareKey=1c6ae6298052cdf21637f30d7f28b8eb)

#### 3PC 优缺点
**优点：**
- 降低了投票者的阻塞范围，并且能够在出现单点故障后继续达成一致。

**缺点：**

- 3PC可以有效的处理 2PC 单点故障的问题， 但不能处理网络划分 (network partition) 的情况：节点互相不能通信。假设在 PreCommit 阶段所有节点被一分为二，收到 preCommit 消息的 voter 在一边，而没有收到这个消息的在另外一边。在这种情况下，可能会导致数据不一致的情况。如下图：
![3PC](https://note.youdao.com/yws/api/personal/file/1B8791A01DC842609F35B808DCDFC5CB?method=download&shareKey=90cb260de69e0d67b897fa8a95d8e8fc)
- 3PC 也不能处理 fail-recover 的错误情况。 简单说来当 coordinator 收到 preCommit 的确认前 crash, 于是其他某一个 voter 接替了原 coordinator 的任务而开始组织所有 voter commit。 而与此同时原 coordinator 重启后又回到了网络中，开始继续之前的回合：发送abort给各位 voter 因为它并没有收到 preCommit 。 此时有可能会出现原 coordinator 和继任的 coordinator 给不同节点发送相矛盾的 commit 和 abort 指令。 从而出现个节点的状态分歧。



## Paxos 算法
------
https://www.cnblogs.com/zhang-qc/p/8688258.html


##  ZAB 协议
------



## 面试题总结
------
### 请简答介绍下 Paxos 算法和 ZAB 协议




## 参考
------
- [分布式一致性协议概述](https://zhuanlan.zhihu.com/p/130974371)
- [Consensus Protocols: Two-Phase Commit - Paper Trail](https://www.the-paper-trail.org/post/2008-11-27-consensus-protocols-two-phase-commit/)
- [Consensus Protocols: Three-phase Commit - Paper Trail](https://www.the-paper-trail.org/post/2008-11-29-consensus-protocols-three-phase-commit/)
- [分布式事务之深入理解什么是2PC、3PC及TCC协议](https://cloud.tencent.com/developer/article/1477464)
- [漫话分布式系统共识协议: Paxos篇](https://zhuanlan.zhihu.com/p/35737689)
- [漫话分布式系统共识协议: 2PC/3PC篇](https://zhuanlan.zhihu.com/p/35298019)
- 《从 Paxos 到 ZooKeeper》

