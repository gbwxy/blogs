## 面试题4：二维数组中的查找
### 题目
在一个数组中，每一行都按照从左到右递增的顺序排序，每一列都按照从上到下递增的顺序排序。请完成一个函数，输入这样的一个二维数组和一个整数，判断数组中是否含有该整数。
### 解题思路
二维数组 a()() 特点是每一行递增，每一列也递增，m行，n列
比较 a(i)(j) 与 给定数字 tar
	- 如果 a(i)(j)  > tar，则 tar 如果存在则在 a()() 区域 1 中 
	- 如果 a(i)(j) < tar,则 tar 如果存在则在 a()() 区域 2 中 
	- 如果 a(i)(j) == tar, 则找到
![](https://note.youdao.com/yws/api/personal/file/08385905A45A4103B7E5E35F67E40162?method=download&shareKey=55454657f5c7445fd7a9d1357447dd80)

1. 从右上角数字开始查找 a(0)(n-1)；i = 0  j = n-1
2. 如果 a(i)(j) > tar，j--;
3. 如果 a(i)(j) < tar，i++；
4. 如果 a(i)(j) = tar，返回
5. 如果 i == m -1 && j == 0，a(i)(j) != tar，则没有找到

例如：给定数组如下，查找数字 7
[
    1,2,8,9
    2,4,9,12
    4,7,10,13
    6,8,11,15
]

![](https://note.youdao.com/yws/api/personal/file/4273D21FB6FF4BB0BABAF94E3A19D182?method=download&shareKey=77c8b3a1c496f1f3da756094ce87dcf9)

### 代码
```Java
   /**
     * 若数组为空，返回 false
     * 初始化行下标为 0，列下标为二维数组的列数减 1
     * 重复下列步骤，直到行下标或列下标超出边界
     * 获得当前下标位置的元素 num
     * 如果 num 和 target 相等，返回 true
     * 如果 num 大于 target，列下标减 1
     * 如果 num 小于 target，行下标加 1
     * 循环体执行完毕仍未找到元素等于 target ，说明不存在这样的元素，返回 false`
     *
     * @param matrix
     * @param target
     * @return
     */
    public boolean findNumberIn2DArray(int[][] matrix, int target) {
        if (matrix == null || matrix.length == 0 || matrix[0].length == 0) {
            return false;
        }
        int rows = matrix.length, columns = matrix[0].length;
        int row = 0, column = columns - 1;
        while (row < rows && column >= 0) {
            int num = matrix[row][column];
            if (num == target) {
                return true;
            } else if (num > target) {
                column--;
            } else {
                row++;
            }
        }
        return false;
    }
```

