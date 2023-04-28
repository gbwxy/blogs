
## 一个表最多多少个索引，多少列
https://dev.mysql.com/doc/refman/5.7/en/column-count-limit.html#column-count-limits
https://dev.mysql.com/doc/refman/5.7/en/innodb-limits.html

InnoDB 引擎
A table can contain a maximum of 1017 columns (raised in MySQL 5.6.9 from the earlier limit of 1000). Virtual generated columns are included in this limit.
A table can contain a maximum of 64 secondary indexes.

- 1个表最大只能 1017 列
- 1个表最大只能创建 64 个 2级索引。 加上主键，那么上面的问题就有了答案，65个
-  复合索引最多只能 16 列
- 