# objtool-amd-v5-impl-p1

armv8 二进制位表示（C4 章节）：https://developer.arm.com/documentation/ddi0487/latest/

在 `tools/objtool/check.h` 中有这样一个 `instruction` 结构体表示一个指令：

```c
struct instruction {
	struct list_head list;
	struct hlist_node hash;
	struct section *sec;
	unsigned long offset;
	unsigned int len;
	enum insn_type type;
	unsigned long immediate;
	bool alt_group, dead_end, ignore, hint, save, restore, ignore_alts;
	bool retpoline_safe;
	u8 visited;
	struct symbol *call_dest;
	struct instruction *jump_dest;
	struct instruction *first_jump_src;
	struct rela *jump_table;
	struct list_head alts;
	struct symbol *func;
	struct stack_op stack_op;
	struct insn_state state;
	struct orc_entry orc;
};
```

## Data Processing -- Immediate

处理立即数。

对应代码：

```c
int arm_decode_dp_imm(u32 instr, enum insn_type *type,
		      unsigned long *immediate, struct list_head *ops_list)
{
	arm_decode_class decode_fun;

	decode_fun = aarch64_insn_dp_imm_decode_table[INSN_DP_IMM_SUBCLASS(instr)];
	if (!decode_fun)
		return -1;
	return decode_fun(instr, type, immediate, ops_list);
}
```

也就是含有`dp_imm`的函数都属于`Data Processing -- Immediate` 操作。

它的布局如下：

```
 31 30 29+28   |   26|25    |23|22         |                                                                            0|
         |     |     |      |  |           |                                                                             |
+--------------+------------+--------------+-----------------------------------------------------------------------------+
|        |           |         |                                                                                         |
|        |           |  op0    |                                                                                         |
|        |   100     |         |                                                                                         |
|        |           |         |                                                                                         |
+--------+-----------+---------+-----------------------------------------------------------------------------------------+
```

当 28-26 位为 100 时，armv8 的指令格式如上。其中，op0 的数字的不同有不同的作用(C4.1.86):

| Decode fields op0 | Decode group or instruction        |
| ----------------- | ---------------------------------- |
| 00x               | PC-rel. addressing                 |
| 010               | Add/subtract(immediate)            |
| 011               | Add/subtract(immediate, with tags) |
| 100               | Logical(immediate)                 |
| 101               | Move wide(immediate)               |
| 110               | Bitfield                           |
| 111               | Extract                            |

详细情况查阅文档(c4.1.86)

```c
#define INSN_DP_IMM_SUBCLASS(opcode)			\
	(((opcode) >> 23) & (NR_DP_IMM_SUBCLASS - 1))
```

`INSN_DP_IMM_SUBCLASS` 的操作就是获取 op0 的值。

`tools/objtool/arch/arm64/decode.c` 中有这样一个数组：

```c
#define INSN_PCREL	0b001	//0b00x
#define INSN_ADD_SUB	0b010
#define INSN_ADD_TAG	0b011
#define INSN_LOGICAL	0b100
#define INSN_MOVE_WIDE	0b101
#define INSN_BITFIELD	0b110
#define INSN_EXTRACT	0b111

// 这个数组与上方表格相对
static arm_decode_class aarch64_insn_dp_imm_decode_table[NR_DP_IMM_SUBCLASS] = {
	[0 ... INSN_PCREL]	= arm_decode_pcrel,
	[INSN_ADD_SUB]		= arm_decode_add_sub,
	[INSN_ADD_TAG]		= arm_decode_add_sub_tags,
	[INSN_LOGICAL]		= arm_decode_logical,
	[INSN_MOVE_WIDE]	= arm_decode_move_wide,
	[INSN_BITFIELD]		= arm_decode_bitfield,
	[INSN_EXTRACT]		= arm_decode_extract,
};
```

这个数组用于将不同编码类别的 ARM64 指令与对应的解码函数关联。op0 的值不同有不同的解析函数。

- `arm_decode_pcrel`:PC-relative addressing:ADRP x0, {pc}.

  https://developer.arm.com/documentation/dui0742/g/Migrating-ARM-syntax-assembly-code-to-GNU-syntax/PC-relative-addressing?lang=en

