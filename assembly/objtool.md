# Objtool

## 基础理论

我在测试时所用的几个命令：

```sh
gcc -Og -S test.c -o a.s
```

```sh
as a.s -o a.o
```

```sh
objdump -d a.o
```

```sh
objtool --orc a.o
```

```sh
objtool --dump a.o
```

有这样一段代码，此代码命名为 `c.s`:

```asm
  .text
  .section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
  .string "Hello, world!2.0"
  .text
  .globl main
  .type main, @function
main:
.LFB14:
  subq $8, %rsp
  leaq .LC0(%rip), %rdi
  call puts@PLT
  addq $8, %rsp
  ret
.LFE14:
  .size	main, .-main
```

> 经过测试，手写的汇编代码必须带上 `.section	.rodata.str1.1,"aMS",@progbits,1` 及上面所示的 lable，才能让`objtool`生成 ORC 数据。

生成目标文件，将其重定向为 c.o 文件：

```sh
as c.s -o c.o
```

使用`objdump`命令反汇编查看地址：

```
❯ objdump -d c.o

c.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:   48 83 ec 08             sub    $0x8,%rsp
   4:   48 8d 3d 00 00 00 00    lea    0x0(%rip),%rdi        # b <main+0xb>
   b:   e8 00 00 00 00          call   10 <main+0x10>
  10:   48 83 c4 08             add    $0x8,%rsp
  14:   c3                      ret
```

利用`objtool`生成 ORC 数据：

```
❯ ./objtool --orc c.o
```

dump 一下 ORC 数据：

```
❯ ./objtool --dump c.o
.text+0:type:call sp:sp+8 bp:(und) signal:0
.text+4:type:call sp:sp+16 bp:(und) signal:0
.text+14:type:call sp:sp+8 bp:(und) signal:0
.text+15:type:(und) sp:(und) bp:(und) signal:0
```

---

修改`c.s`文件：

```asm
  .text
  .section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
  .string "Hello, world!2.0"
  .text
  .globl main
  .type main, @function
main:
.LFB14:
  subq $8, %rsp
  ; 这里改变了
  push %rbp
  push %rbp
  pop %rbp
  pop %rbp
  leaq .LC0(%rip), %rdi
  call puts@PLT
  addq $8, %rsp
  ret
.LFE14:
  .size	main, .-main
```

重复上述操作。

`as c.s -o c.o`

`./objtool --orc c.o`

执行 `objdump -d c.o`

```
❯ objdump -d c.o

c.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <main>:
   0:   48 83 ec 08             sub    $0x8,%rsp
   4:   55                      push   %rbp
   5:   55                      push   %rbp
   6:   5d                      pop    %rbp
   7:   5d                      pop    %rbp
   8:   48 8d 3d 00 00 00 00    lea    0x0(%rip),%rdi        # f <main+0xf>
   f:   e8 00 00 00 00          call   14 <main+0x14>
  14:   48 83 c4 08             add    $0x8,%rsp
  18:   c3                      ret
```

执行 `./objtool --dump c.o`, 输出：

```sh
❯ ./objtool --dump c.o
.text+0:type:call sp:sp+8 bp:(und) signal:0
.text+4:type:call sp:sp+16 bp:(und) signal:0
.text+5:type:call sp:sp+24 bp:prevsp-24 signal:0
.text+6:type:call sp:sp+32 bp:prevsp-24 signal:0
.text+7:type:call sp:sp+24 bp:prevsp-24 signal:0
.text+8:type:call sp:sp+16 bp:(und) signal:0
.text+18:type:call sp:sp+8 bp:(und) signal:0
.text+19:type:(und) sp:(und) bp:(und) signal:0
```

`objdump` 输出中新增了：

```asm
   4:   55                      push   %rbp
   5:   55                      push   %rbp
   6:   5d                      pop    %rbp
   7:   5d                      pop    %rbp
```

因为在`c.s`中新增了几次栈的`push`、`pop` 操作，将此次修改的输出结果与未修改前进行对比，可以发现 `objtool` 中的 ORC 数据多了以下四条：

```
.text+5:type:call sp:sp+24 bp:prevsp-24 signal:0
.text+6:type:call sp:sp+32 bp:prevsp-24 signal:0
.text+7:type:call sp:sp+24 bp:prevsp-24 signal:0
.text+8:type:call sp:sp+16 bp:(und) signal:0
```

第一个 `.text+0:type:call sp:sp+8 bp:(und) signal:0` 似乎是由于 `libc` C runtime support code 原因，`call` 指令调用 `main` 函数时 `%rsp` 将指向栈顶，当执行 `call` 指令后，会将 8 byte 的**返回地址**压入栈中。

