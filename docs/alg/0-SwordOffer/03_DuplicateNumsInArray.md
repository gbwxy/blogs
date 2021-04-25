## 数组中重复的数字
### 题目一：找出数组中重复的数字
在一个长度为 n 的数组里的所有数字都在 0~n-1 的范围内。数组中某些数字是重复的，但不知道有几个数字重复了，也不知道每个数字重复了几次。请找出数组中任意一个重复数字。例如，如果输入长度为 7 的数组 {2,3,1,0,2,5,3}，那么对应的输出是重复数字 2 或 3

#### 解题思路
![](https://note.youdao.com/yws/api/personal/file/4F02DBC56A0F40509B4BE25425A3D888?method=download&shareKey=485c1f7b798f940706325f9dba6ff787)

1. 从头到尾依次扫描这个数组 a[] 中的每个数字
2. 当扫描到下标为 i 的数字时（a[i] 表示下标为 i 的数字），比较 a[i] 与 i 
	- 如果 a[i] == i，则继续扫描
	- 如果 a[i] != i，设 m = a[i]，比较 a[i] 和 a[m]
		- 如果 a[i] == a[m]，就找到了一个重复的数字
		- 如果 a[i] != a[m]，则将  a[i] 和 a[m] 的值进行交换
3. 重复步骤 2

#### 代码
```java
    public static Integer func(int[] arr) {
        for (int ii = 0; ii < arr.length; ii++) {
            if (arr[ii] == ii) {
                continue;
            }
            int m = arr[ii];
            if (arr[ii] == arr[m]) {
                return arr[ii];
            } else {
                arr[ii] = arr[m];
                arr[m] = m;
            }
        }
        return null;
    }
```

### 题目二：不修改数组找出重复的数字
在一个长度为 n+1 的数组里的所有数字都在 1~n 的范围内，所以数组中至少有一个数字是重复的。请找出数组中任意一个重复的数字，但不能修改输入的数组。例如，如果输入长度为 8 的数组{2,3,5,4,3,2,6,7}，那对应的输出是重复数字 2 或 3

#### 解题思路
##### 时间优先算法
1. 需要 O(n) 的辅助空间
2. 创建一个长度为 n+1 的辅助数组 num[n+1]
3. 遍历原数组中的数字
	- 如果原数组中被复制的数字是 m，则将它与 num[m] 进行比较
	- 如果 m == num[m] 则返回该重复的数字
	- 如果 num[m] ==0 && m != num[m] 则将 m 存入 num[m] 中
4. 重复步骤 3

**该方法的时间复杂度是 O(n)，空间复杂度 O(n)** 

##### 空间优先算法
1. 把 1~n 的数字从中间的数字 m 分两部分，前面一半为 1~m，后面的一半为 m+1~n；
2. 设 start = 1，end = n，mid = (end - start)/2 + start
3. 遍历给定的数组 a[] ，查找值在 1~m 范围内的个数 count
	- 如果 count >  m，那么 1~m 里一定包含重复的数字
		- 将 1~m 分两部分，1~m/2 和 m/2+1 ~ m
		- end = m，重复步骤 3
	- 否则 m+1~n 中一定存在重复数字
		- 将 m+1~n 分两部分，(n-(m+1))/2+m+1 和 m/2+1 ~ m，重复步骤 2
		-  start = 1 + m，重复步骤 3

**该方法类似二分查找，只是多了一步统计区间里数字的数目** 
**该方法的时间复杂度是 O(n*logn)，空间复杂度 O(1)** 


#### 代码
```Java
    /**
     * 不改变原数组，时间优先算法
     *
     * @param arr
     * @return
     */
    public static Integer funcTime(int[] arr) {
        if (arr == null || arr.length == 0) {
            return null;
        }
        //int类型数组，创建后默认赋值为 0
        int[] nums = new int[arr.length + 1];
        for (int ii = 0; ii < arr.length; ii++) {
            int m = arr[ii];
            if (nums[m] == m) {
                return m;
            } else {
                nums[m] = m;
            }
        }
        return null;
    }
    
       /**
     * 不改变原数组，空间优先算法
     *
     * @param arr
     * @return
     */
    public static Integer funcSpace(int[] arr) {
        if (arr == null || arr.length == 0) {
            return null;
        }

        int len = arr.length;
        int start = 1;
        int end = len - 1;
        while (end >= start) {
            int mid = ((end - start) >> 1) + start;
            int count = countRange(arr, len, start, mid);
            if (end == start) {
                if (count > 1) {
                    return start;
                } else {
                    break;
                }
            }
            if (count > (mid - start + 1)) {
                end = mid;
            } else {
                start = mid + 1;
            }
        }

        return null;
    }

    private static int countRange(int[] arr, int length, int start, int end) {
        if (arr == null) {
            return 0;
        }
        int count = 0;
        for (int ii = 0; ii < arr.length; ii++) {
            if (arr[ii] >= start && arr[ii] <= end) {
                count++;
            }
        }

        return count;
    }

```












