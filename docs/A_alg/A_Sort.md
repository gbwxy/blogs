# 经典排序算法

**注意：代码中排序都是从小到大排序 **

## 排序总结

- 归并排序、快速排序、堆排序，
    - 时间复杂度都是 O(N*logN)；
    - 归并排序额外空间复杂度 O(N)，最稳定，排序后 2 个相等键值的顺序和排序之前它们的顺序相同
    - 快速排序常数项时间小，最快，额外空间复杂度 O(logN)
    - 堆排序，额外空间复杂度 O(1)
-

## 选择排序 Code01_SelectSort

- 第一层循环，i = 0 -> N-1
- 第二层循环，j = i+1 -> N-1
    - 在 i ~ N-1 上找最小值的下标，和 arr[i] 进行交换

## 冒泡排序 Code02_BubbleSort

- 第一层循环，e = N-1 -> 0
- 第二层循环，i = 0 -> e - 1
    - 如果 arr[i] > arr[i+1]，交换 arr[i] 和 arr[i+1]

## 插入排序 Code03_InsertionSort

- 第一层循环，i = 1 -> N-1
- 第二层循环，j = i - 1 -> 0
    - 将 arr[i] 插入到 arr[0...i-1] 正确的位置
        - 因为 arr[0...i-1] 是有序的，只需找到第一个 arr[j] <= arr[i] 的位置，并将 arr[i] 插入到 arr[j] 后面，并且 arr[j+1] 及后面的都后移一位
    - 此步骤 保证 arr[0...i] 是有序的

## 归并排序 Code04_MergeSort

- 二分法将数组分成两个数组 arr[L...Mid] 和 arr[Mid+1...R]，分别将两个数组排有序，然后再将两个数组合并，并保证有序
- 起始 L = 0，R = N-1
- 采用递归比较好理解，非递归方式不好理解
- 时间复杂度 O(N*logN)，额外空间复杂度 O(N)，稳定
- 稳定性：排序后 2 个相等键值的顺序和排序之前它们的顺序相同

## 快速排序 Code05_QuickSort

- arr[L...R] 中随机选择一个数 val，大于 val 的放右边，小于 val 的放左边，等于的放中间
    - [L...less][less+1....more-1][more...R]
    - 返回结果 result[0] = less ; result[1] = more
- 分别 arr[L...less] 和 arr[more...R]
- 时间复杂度 O(N*logN)，额外空间复杂度 O(logN)，不稳定

## 堆排序 Code06_HeapSort

- 首先根据 arr，构建大根堆结构，大根堆大小为 heapSize = arr.length()
- 此时 arr[0] 为最大值，将 arr[0] 与 arr[heapSize] 交换；heapSize--；并维护大根堆结构
- 循环上述步骤，直到 heapSize = 0
- 时间复杂度 O(N*logN)，额外空间复杂度 O(1)，不稳定

## 使用对数器验证算法是否正确 Test

获取随机数组

```java
/**
 Math.random()              -> [0,1)
 Math.random() * N          -> [0,N)
 (int)(Math.random() * N)   -> [0, N-1]
 (int)(Math.random() * (N+1))   -> [0, N]
 (int) ((N + 1) * Math.random()) - (int) (N * Math.random())   ->  [-(N-1) , N]
 **/
/**
 * 获取随机数组
 *
 * @param maxSize  数组最大个数
 * @param maxValue 数组中的最大值
 * @return 随机数组
 */
public static int[]generateRandomArray(int maxSize,int maxValue){
      int[]arr=new int[(int)((maxSize+1)*Math.random())];
      for(int i=0;i<arr.length;i++){
      arr[i]=(int)((maxValue+1)*Math.random())-(int)(maxValue*Math.random());
      }
      return arr;
      }
```

## 非基于比较的排序

### 计数排序

- 只适用于正整数数组
- 首先获取数组的最大值，然后根据最大值设置桶大小
- 对数组中的值进行计数，最后根据桶的顺序和出现从次数重新组织数组

### 基数排序

- 只适用于正整数数组
- 获取所有值的最大十进制位数，按照 个位、十位、百位、千位... 的顺序，依次对数组进行排序
- 对于 d 位，设置 0...9 是个桶，bucket[i] 标识 0...i 出现个数之和
- i = N-1 -> 0，将 arr[i] 的放在对应的位置上 help[bucket[j] - 1] = arr[i]，其中 j 是 arr[i] d 位上的值

## 参考

- [十大排序](https://www.runoob.com/w3cnote/ten-sorting-algorithm.html)
