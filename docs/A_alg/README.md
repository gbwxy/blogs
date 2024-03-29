# Master 公式

## 什么是 Master 公式

Master 公式是用来利用分治策略解决问题经常使用的时间复杂度的分析方法

分治策略中使用递归来求解问题分为三步走，分别为分解、解决和合并

## Master 公式解释

![](./../../resources/image/algoruthm/Master公式.png)

- a：生成的子问题数（比如二叉树的递归遍历就是 a = 2)
- b：表示每次递归是母问题的1/b的数据规模
- N：母问题的数据规模
- d：额外操作的次数

**注：使用Master公式分析递归问题时间复杂度时，各子问题的数据规模应该是一致的，否则不能使用Master公式。**

# 子串、子序列

对于一个字符串而言，比如：pikachu

- 字串是在字符串中，取出一块（连续的），如：pik, ach, kac等
- 子序列指的是从字符串中，顺序取出字符，但是可以不连续：如：pau, kch, icu等
