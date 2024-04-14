# MYSQL 101

MYSQL 的一些常见命令总结，方便自己更快复习。

## 一些常用的重要的 SQL 命令

- SELECT - extracts data from a database
- UPDATE - updates data in a database
- DELETE - deletes data from a database
- INSERT INTO - inserts new data into a database
- CREATE DATABASE - creates a new database
- ALTER DATABASE - modifies a database
- CREATE TABLE - creates a new table
- ALTER TABLE - modifies a table
- DROP TABLE - deletes a table
- CREATE INDEX - creates an index (search key)
- DROP INDEX - deletes an index

## SELECT

语法：

```sql
SELECT column1, column2, ...
FROM table_name;
```

```sql
SELECT * FROM table_name;
```

### SELECT DISTINCT

`SELECT DISTINCT` 语句用于返回不同的值。

```sql
SELECT DISTINCT column1, column2, ...
FROM table_name;
```

获取不同的 column 的数量：

```sql
SELECT COUNT(DISTINCT column) FROM table_name;
```

## WHERE

`WHERE` 子句用于过滤记录。

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition;
```

> `WHERE` 还可以用于 `UPDATE`，`DELETE` 等等。

## AND/OR/NOT

`WHERE` 子句可以和 `AND`, `OR`, `NOT` 运算符结合使用。

### AND

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition1 AND condition2 AND condition3 ...;
```

### OR

```sql
SELECT column1, column2, ...
FROM table_name
WHERE condition1 OR condition2 OR condition3 ...;
```

### NOT

```sql
SELECT column1, column2, ...
FROM table_name
WHERE NOT condition;
```

## AND 和 OR, NOT 结合使用

在满足 condition1 的同时满足 condition2/condition3:

```sql
SELECT * FROM table_name
WHERE condition1 AND (condition2 OR condition3)
```

多个否定：

```sql
SELECT * FROM table_name
WHERE NOT condition1 AND NOT condition2;
```

## ORDER BY

`ORDER BY` 关键字用于按升序或降序对结果集进行排序。

```sql
SELECT column1, column2, ...
FROM table_name
ORDER BY column1, column2, ... ASC|DESC;
```

> ASC:Ascending （升序）, DESC: descending （降序）

## INSERT INTO

`INSERT INTO` 语句用于在表中插入新记录。

指定要插入的值：

```sql
INSERT INTO table_name (column1, column2, column3, ...)
VALUES (value1, value2, value3, ...)
```

向表的所有列添加内容，不需要在 SQL 中指定列名称：

```sql
INSERT INTO table_name
VALUES(value1, value2, value3, ...);
```

## NULL 值

判断一个字段是否为 NULL:

```sql
SELECT column_names
FROM table_name
WHERE column_name IS NULL;
```

与 `NOT` 配合使用：

```sql
SELECT column_name
FROM table_name
WHERE column_name IS NOT NULL;
```

## UPDATE SET

`UPDATE` 用于更新已存在的记录。

```sql
UPDATE table_name
SET column1 = value1, column2 = value2, ...
WHERE condition;
```

> WARN: 注意使用 `UPDATE SET` 语句时要添加 `WHERE`，不然，表中的所有记录都会被修改。

## DELETE

```sql
DELETE FROM table_name WHERE condition;
```

## LIMIT

`LIMIT` 指定返回的记录数。

```sql
SELECT column_name
FROM table_name
WHERE condition
LIMIT number;
```

从查找出的记录中返回前 3 条记录：

```sql
SELECT * FROM table_name
LIMIT 3;
```

### 配合 OFFSET 使用

从查找出来的第 3 个记录开始返回（不包括第 3 个）：

```sql
SELECT * FROM table_name
LIMIT 3 OFFSET 3;
```

> 常用于分页返回

### 配合 WHERE 使用

```sql
SELECT * FROM table_name
WHERE condition
LIMIT 3;
```

## MYSQL Functions

一些常见的函数。

### MIN(), MAX()

`MIN()` 函数返回所选列的最小值。
`MAX()` 函数返回所选列的最大值。

```sql
SELECT MIN(column_name)
FROM table_name
WHERE condition;
```

```sql
SELECT MAX(column_name)
FROM table_name
WHERE condition;
```

### COUNT(), AVG(), SUM()

`COUNT()` 函数返回与指定条件匹配的行数。

```sql
SELECT COUNT(column_name)
FROM table_name
WHERE condition;
```

AVG() 函数返回列的值为数字的平均值。

```sql
SELECT AVG(column_name)
FROM table_name
WHERE condition;
```

SUM() 函数返回列的值为数字的总和。

```sql
SELECT SUM(column_name)
FROM table_name
WHERE condition;
```

## LIKE

`LIKE` 运算符在 `WHERE` 子句中使用以搜索列中的指定模式。

有两个通配符经常与 LIKE 运算符一起使用：

- 百分号 `%` 表示零个、一个或多个字符
- 下划线符号 `_` 代表一个，单个字符。（占位符）

百分号和下划线可以组合使用。

