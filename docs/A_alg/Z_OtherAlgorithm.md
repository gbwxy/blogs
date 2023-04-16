# 资源限制技巧汇总

- 布隆过滤器用于集合的建立与查询，并可以节省大量空间
- 一致性哈希解决数据服务器的负载管理问题
- 利用并查集结构做岛问题的并行计算
- 哈希函数可以把数据按照种类均匀分流
- 位图解决某一范围上数字的出现情况，并可以节省大量空间
- 利用分段统计思想，进一步节省大量空间
- 利用堆、外排序来做出出力单元的结果合并

# 布隆过滤器 Bloom Filter

- 本质上布隆过滤器是一种数据结构，比较巧妙的概率型数据结构（probabilistic data structure），特点是高效地插入和查询，可以用来告诉你 “某样东西一定不存在或者可能存在”。
- 布隆过滤器是一个 bit 向量或者说 bit 数组
  ![img.png](../../../../../../resources/image/algoruthm/BoolmFilter-1.png)
- 使用多个不同的哈希函数生成多个哈希值，并对每个生成的哈希值指向的 bit 位置 1，例如针对值 “baidu” 和三个不同的哈希函数分别生成了哈希值 1、4、7，则上图转变为
  ![img.png](../../../../../../resources/image/algoruthm/BoolmFilter-2.png)
- 传统的布隆过滤器并不支持删除操作。但是名为 [Counting Bloom filter](https://cloud.tencent.com/developer/article/1136056)
  的变种可以用来测试元素计数个数是否绝对小于某个阈值，它支持元素删除。
- p 表示误报率，m 标识布隆过滤器的bit数组大小，k 标识需要使用的hash函数个数，n 标识总样本数
- 根据 p 和 n 确定 bit 数组大小 m
- 根据 m 和 n 确定hash函数个数 k
  ![img.png](../../../../../../resources/image/algoruthm/BoolmFilter-3.png)
- 根据 m、n、k 确定实际的误报率 p
  ![img.png](../../../../../../resources/image/algoruthm/BoolmFilter-4.png)

## 参考

- [详解布隆过滤器的原理](https://zhuanlan.zhihu.com/p/43263751)
- [Bloom filter](https://hackernoon.com/probabilistic-data-structures-bloom-filter-5374112a7832)

# 一致性哈希

- 一致性哈希算法解决的问题是：解决了分布式系统在扩容或者缩容时，全量或过多的数据迁移的问题
- 哈希环，假设环上有 2^32 - 1 个点（也可以是其他的值，例如就是使用的hash函数生成串的最大值），分别对
- 虚拟节点提高均衡性
- 虚拟节点控制负载

## 参考

- [5分钟理解一致性哈希算法](https://juejin.cn/post/6844903750860013576)