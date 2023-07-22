# AARCH64 立即数范围

在`tools/arch/arm64/include/asm/insn.h`中存在一个立即数的枚举类，用以分析 aarch64 中的立即数的类型:

```c
enum aarch64_insn_imm_type {
	AARCH64_INSN_IMM_ADR,
	AARCH64_INSN_IMM_26,
	AARCH64_INSN_IMM_19,
	AARCH64_INSN_IMM_16,
	AARCH64_INSN_IMM_14,
	AARCH64_INSN_IMM_12,
	AARCH64_INSN_IMM_9,
	AARCH64_INSN_IMM_7,
	AARCH64_INSN_IMM_6,
	AARCH64_INSN_IMM_S,
	AARCH64_INSN_IMM_R,
	AARCH64_INSN_IMM_N,
	AARCH64_INSN_IMM_MAX
};
```

后面的数字表示立即数的位数。所以在这里记录一下立即数的位数。关于后面的字母，S、R 和 N 是一些额外位用于扩展立即数的位数或提供附加信息的标志位。
这些标志位在某些指令中用于对立即数进行调整或扩展，以适应指令的需要。

对这些立即数的处理如下：

```c
	case AARCH64_INSN_IMM_6:
	case AARCH64_INSN_IMM_S:
		mask = BIT(6) - 1;
		shift = 10;
		break;
	case AARCH64_INSN_IMM_R:
		mask = BIT(6) - 1;
		shift = 16;
		break;
	case AARCH64_INSN_IMM_N:
		mask = 1;
		shift = 22;
		break;
```

1. AARCH64_INSN_IMM_ADR：这代表 ADR 指令中使用的立即数类型。ADR
   指令用于计算一个符号地址的值，通常用于加载地址到寄存器。

2. AARCH64_INSN_IMM_26：这代表使用 26 位立即数的指令类型。这通常是一些条件分支指令中使用的立即数，用于表示相对于当前
   PC（程序计数器）的目标地址偏移量。

3. AARCH64_INSN_IMM_19：这代表使用 19
   位立即数的指令类型。同样，这也是一些条件分支指令中使用的立即数，用于表示相对于当前 PC 的目标地址偏移量。

4. AARCH64_INSN_IMM_16：这代表使用 16 位立即数的指令类型。例如，MOVZ 和 MOVK 指令中使用的立即数，用于加载 16
   位的常数值到寄存器。

5. ARCH64_INSN_IMM_14：这代表使用 14 位立即数的指令类型。例如，一些 Load/Store
   指令中使用的立即数，用于表示访问内存时的偏移量。

6. CH64_INSN_IMM_12：这代表使用 12 位立即数的指令类型。这些立即数通常用于一些算术指令（如 ADD 和
   SUB），用于执行加法和减法运算。

7. AARCH64_INSN_IMM_9：这代表使用 9 位立即数的指令类型。例如，一些 Load/Store
   指令中使用的立即数，用于表示访问内存时的偏移量。

8. AARCH64_INSN_IMM_7：这代表使用 7 位立即数的指令类型。例如，一些 Load/Store
   指令中使用的立即数，用于表示访问内存时的偏移量。

9. AARCH64_INSN_IMM_6：这代表使用 6 位立即数的指令类型。例如，一些 Load/Store
   指令中使用的立即数，用于表示访问内存时的偏移量。

10. AARCH64_INSN_IMM_MAX：这个枚举成员标记了立即数类型的最大值，本身没有实际的立即数类型，只用于标记边界。

## Arithmetic instructions

add/sub 指令的布局：

> 这些布局都是从[arm manual](https://developer.arm.com/documentation/ddi0596/2020-12?lang=en)中获取。
> 可能我在我的 objtool-amd-v5-impl-p1 有更多信息。

```
 31  30 29 28 | 27 26 25 24 | 23 22 21    |        |           |  10 9    |       5 4 |       0 |
+---+--+--+---+-------------+---+--+------+--------+-----------+----+-----+--------+--+---------+
|   |  |  |                     |  |                                |              |            |
|sf |op|S | 1    0  0  0  1   0 |sh|         imm12                  |      Rn      |     Rd     |
|   |  |  |                     |  |                                |              |            |
|   |  |  |                     |  |                                |              |            |
+---+--+--+---------------------+--+--------------------------------+--------------+------------+
```

如上图所示 `add/sub` 拥有 12 位无符号立即数(imm12)，可以通过设置 `sh` 将其移位 12 位（左移）。

## Move instructions

```
 31  30 29 28| 27 26 25 24| 23 22 21 20|               5  4 |            0|
+---+-----+-------------------+-----+-------------------+---+-------------+
|   |     |                   |     |                   |                 |
| op| opc |1   0   0  1  0  1 | hw  |      imm16        |    Rd           |
|   |     |                   |     |                   |                 |
+---+-----+-------------------+-----+-------------------+-----------------+
```

move 指令(`movz`,`movn`,`movk`) 拥有 16 位立即数(imm16) 可以通过改变 hw 的值进行 0，16，32
或者 48 的移位。

引用[这篇文章](https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64/)中对 movz 和 movk 的解释及示例：

> movz assigns the given 16-bit value to the position given by the shift operand and zeroes all other bits.
> movk does the same but keeps the value of the other bits instead of zeroing them.
> So in the worst case a 64-bit immediate needs 4 instructions.
> But many common immediates can be encoded in less:
>
> ```
> # x0 = 0x10000
> movz x0, 0x1, lsl 16
>
> # x0 = 0x10001
> movz x0, 0x1
> movk x0, 0x1, lsl 16
> ```

## Address calculations

```
 31  30 29 28| 27 26 25 24| 23                         5  4 |            0|
+---+-----+---------------------------------------------+---+-------------+
|   |     |               |                             |                 |
| op|immlo|1  0   0  0  0 |                immhi        |    Rd           |
|   |     |               |                             |                 |
+---+-----+---------------+-----------------------------+-----------------+
```

adr,adrp 拥有 21 位立即数(immhi + immlo)

## Logical instructions

Logical instructions 拥有 13 位立即数。这里的内容稍微复杂，请查看这些文章，他们的讲解可能会更好：

- https://blog.csdn.net/pcj_888/article/details/121455966

- https://dinfuehr.github.io/blog/encoding-of-immediate-values-on-aarch64/