- `arm_decode_move_wide`:move wide instruction:MOVZ,MOVK,MOVS....

  https://developer.arm.com/documentation/dui0489/i/arm-and-thumb-instructions/mov

- `arm_decode_bitfield`:bitfield operation:

  https://developer.arm.com/documentation/den0024/a/The-A64-instruction-set/Data-processing-instructions/Bitfield-and-byte-manipulation-instructions?lang=en

- `arm_decode_extract`:bit extract

  https://developer.arm.com/documentation/ddi0596/2020-12/Base-Instructions/BFXIL--Bitfield-extract-and-insert-at-low-end--an-alias-of-BFM-

`tools/objtool/arch/arm64/include/bit_operations.h`中有这样一段宏定义，定义一些常见的位操作：

```c
// 生成N位全为1的值
#define ONES(N)			(((__uint128_t)1 << (N)) - 1)
// 零扩展：零扩展指的是将目标的高位数设置为零，而不是将高位数设置成原数字的最高有效位。
// 零扩展通常用于将无符号数字移动至较大的字段中，同时保留其数值；
// 而符号扩展通常用于有符号的数字。
#define ZERO_EXTEND(X, N)	((X) & ONES(N))
// 提取X中的第N位位数
#define EXTRACT_BIT(X, N)	(((X) >> (N)) & ONES(1))
// 符号扩展
#define SIGN_EXTEND(X, N)	sign_extend((X), (N))

// '~' 为取反
// 0UL 表示把数字0转换为无符号长整型数
// ~0UL 表示生成一个具有所有位都为1的掩码
// nbits 表示x的最高位位置
static inline unsigned long sign_extend(unsigned long x, int nbits)
{
	return ((~0UL + (EXTRACT_BIT(x, nbits - 1) ^ 1)) << nbits) | x;
}
```

### 处理 PC-rel. addressing 的情况：

布局：

```
             +            +                                 +             +
 31  30 29 28| 27 26 25 24| 23                         5  4 |            0|
+---+-----+---------------------------------------------+---+-------------+
|   |     |               |                             |                 |
| op|immlo|1  0   0  0  0 |                immhi        |    Rd           |
|   |     |               |                             |                 |
+---+-----+---------------+-----------------------------+-----------------+
```

具有以下设定：

| op  | instruction |
| --- | ----------- |
| 0   | ADR         |
| 1   | ADRP        |

```c
int arm_decode_pcrel(u32 instr, enum insn_type *type,
		     unsigned long *immediate, struct list_head *ops_list)
{
	unsigned char page = 0;
	u32 immhi = 0, immlo = 0;

    // 首位为 0 为 ADR 操作
    // 1 则为 ADRP
	page = EXTRACT_BIT(instr, 31);
	// immediate 的高位
	immhi = (instr >> 5) & ONES(19);
	// immediate 的低位
	immlo = (instr >> 29) & ONES(2);

    // 符号扩展不理解为什么需要左移 2 | immlo
    // 左移2对齐？
	*immediate = SIGN_EXTEND((immhi << 2) | immlo, 21);

	if (page)
		*immediate = SIGN_EXTEND(*immediate << 12, 33);

	*type = INSN_OTHER;

	return 0;
}
```

> 关于 ADR 与 ADRP：
>
> - ADR 指令用于计算相对于程序计数器（PC）的地址偏移量，并将结果加载到目标寄存器中。`ADR ro, jump_target`
> - ADRP 则是用于计算相对于**页表**的地址偏移量，并将结果加载到目标寄存器。`ADRP x0, page_table_entry`. ADRP 在计算出的地址偏移量的高 12 位上会填充一些数据（待查找，似乎是相应的页表索引）

### 处理 Move wide (immediate)的情况

布局：

```
             +            +            +                    +             +
 31  30 29 28| 27 26 25 24| 23 22 21 20|               5  4 |            0|
+---+-----+-------------------+-----+-------------------+---+-------------+
|   |     |                   |     |                   |                 |
| op| opc |1   0   0  1  0  1 | hw  |      imm16        |    Rd           |
|   |     |                   |     |                   |                 |
+---+-----+-------------------+-----+-------------------+-----------------+
```

