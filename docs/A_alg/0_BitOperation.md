# 位运算及其扩展

## int类型的数，提取其二进制中最右侧的1来

```java
int rightOne=val&(-val)

```

## 异或运算

- a ^ b = b ^ a;
- (a ^ b) ^ c =a ^ (b ^ c)
- a ^ b ^ a = b
- a ^ a = 0
- 0 ^ a = a