> 这个解释基于 C 语言，纯汇编中不知道如何处理。了解还是太少:(。是因为`objtool`的原因，会在函数入口把栈状态初始化成这样。

第二个 `sp:sp+16` 是 `sub $0x8,%rsp` 执行的结果。之后执行几次 `push`， 栈指针 `sp` 就加几次。所以一直加到 32。

其中的 `text + 5` 表示 `4 + 1` 指令的地址 + 1。以第一个 `push` 为例，`text+5` 表示 `objdump` 中的 `4: 55 push %rbp`，这里的数字都是偏移量。

模拟栈的图：

```
+--------------------------------------+
|                                      |
|                                      |
|            初始状态                  |
|                                      |
+--------------------------------------+ <--------------+ rbp
|                                      |
|            返回地址                  | <--------------+ sp:sp+8
|                                      |
+--------------------------------------+ <--------------+ rsp

+--------------------------------------+
|                                      |
|                                      |
|            初始状态                  |
|                                      |
+--------------------------------------+ <--------------+ rbp
|                                      |
|                                      | <--------------+ sp:sp+8
|            返回地址                  |
|                                      |
+--------------------------------------+
|                                      |
|          sub $0x8,% rsp              | <-------------+ sp:sp+16
|                                      |
|                                      |
+--------------------------------------+ <--------------+ rsp

+--------------------------------------+
|                                      |
|                                      |
|            初始状态                  |
|                                      |
+--------------------------------------+ <--------------+ rsp
|                                      |
|                                      | <--------------+ sp:sp+8
|            返回地址                  |
|                                      |
+--------------------------------------+
|                                      |
|          sub $0x8,% rsp              | <-------------+ sp:sp+16
|                                      |
|                                      |
+--------------------------------------+ <--------------+ rbp
|                                      |
|           push % rbp                 | <-------------+ sp:sp+24
|                                      |
+--------------------------------------+
```

基指针 `bp:prevsp-24`：初始化 8，sub 8, push rbp 三个加起来得出 24。

## kernel 代码实现

orc unwind 流程：

```
+----------+     +------------+     +------------+     +------------+     +------------+
|          |     |            |     |            |     |            |     |            |
| ELF file +---->+   指令流   +---->+ 堆栈信息   +---->+ ORC段      +---->+ 运行时堆栈 |
+----------+     +------------+     +------------+     +------------+     +------------+
            指令解析          指令检查            ORC生成            ORC推栈
            decode            check               gfenerate          unwinder
```

> ELF 文件就是编译 C 程序时生成的可执行文件。ELF 文件以 ELF 头（ELF Header）开始，其中包含了关于文件本身的信息，如文件类型、体系结构、入口点地址等。紧接着是节头表（Section Header Table），它列出了 ELF 文件中的所有节（sections）。每个节都有自己的名称、大小和位置等属性。常见的节包括代码段（.text）、数据段（.data）和未初始化的数据段（.bss）等。然后是程序头表（Program Header Table），它描述了 ELF 文件在内存中的布局。每个程序头（Program Header）对应一个段（segment），它指示操作系统如何加载 ELF 文件的不同部分到内存中。例如，加载代码段、数据段和未初始化的数据段等。最后，ELF 文件的剩余部分是实际的代码和数据，它们根据 ELF 文件的布局被加载到内存中。

armv8 二进制位表示（C4 章节）：https://developer.arm.com/documentation/ddi0487/latest/

在 `tools/objtool/check.h` 中有这样一个 `instruction` 结构体：

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

| Decode fields op0 | Decode group or instruction page   |
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
#define NR_DP_IMM_SUBCLASS	8
#define INSN_MOVE_WIDE	0b101
#define INSN_BITFIELD	0b110
#define INSN_EXTRACT	0b111
#define INSN_PCREL	0b001	//0b00x

static arm_decode_class aarch64_insn_dp_imm_decode_table[NR_DP_IMM_SUBCLASS] = {
	[0 ... INSN_PCREL]	= arm_decode_pcrel,
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
#define EXTRACT_BIT(X, N)	(((X) >> (N)) & ONES(1))
// 符号扩展
#define SIGN_EXTEND(X, N)	sign_extend((X), (N))

// '~' 为取反
// 0UL 表示把数字0转换为无符号长整型数
// ~0UL 表示生成一个具有所有位都为1的掩码
static inline unsigned long sign_extend(unsigned long x, int nbits)
{
	return ((~0UL + (EXTRACT_BIT(x, nbits - 1) ^ 1)) << nbits) | x;
}
```