具有以下设定：

| sf(op) | opc | hw  | instruction         |
| ------ | --- | --- | ------------------- |
| -      | 01  | -   | Unallocated.        |
| 0      | -   | 1x  | Unallocated         |
| 0      | 00  | 0x  | MOVN-32-bit variant |
| 0      | 10  | 0x  | MOVZ-32-bit variant |
| 0      | 11  | 0x  | MOVK-32-bit variant |
| 1      | 00  | -   | MOVN-64-bit variant |
| 1      | 10  | -   | MOVZ-64-bit variant |
| 1      | 11  | -   | MOVK-64-bit variant |

```c
int arm_decode_move_wide(u32 instr, enum insn_type *type,
			 unsigned long *immediate, struct list_head *ops_list)
{
	u32 imm16 = 0;
	// sf 就是首位标志位op
	unsigned char hw = 0, opc = 0, sf = 0;

	sf = EXTRACT_BIT(instr, 31);
	opc = (instr >> 29) & ONES(2);
	hw = (instr >> 21) & ONES(2);
	imm16 = (instr >> 5) & ONES(16);

    // 这里(hw & 0x2)是将32bit的操作剔除？
	if ((sf == 0 && (hw & 0x2)) || opc == 0x1)
		return arm_decode_unknown(instr, type, immediate, ops_list);

	*type = INSN_OTHER;
	*immediate = imm16;

	return 0;
}
```

### 处理 Bitfield 的情况

布局：

```
 31   30 29 28  | 27 26 25 24 | 23 22 21  |       16| 15      |  10 9  |   5 4 |   0|
+---+------+----+-------------+---+--+----+-------------------+----+---+----+--+----+
|   |      |                      |  |              |              |        |       |
|sf |  opc | 1    0  0  1  1    0 | N|    immr      |    imms      |   Rn   |   Rd  |
|   |      |                      |  |              |              |        |       |
+---+------+----------------------+--+--------------+--------------+--------+-------+
```

具有以下设定：

| sf  | opc | N   | instruction         |
| --- | --- | --- | ------------------- |
| -   | 11  | -   | Unallocated.        |
| 0   | -   | 1   | Unallocated         |
| 0   | 00  | 0   | SBFM-32-bit variant |
| 0   | 01  | 0   | BFM-32-bit varian   |
| 0   | 10  | 0   | UBFM-32-bit varian  |
| 1   | -   | 0   | Unallocated.        |
| 1   | 00  | 1   | SBFM-64-bit variant |
| 1   | 01  | 1   | BFM-64-bit varian   |
| 1   | 10  | 1   | UBFM-64-bit varian  |

```c
int arm_decode_bitfield(u32 instr, enum insn_type *type,
			unsigned long *immediate, struct list_head *ops_list)
{
	unsigned char sf = 0, opc = 0, N = 0;

	sf = EXTRACT_BIT(instr, 31);
	opc = (instr >> 29) & ONES(2);
	N = EXTRACT_BIT(instr, 22);

	// 剔除 Unallocated 的指令
	if (opc == 0x3 || sf != N)
		return arm_decode_unknown(instr, type, immediate, ops_list);

	*type = INSN_OTHER;

	return 0;
}
```

关于`BFM`指令表示 Bit Field Move，位域移动指令。前面有 S 则为 signed 表示有符号，U 表示无符号。用于从一个操作数中提取一个位域，并将其移动到目标寄存器中。
`SBFM <Wd>, <Wn>, #<immr>, #<imms>`
其中：

- Rd 是目标寄存器，用于存储提取的位域值。
- Rn 是源寄存器，包含要提取位域的源操作数。
- #immr 是右移位数的立即数。它定义了从源操作数中提取位域时的右移数。
- #imms 是位域长度的立即数。它定义了要提取的位域的长度。

### 处理 extract 的情况

布局

