# stack unwinding

将 linux 中的 stack unwinding 的一些概念进行梳理。

## Stack unwinding

在计算机科学中，“unwinder”通常指的是堆栈展开器（stack unwinder），它是一种用于实现堆栈展开的算法或工具。

Stack unwinding 是一种通用的概念，它指的是在程序发生异常或错误时，回退调用栈的过程，释放资源并返回到适当的异常处理程序或调用点。
它是一种异常处理机制，可用于各种编程语言和环境。

Stack unwinding 可以获取 stack trace, 用于 debugger 等一些操作。

### Frame Pointer Unwinds

这是最简单、最经典的 stack unwinding：固定一个寄存器在 frame pointer(在 x86-64 上为 RBP)，
函数把在汇编代码的 prologue 处把 frame pointer 放入栈帧中，并更新 frame pointer 为保存的 frame pointer 的地址。 frame pointer 值和栈上保存的值形成了一个单链表。
获取初始 frame pointer 值(builtin_frame_address)后，不停解引用 frame pointer 即可得到所有栈帧的 frame pointer 值。

例子[^1]：

```c
#include <stdio.h>
[[gnu::noinline]] void qux() {
  void **fp = __builtin_frame_address(0);
  for (;;) {
    printf("%p\n", fp);
    void **next_fp = *fp;
    if (next_fp <= fp)
      break;
    fp = next_fp;
  }
}
[[gnu::noinline]] void bar() { qux(); }
[[gnu::noinline]] void foo() { bar(); }
int main() { foo(); }
```

