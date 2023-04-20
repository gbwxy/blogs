# 目标

JVM 调优的目的主要是降低 FullGC 对系统的影响，减少 FullGC 次数，降低 FullGC 时间

# 步骤

- 首先要确定运行程序的 JVM 内存模型各部分的使用情况 >> jstat gc pid 10000 1000
    - 堆(Eden、Survivor0、Survivor1、Old)、方法区、线程栈、本地方法栈的总大小
    - YoungGC 的触发频率和每次耗时：我们大概就能知道系统大概多久会因为 YoungGC的执行而卡顿多久
    - 年轻代对象增长的速率：通过观察EU(eden区的使用)来估算每秒eden大概新增多少对象，如果系统负载不高，可以把频率1秒换成1分钟，甚至10分钟来观察整体情况。
        - 也可以这么算：每秒产生对象大概占多大 = eden 大小 / youngGC 频率(多长时间执行一次youngGC)
    - 每次Young GC后有多少对象存活和进入老年代：jstat -gc pid 300000 10 观察每次结果eden， survivor和老年代使用的变化情况，以推算出老年代对象增长速率
    - Full GC的触发频率和每次耗时 ‐XX:CMSInitiatingOccupancyFraction=75 ‐XX:+UseCMSInitiatingOccupancyOnly

![img.png](../../../../resources/image/jvm/GCTuning-01.png)

- 结合对象挪动到老年代那些规则，判断为什么会发生 FullGC，并推断出程序可能会出现的问题

## 对象挪动到老年代的规则

- 对象头中的分代年龄 > 设置的进入老年代的年龄 -XX:MaxTenuringThreshold（一般是缓存对象才会一直存活）
- 大对象直接进入老年代 -XX:PretenureSizeThreshold
- 对象动态年龄判断机制：
    - 一批对象的总大小大于Survivor区域内存大小的50%(-XX:TargetSurvivorRatio可以指定)，那么此时大于等于这批对象年龄最大值的对象，就可以直接进入老年代
    - youngGC 时，如果存活内存大小大于 Survivor区域内存大小的50%(-XX:TargetSurvivorRatio可以指定) ，直接进入老年代

## Full GC的原因(前三种可能导致 FullGC 比 youngGC 次数多)

- 元空间不够导致的多余 fullGC
- 显示调用System.gc()造成多余的full gc，这种一般线上尽量通过XX:+DisableExplicitGC参数禁用，如果加上了这个JVM启动参数，那么代码中调用System.gc()没有任何效果
- 老年代空间分配担保机制
- Old 空间不够用

# 解决 OOM 的问题

# 解决死锁的问题

# 命令

- jmap 查内存中的对象
- jstack 查线程的情况
- jstat 查看堆内存各部分的使用量