```
 31   30 29 28  | 27 26 25 24 | 23 22 21 20 |     16| 15      |  10 9  |   5 4 |   0|
+---+------+----+-------------+---+--+--+---+-----------------+----+---+----+--+----+
|   |      |                      |  |  |           |              |        |       |
|sf | op21 | 1    0  0  1  1    1 | N|o0|  Rm       |    imms      |   Rn   |   Rd  |
|   |      |                      |  |  |           |              |        |       |
+---+------+----------------------+--+--+-----------+--------------+--------+-------+
```

具有以下设定：

| sf  | op21 | N   | o0  | imms   | instruction         |
| --- | ---- | --- | --- | ------ | ------------------- |
| -   | x1   | -   | -   | -      | Unallocated.        |
| -   | 00   | -   | 1   | -      | Unallocated.        |
| -   | 1x   | -   | -   | -      | Unallocated.        |
| 0   | -    | -   | -   | 1xxxxx | Unallocated.        |
| 0   | -    | 1   | -   | -      | Unallocated.        |
| 0   | 00   | 0   | 0   | 0xxxxx | EXTR-32-bit variant |
| 1   | -    | 0   | -   | -      | Unallocated.        |
| 1   | 00   | 1   | 0   | -      | EXTR-64-bit variant |

```c
int arm_decode_extract(u32 instr, enum insn_type *type,
		       unsigned long *immediate, struct list_head *ops_list)
{
	unsigned char sf = 0, op21 = 0, N = 0, o0 = 0;
	unsigned char imms = 0;
	unsigned char decode_field = 0;

	sf = EXTRACT_BIT(instr, 31);
	op21 = (instr >> 29) & ONES(2);
	N = EXTRACT_BIT(instr, 22);
	o0 = EXTRACT_BIT(instr, 21);
	imms = (instr >> 10) & ONES(6);

	// decode_field 的作用刚好可以排除Unallocated的情况
	decode_field = (sf << 4) | (op21 << 2) | (N << 1) | o0;
	*type = INSN_OTHER;
	*immediate = imms;

    // 10010 是EXTR-64-bit，0则是EXTR-32-bit
	if ((decode_field == 0 && !EXTRACT_BIT(imms, 5)) ||
	    decode_field == 0b10010)
		return 0;

	return arm_decode_unknown(instr, type, immediate, ops_list);
}
```