以 a 开头且必须要两个字符以上：

```sql
SELECT * FROM table_name
WHERE column_name LIKE 'a_%';
```

## IN

`IN` 运算符允许在 `WHERE` 子句中指定多个值。

`IN` 运算符是多个 `OR` 条件的简写。

```sql
SELECT *
FROM table_name
WHERE column_name IN (value1, value2, ...);
```

## BETWEEN

`BETWEEN` 运算符选择给定范围内的值。这些值可以是数字、文本或日期。

`BETWEEN` 运算符具有包容性：包括开始值和结束值。

```sql
SELECT *
FROM table_name
WHERE column_name BETWEEN value1 AND value2;
```

当 `BETWEEN` 比较的是字符串时，会按照字符串的字典序进行比较。

## 别名 AS

别名用于为**表**或**表中的列**提供临时名称。

别名通常用于使列名更具可读性。

别名仅在该查询期间存在。

使用 AS 关键字创建别名。

Alias Column:

```sql
SELECT column_name AS alias_name
FROM table_name;
```

Alias Table:

```sql
SELECT column_name
FROM table_name AS alias_name;
```

## JOIN

`JOIN` 子句用于根据它们之间的相关列组合来自两个或多个表的行。

四种 `JOIN` 类型：

- `INNER JOIN`：返回两个表中值匹配的记录
- `LEFT JOIN`：返回左表所有记录，右表匹配记录
- `RIGHT JOIN`：返回右表的所有记录，以及左表的匹配记录
- `CROSS JOIN`：返回两个表中的所有记录

INNER/LEFT/RIGHT 语法：

返回符合两表中 `column3` 相等的 `table1.column1` 和 `table2.column1` 列：

```sql
SELECT table1.column1, table2.column1, ...
FROM table1
INNER/LEFT/RIGHT JOIN table2
ON table1.column3=table2.column3;
```

CROSS 语法：

```sql
SELECT column_names,....
FROM table1
CROSS JOIN table2;
```

下面以这两个表为例：

```
mysql> select * from fruits;
+------+--------+
| id   | name   |
+------+--------+
|    1 | apple  |
|    2 | banana |
|    3 | cherry |
|    4 | peach  |
|    7 | test   |
+------+--------+

mysql> select * from product;
+------+------+---------+
| id   | fid  | pname   |
+------+------+---------+
|    1 |    1 | apples  |
|    2 |    2 | bananas |
|    3 |    3 | cherrys |
|    4 |    4 | peachs  |
+------+------+---------+
```

### INNER JOIN

### LEFT JOIN

`LEFT JOIN` 关键字返回左表中的所有记录，即使右边没有匹配项。

```sql
mysql> select p.pname, f.name from product as p left join fruits as f on p.fid=f.id;
+---------+--------+
| pname   | name   |
+---------+--------+
| apples  | apple  |
| bananas | banana |
| cherrys | cherry |
| peachs  | peach  |
+---------+--------+
```

可以看到匹配的全是左表的记录。可以看 `RIGHT JOIN` 示例。

### RIGHT JOIN

`RIGHT JOIN` 关键字返回右表中的所有记录，即使左边没有匹配项。

```sql
mysql> select p.pname, f.name from product as p right join fruits as f on p.fid=f.id;
+---------+--------+
| pname   | name   |
+---------+--------+
| apples  | apple  |
| bananas | banana |
| cherrys | cherry |
| peachs  | peach  |
| NULL    | test   |
+---------+--------+
```

看到 `pname` 为 `NULL` 这里返回右表 `fruits` 的所有内容，不管有没有匹配上。
只不过 `pname` 为 `NULL`。

### CROSS JOIN

`CROSS JOIN` 返回两个表行数的乘积。

```sql
mysql> select p.pname,f.name from product as p cross join fruits as f;
+---------+--------+
| pname   | name   |
+---------+--------+
| peachs  | apple  |
| cherrys | apple  |
| bananas | apple  |
| apples  | apple  |
| peachs  | banana |
| cherrys | banana |
| bananas | banana |
| apples  | banana |
| peachs  | cherry |
| cherrys | cherry |
| bananas | cherry |
| apples  | cherry |
| peachs  | peach  |
| cherrys | peach  |
| bananas | peach  |
| apples  | peach  |
| peachs  | test   |
| cherrys | test   |
| bananas | test   |
| apples  | test   |
+---------+--------+
```

### SELF JOIN

区分这两个：

