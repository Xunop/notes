# linux unwind 梳理

将 linux unwind 的一些概念进行梳理。

## Stack unwinding

在计算机科学中，“unwinder”通常指的是堆栈展开器（stack unwinder），它是一种用于实现堆栈展开的算法或工具。

Stack unwinding 是一种通用的概念，它指的是在程序发生异常或错误时，回退调用栈的过程，释放资源并返回到适当的异常处理程序或调用点。
它是一种异常处理机制，可用于各种编程语言和环境。

Stack unwinding 可以获取 stack trace, 用于 debugger 等一些操作。

### Frame Pointer Unwinds


### ORC unwinder

ORC 展开元数据生成：这是一种更快、更精确的堆栈展开方法。
ORC（Online Relocation Compiler）是一种 Linux 内核中的代码生成框架，它能够动态生成代码，从而提高系统性能。
objtool 利用 ORC 生成的元数据来展开堆栈，比使用基于帧指针的展开方法更快、更精确。
基于帧指针的展开方法需要在函数调用时保存帧指针的值，并在返回时重新加载它，这会增加代码大小和执行时间。
而 ORC 展开方法则不需要保存和加载帧指针，因此更加高效。