类似的，以下操作都可以根据 [armv8 手册](https://developer.arm.com/documentation/ddi0487/latest/) 查找到，这部分内容是处理立即数：C4.1.86

### Add/subtract (immediate)

在函数 `arm_decode_add_subarm_decode_add_sub` 实现。

关于它的布局查看手册。其中 rn 表示源寄存器，rd 表示目标寄存器。

```c
#define CFI_R29			29
#define CFI_FP			CFI_R29
#define CFI_BP			CFI_FP
#define CFI_SP			31

int arm_decode_add_sub(u32 instr, enum insn_type *type,
		       unsigned long *immediate, struct list_head *ops_list)
{
	unsigned long imm12 = 0, imm = 0;
	unsigned char sf = 0, sh = 0, S = 0, op_bit = 0;
	unsigned char rn = 0, rd = 0;

	S = EXTRACT_BIT(instr, 29);
	op_bit = EXTRACT_BIT(instr, 30);
	sf = EXTRACT_BIT(instr, 31);
	sh = EXTRACT_BIT(instr, 22);
	rd = instr & ONES(5);
	rn = (instr >> 5) & ONES(5);
	imm12 = (instr >> 10) & ONES(12);
	// 妙，实现了32和64位的切换
	imm = ZERO_EXTEND(imm12 << (sh * 12), (sf + 1) * 32);

	*type = INSN_OTHER;

    // 理解不能，为什么需要判断这个指令类型?
	if (rd == CFI_BP || (!S && rd == CFI_SP) || stack_related_reg(rn)) {
		struct stack_op *op;

		*type = INSN_STACK;

		op = calloc(1, sizeof(*op));
		list_add_tail(&op->list, ops_list);

		op->dest.type = OP_DEST_REG;
		op->dest.offset = 0;
		op->dest.reg = rd;
		op->src.type = OP_SRC_ADD;
		// 实现sub/add
		op->src.offset = op_bit ? -1 * imm : imm;
		op->src.reg = rn;
	}
	return 0;
}
```

### Add/subtract (immediate, with tags)

在函数 `arm_decode_add_sub_tags` 实现。

### Logical (immediate)

```c

// 获取最高位索引
int highest_set_bit(u32 x)
{
	int i;

	for (i = 31; i >= 0; i--, x <<= 1)
	    // 0x80000000 32位二进制形式最高位为1
	    // 10000000000000000000000000000000
		if (x & 0x80000000)
			return i;
	return 0;
}

/* imms and immr are both 6 bit long */
__uint128_t decode_bit_masks(unsigned char N, unsigned char imms,
			     unsigned char immr, bool immediate)
{
	u64 tmask, wmask;
	u32 diff, S, R, esize, welem, telem;
	unsigned char levels = 0, len = 0;

	// 计算imms中第一位为1的索引？
	len = highest_set_bit((N << 6) | ((~imms) & ONES(6)));
	levels = ZERO_EXTEND(ONES(len), 6);

	if (immediate && ((imms & levels) == levels)) {
		WARN("unknown instruction");
		return -1;
	}

	S = imms & levels;
	R = immr & levels;
	diff = ZERO_EXTEND(S - R, 6);

	esize = 1 << len;
	diff = diff & ONES(len);

	welem = ZERO_EXTEND(ONES(S + 1), esize);
	telem = ZERO_EXTEND(ONES(diff + 1), esize);

	wmask = replicate(ror(welem, esize, R), esize, 64 / esize);
	tmask = replicate(telem, esize, 64 / esize);

	return ((__uint128_t)wmask << 64) | tmask;
}


int arm_decode_logical(u32 instr, enum insn_type *type,
		       unsigned long *immediate, struct list_head *ops_list)
{
	unsigned char sf = 0, opc = 0, N = 0;
	unsigned char imms = 0, immr = 0, rn = 0, rd = 0;
	struct stack_op *op;

	rd = instr & ONES(5);
	rn = (instr >> 5) & ONES(5);

	imms = (instr >> 10) & ONES(6);
	immr = (instr >> 16) & ONES(6);

	N = EXTRACT_BIT(instr, 22);
	opc = (instr >> 29) & ONES(2);
	sf = EXTRACT_BIT(instr, 31);

	if (N == 1 && sf == 0)
		return arm_decode_unknown(instr, type, immediate, ops_list);

	*type = INSN_OTHER;
	*immediate = (decode_bit_masks(N, imms, immr, true) >> 64);

	if (opc & 1)
		return 0;

	if (rd != CFI_SP)
		return 0;

	*type = INSN_STACK;

	if (rn != CFI_SP) {
		op = calloc(1, sizeof(*op));
		list_add_tail(&op->list, ops_list);

		op->dest.type = OP_DEST_REG;
		op->dest.offset = 0;
		op->dest.reg = rd;
		op->src.type = OP_SRC_REG;
		op->src.offset = 0;
		op->src.reg = rn;
	}

	op = calloc(1, sizeof(*op));
	list_add_tail(&op->list, ops_list);

	op->dest.type = OP_DEST_REG;
	op->dest.offset = 0;
	op->dest.reg = rd;

	op->src.type = OP_SRC_AND;
	op->src.offset = 0;
	op->src.reg = rd;

	return 0;
}
```

有两个函数：`decode_bit_masks` 和 `arm_decode_logical`，其中前者是在 `bit_operations.c` 文件中实现，后者调用了前者。

`decode_bit_masks` 返回一个 bitmask immediate。其中对于 32 位返回`imms:immr`，64 位返回`N:imms:immr`。可以查看 Arm 的实现(https://developer.arm.com/documentation/ddi0596/2020-12/Shared-Pseudocode/AArch64-Instrs?lang=en#impl-aarch64.DecodeBitMasks.4).

在函数 `arm_decode_logical.c` 中实现。