```sql
mysql> select A.name, B.name from fruits as A, fruits as B where A.id <> B.id;
+--------+--------+
| name   | name   |
+--------+--------+
| test   | apple  |
| peach  | apple  |
| cherry | apple  |
| banana | apple  |
| test   | banana |
| peach  | banana |
| cherry | banana |
| apple  | banana |
| test   | cherry |
| peach  | cherry |
| banana | cherry |
| apple  | cherry |
| test   | peach  |
| cherry | peach  |
| banana | peach  |
| apple  | peach  |
| peach  | test   |
| cherry | test   |
| banana | test   |
| apple  | test   |
+--------+--------+
20 rows in set (0.00 sec)

mysql> select A.name, B.name from fruits as A, fruits as B;
+--------+--------+
| name   | name   |
+--------+--------+
| test   | apple  |
| peach  | apple  |
| cherry | apple  |
| banana | apple  |
| apple  | apple  |
| test   | banana |
| peach  | banana |
| cherry | banana |
| banana | banana |
| apple  | banana |
| test   | cherry |
| peach  | cherry |
| cherry | cherry |
| banana | cherry |
| apple  | cherry |
| test   | peach  |
| peach  | peach  |
| cherry | peach  |
| banana | peach  |
| apple  | peach  |
| test   | test   |
| peach  | test   |
| cherry | test   |
| banana | test   |
| apple  | test   |
+--------+--------+
25 rows in set (0.00 sec)
```

连接操作中排除那些自身匹配的情况，确保只有不同 fruit 之间的匹配会被包含在结果中。

## UNION

`UNION` 运算符用于组合两个或多个 `SELECT` 语句的结果集。

- `UNION` 中的每个 `SELECT` 语句必须具有相同的列数
- 列还必须具有相似的数据类型
- 每个 `SELECT` 语句中的列也必须是相同的顺序

```sql
SELECT column_name(s) FROM table1
UNION
SELECT column_name(s) FROM table2;
```

`UNION` 会将结果都排在一起。

## GROUP BY

`GROUP BY` 语句将具有相同值的行分组为汇总行，例如"查找每个地区的客户数量"。

`GROUP BY` 语句通常与聚合函数 (`COUNT()`、`MAX()`, `MIN()`, `SUM()`, `AVG()`) 按一列或多列对结果集进行分组。

语法：

```sql
SELECT column_name(s)
FROM table_name
WHERE condition
GROUP BY column_name(s)
ORDER BY column_name(s);
```

一眼看过去，不懂 `GROUP BY` 的作用，举例：

存在以下表：

```
+------+--------+
| id   | name   |
+------+--------+
|    1 | apple  |
|    2 | banana |
|    3 | cherry |
|    4 | peach  |
|    7 | test   |
|   99 | apple  |
+------+--------+
```

考虑以下输出：

```sql
mysql> select name from fruits group by name;
+--------+
| name   |
+--------+
| apple  |
| banana |
| cherry |
| peach  |
| test   |
+--------+
```

与：

```sql
mysql> select distinct name from fruits;
+--------+
| name   |
+--------+
| apple  |
| banana |
| cherry |
| peach  |
| test   |
+--------+
```

`DISTINCT` 输出与我们通过上面的 `GROUP BY` 查询得到的结果相同。

`select name, count(*) from fruits group by name;`

输出：

```sql
mysql> select name, count(*) from fruits group by name;
+--------+----------+
| name   | count(*) |
+--------+----------+
| apple  |        2 |
| banana |        1 |
| cherry |        1 |
| peach  |        1 |
| test   |        1 |
+--------+----------+
```

## HAVING

`HVAING` 与聚合函数一起使用，因为 `WHERE` 不能与聚合函数一起使用。

语法：

```sql
SELECT column_name(s)
FROM table_name
WHERE condition
GROUP BY column_name(s)
HAVING condition
ORDER BY column_name(s);
```

查询数量在两个以上的 fruit:

```sql
mysql> select count(id), name from fruits group by name  having count(id) > 1;
+-----------+-------+
| count(id) | name  |
+-----------+-------+
|         2 | apple |
+-----------+-------+
```

> 必须使用 `GROUP BY`，因为 `name` 属于非聚合列

## EXISTS

`EXISTS` 运算符用于测试子查询中是否存在任何记录。

如果子查询返回一条或多条记录，`EXISTS` 运算符返回 TRUE。

语法：

```sql
SELECT column_name(s)
FROM table_name
WHERE EXISTS
(SELECT column_name FROM table_name WHERE condition);
```

## INSERT INTO SELECT

`INSERT INTO SELECT` 语句从一个表中复制数据并将其插入到另一个表中。

`INSERT INTO SELECT` 语句要求源表和目标表中的数据类型匹配。

> 目标表中的现有记录不受影响。

语法：

将一个表的所有列复制到另一个表：

```sql
INSERT INTO table2
SELECT * FROM table1
WHERE condition;
```

仅将一个表中的一些列复制到另一个表中：

```sql
INSERT INTO table2 (column1, column2, column3, ...)
SELECT column1, column2, column3, ...
FROM table1
WHERE condition;
```

## CASE

`CASE` 语句遍历条件并在满足第一个条件时返回一个值（如 if-then-else 语句）。 因此，一旦条件为真，它将停止读取并返回结果。 如果没有条件为真，则返回 `ELSE` 子句中的值。

如果没有 `ELSE` 部分且没有条件为真，则返回NULL。

语法：

```sql
CASE
    WHEN condition1 THEN result1
    WHEN condition2 THEN result2
    WHEN conditionN THEN resultN
    ELSE result
END; 
```
