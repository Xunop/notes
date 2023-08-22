# arm64 指令

arm64 方面一个非常好非常全的文章[arm64-assembly](https://modexp.wordpress.com/2018/10/30/arm64-assembly/)

这里记录的并没有上面那篇文章多。

记录一下常见的 arm64 指令或是一些疑惑的地方。

## stp[^1]

Store Pair of Registers.

post-index:

```
stp x19, x20, [x8], #16
```

与下面这个相等：

```
stp x19, x20, [x8]
add x8, x8, #16
```

也就是在存储之后对寄存器进行相加操作。

pre-index:

```
stp x19, x20, [x8, #16]!
```

与下面指令相等：

```
add x8, x8, #16
stp x19, x20, [x8]
```

先对寄存器进行相加操作再存储。

这两个操作常用于调用函数时压栈或者弹栈：

```
some_func:
    // store two 64-bit words at [sp-16] and subtract 16 from sp
    stp x29, x30, [sp, #-0x16]!
    // ...
    // load two 64-bit words from stack, advance sp by 16
    ldp x29, x30, [sp], #0x16
    ret
```

[^1]: [explain-arm64-insn](https://stackoverflow.com/questions/64638627/explain-arm64-instruction-stp)
