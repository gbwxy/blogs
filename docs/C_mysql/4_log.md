[TOC]

# MySQL 日志总结

![](https://note.youdao.com/yws/api/personal/file/0C031BD87D4A435E80A6E67BE87C125E?method=download&shareKey=4e3475d22c24a2bdfc6bab10e04fd112)

|          | bin log                           | undo log                                                     | redo log                                               |
| -------- | --------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------ |
| 日志名称 | 二进制日志/归档日志               | 回滚日志                                                     | 重做日志/重写日志                                      |
| 作用     | - 主从复制<br/>- 基于时间点的还原 | - 保存数据的多个版本<br/>- 可以用于回滚<br/>- 可以提供多版本并发控制(MVCC)下的非锁定读 | - 确保事务的持久性。<br/>- 确保MySQL故障重启后的持久性 |
| 操作位置 | server层，所有引擎共享            | engine层，Innodb独有                                         | engine层，Innodb独有                                   |
| 文件大小 | 可通过max_binlog_ize设置文件大小  | ？                                                           | redo log大小是固定的                                   |
| 记录方式 | 通过追加方式进行记录              | ？                                                           | 通过循环写方式进行记录，写到末尾又从开头接着写         |

- Undo log ：如果事务执行失败要回滚数据，用到 undo log 里的数据；恢复的是 buffer pool 里缓存的数据
- Redo log ：如果事务提交成功了，buffer pool 中的数据还没来得及写入磁盘，这时候 MySQL 宕机了，可以用 redo log 中的日志恢复 buffer pool 中的数据
- bin log ：主要用来恢复数据库磁盘里的数据

## binlog

- binlog 用于记录数据库执行的写入性操作(不包括查询)信息，以二进制的形式保存在磁盘中。 
- binlog 是 mysql 的逻辑日志，并且由 Server 层进行记录，使用任何存储引擎的 mysql 数据库都会记录 binlog 日志。
- binlog 是通过追加的方式进行写入的，可以通过 max_binlog_size 参数设置每个 binlog 文件的大小，当文件大小达到给定值之后，会生成新的文件来保存日志。
### binlog使用场景

在实际应用中， binlog 的主要使用场景有两个，分别是**主从复制**和**数据恢复**。
- 主从复制 ：在 Master 端开启 binlog ，然后将 binlog 发送到各个 Slave 端， Slave 端重放 binlog 从而达到主从数据一致。
- 数据恢复 ：通过使用 mysqlbinlog 工具来恢复数据
### binlog日志格式

binlog 日志有三种格式，分别为 **STATMENT 、 ROW 和 MIXED **。
- STATMENT ： 基于 SQL 语句的复制( statement-based replication, SBR )，每一条会修改数据的sql语句会记录到 binlog 中 。
    - 优点： 不需要记录每一行的变化，减少了` binlog ` 日志量，节约了 ` IO ` , 从而提高了性能； 
    - 缺点： 在某些情况下会导致主从数据不一致，比如执行` sysdate() ` 、 ` slepp() ` 等 。 
- ROW ： 基于行的复制( row-based replication, RBR )，不记录每条sql语句的上下文信息，仅需记录哪条数据被修改了 。
    - 优点： 不会出现某些特定情况下的存储过程、或function、或trigger的调用和触发无法被正确复制的问题
    - 缺点： 会产生大量的日志，尤其是 alter table 的时候会让日志暴涨
- MIXED ： 基于 STATMENT 和 ROW 两种模式的混合复制( mixed-based replication, MBR )，一般的复制使用 STATEMENT 模式保存 binlog ，对于 STATEMENT 模式无法复制的操作使用 ROW 模式保存 binlog



# 参考

- https://segmentfault.com/a/1190000023827696
- https://zhuanlan.zhihu.com/p/341376691