通过这个代码的汇编我们可以清晰的看见 stack unwinding 的处理流程。
代码太长，放到 github 仓库中，在一些地方写了注释：[cs.s](https://github.com/Xunop/notes/blob/main/linux/stack_unwinding/cs.s)

这是一种软件的抽象：过程(procedures)，我在这篇博客中有记录：[过程](https://blog.fooo.in/2023/06/22/CS/cs-procedure)

### DWARF

DWARF 是一种调试信息格式，旨在提供在调试过程中对程序的可执行文件或共享库进行符号级调试的能力。
它定义了一套结构化的数据格式，用于描述源代码的编译过程、类型信息、变量、函数、源代码位置等。
DWARF 格式通常与编译器一起使用，编译器会在可执行文件或共享库中嵌入 DWARF 调试信息。

可以在 [cs.s](https://github.com/Xunop/notes/blob/main/linux/stack_unwinding/cs.s) 这个文件中看到有以 `.cfi` 开头的信息。
这些信息就是 DWARF 格式。

关于这些指令的意思请查看：https://sourceware.org/binutils/docs/as/CFI-directives.html

这里截取部分代码来解释一下 `cfi` 指令：

```assembly
main:
.LFB14:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$0, %eax
	call	foo
	movl	$0, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE14:
	.size	main, .-main
	.ident	"GCC: (GNU) 13.1.1 20230429"
	.section	.note.GNU-stack,"",@progbits
```

我在看 `.cfi` 部分指令的时候对 `subq $8, %rsp` 和 `.cfi_def_cfa_offset 16` 这一段感到很疑惑，为什么它不是 `cfi_def_cfa_offset 8`？[^2]

`main()` 函数被`lib` C runtime support 处的代码调用，`call` 指令被执行，`%rsp` 将指向栈顶：

```
:                :                              ^
|    一些数据    | <--- %rsp                    | increasing addresses
+----------------+                              |
```

此时 `%rsp` 的值是调用栈帧的处的栈指针的值，也就是 CFA。

> 我们需要了解两个定义：CFI 和 CFA。
> CFI: Call Frame Information (CFI)， 一种用于描述栈帧信息的调试信息。
> CFA: Canonical Frame Address， 栈帧的规范地址。它是一个在调试过程中用于引用当前函数的栈帧的地址，CFA 可以通过 CFI 指令进行计算。

当 `call` 指令被执行之后，将会压入 8 个字节的返回地址到栈中：

```
:                :
|    一些信息    | <--- CFA
+----------------+
|    返回地址    | <--- %rsp == CFA - 8
+----------------+
```

现在我们进入了 `main` 函数中，在里面执行 `subq	$8, %rsp` 扩展为自己保留 8 字节的栈空间：

```
:                :
|    一些信息    | <--- CFA
+----------------+
|    返回地址    |
+----------------+
|    预留空间    | <--- %rsp == CFA - 16
+----------------+
```

`cfi_def_cfa_offset 16` 就是这样计算出来的。8 字节用于保存返回地址，另外 8 字节用于保存上一个栈帧的基指针。

### ORC unwinder

Linux kernel 在 x86-64 平台上使用的自己的 unwinder[^3]。

这是一种更快、更精确的堆栈展开方法。

上面的两个方法可以同时组合使用，所以在 cs.s 文件中可以看到两种方法组合在一起。

ORC（Online Relocation Compiler）是一种 Linux 内核中的代码生成框架，它能够动态生成代码，从而提高系统性能。
objtool 利用 ORC 生成的元数据来展开堆栈，比使用基于帧指针（frame pointer）的展开方法更快、更精确。
基于帧指针的展开方法需要在函数调用时保存帧指针的值，并在返回时重新加载它，这会增加代码大小和执行时间。
而 ORC 展开方法则不需要保存和加载帧指针，因此更加高效。

同时 ORC 的调试信息比 DWARF 更简单："It gets rid of the complex DWARF CFI state machine and also gets rid of the tracking of unnecessary registers. "[^3]

ORC 数据由 objtool 生成，其中包含由 unwind tables 组成的数据。这些 unwind tables 是通过进行编译时的**堆栈元数据验证**（CONFIG_STACK_VALIDATION）(stack metadata validation)生成的。在分析.o 文件的所有代码路径之后，objtool 确定了文件中每个指令地址的堆栈状态信息，并将该信息输出到.o 文件的.orc_unwind 和.orc_unwind_ip 节中。

以下的 orc.o 文件由上方 cs.c 文件生成。生成堆栈状态信息：

```bash
./objtool --orc orc.o
```

查看 orc.o 文件中各个段的内容，省略前面部分内容，只贴出了 orc 部分：

```bash
$ objdump -s orc.o

orc.o:     file format elf64-x86-64
....
Contents of section .eh_frame:
 0000 14000000 00000000 017a5200 01781001  .........zR..x..
 0010 1b0c0708 90010000 1c000000 1c000000  ................
 0020 00000000 31000000 00410e10 8602430d  ....1....A....C.
 0030 06458303 670c0708 14000000 3c000000  .E..g.......<...
 0040 00000000 13000000 00440e10 4e0e0800  .........D..N...
 0050 14000000 54000000 00000000 13000000  ....T...........
 0060 00440e10 4e0e0800 14000000 6c000000  .D..N.......l...
 0070 00000000 18000000 00440e10 530e0800  .........D..S...
Contents of section .orc_unwind:
 0000 08000000 05021000 f0ff1502 1000f0ff  ................
 0010 14020800 00000502 10000000 05020800  ................
 0020 00000502 10000000 05020800 00000502  ................
 0030 10000000 05020800 00000502 00000000  ................
 0040 0000                                 ..
Contents of section .orc_unwind_ip:
 0000 00000000 00000000 00000000 00000000  ................
 0010 00000000 00000000 00000000 00000000  ................
 0020 00000000 00000000 00000000           ............
```

使用 `objtool` 查看元数据：

```bash
$ ./objtool --dump orc.o
.text+0:type:call sp:sp+8 bp:(und) signal:0
.text+1:type:call sp:sp+16 bp:prevsp-16 signal:0
.text+4:type:call sp:bp+16 bp:prevsp-16 signal:0
.text+30:type:call sp:sp+8 bp:(und) signal:0
.text+35:type:call sp:sp+16 bp:(und) signal:0
.text+43:type:call sp:sp+8 bp:(und) signal:0
.text+48:type:call sp:sp+16 bp:(und) signal:0
.text+56:type:call sp:sp+8 bp:(und) signal:0
.text+5b:type:call sp:sp+16 bp:(und) signal:0
.text+6e:type:call sp:sp+8 bp:(und) signal:0
.text+6f:type:(und) sp:(und) bp:(und) signal:0
```

`.text+0:type:call sp:sp+8 bp:(und) signal:0` 表示在代码段的偏移量为 0 处，发生了一个函数调用。栈指针 (sp) 在执行该指令时增加了 8 个字节，表示分配了一部分栈空间用于函数调用。基址指针 (bp) 未指定具体值，被标记为 (und)。signal 字段为 0，表示没有发生异常或信号。

[^1]: [stack unwinding - maskray](https://maskray.me/blog/2020-11-08-stack-unwinding)
[^2]: [GAS: Explanation of .cfi_def_cfa_offset - stackoverflow](https://stackoverflow.com/questions/7534420/gas-explanation-of-cfi-def-cfa-offset)
[^3]: [orc-unwinder - kernel](https://www.kernel.org/doc/html/next/x86/orc-unwinder.html)
