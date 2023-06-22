# stack unwinding

将 linux unwinding 的一些概念进行梳理。

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

这个代码的汇编我们可以清晰的看见 stack unwinding 的处理流程。
代码太长，放到 github 仓库中，在一些地方写了注释：[cs.s](https://raw.githubusercontent.com/Xunop/notes/main/CS/cs.s)

这个就是 CSAPP 中所说的过程(procedures)，我在这篇博客中有记录：[过程](https://blog.fooo.in/2023/06/22/CS/cs-procedure)

### ORC unwinder

ORC 展开元数据生成：这是一种更快、更精确的堆栈展开方法。
ORC（Online Relocation Compiler）是一种 Linux 内核中的代码生成框架，它能够动态生成代码，从而提高系统性能。
objtool 利用 ORC 生成的元数据来展开堆栈，比使用基于帧指针的展开方法更快、更精确。
基于帧指针的展开方法需要在函数调用时保存帧指针的值，并在返回时重新加载它，这会增加代码大小和执行时间。
而 ORC 展开方法则不需要保存和加载帧指针，因此更加高效。

[^1]: 参考自[stack unwinding](https://maskray.me/blog/2020-11-08-stack-unwinding)
