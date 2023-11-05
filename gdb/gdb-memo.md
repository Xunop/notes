# gdb 常用操作记录

因为写了一段时间内核中的 objtool ，出现一些问题时需要使用 gdb 进行调试。这里记录一下自己的常用操作。学习建议还是看 [gdb manual](https://sourceware.org/gdb/current/onlinedocs/gdb.html/)，这是一点点笔记，gdb 的使用那可真是太多了。

## gdb 配置

gdb 有一个配置文件 `.gdbinit` ，可以在里面修改 gdb 配置。我的配置：

```
set pagination off
set history save on
set history expansion on
```

> 禁止分页
> 开启历史记录
> 可以使用 ! 执行上一条命令

## 常用操作

我调试的东西需要传递参数给它：

```
gdb --args ./tools/objtool/objtool -o arch/arm64/kernel/debug-monitors.o
```

`start`, `next` `info` `print` 一些就不记录在这了。

### 断点

打断点：

```sh
b check.c:1111
```

针对某个函数：

```sh
b func
```

### 栈帧

查看栈帧（ backtrace/bt ）：

```sh
bt num
```

> 0 表示当前正在执行的函数。
> num 为查看栈帧的数量，不加 num 则显示全部。
> 如果 num 是正数，则栈帧从 0 开始计数，如果是负数，则从最大的栈帧编号开始计数。一个是正向，一个是反向。

```
(gdb) bt
#0  has_modified_stack_frame (state=state@entry=0x7fffffffd9b0, insn=0x555555e742e0) at check.c:2721
#1  0x0000555555560cb0 in validate_return (state=0x7fffffffd9b0, insn=0x555555e742e0, func=0x555555e59070) at check.c:3550
#2  validate_branch (file=file@entry=0x5555555fbf00 <file>, func=0x555555e59070, insn=0x555555e742e0,
    insn@entry=0x555555e73f60, state=...) at check.c:3739
#3  0x00005555555622a2 in validate_symbol (state=0x7fffffffdc20, sym=0x555555e59070, sec=0x555555e05b50, file=<optimized out>)
    at check.c:4281
#4  validate_section (file=file@entry=0x5555555fbf00 <file>, sec=sec@entry=0x555555e05b50) at check.c:4300
#5  0x0000555555564701 in validate_functions (file=0x5555555fbf00 <file>) at check.c:4341
#6  check (file=file@entry=0x5555555fbf00 <file>) at check.c:4627
#7  0x0000555555567e4c in objtool_run (argc=<optimized out>, argc@entry=3, argv=argv@entry=0x7fffffffe058)
    at builtin-check.c:225
#8  0x00005555555587d7 in main (argc=3, argv=0x7fffffffe058) at objtool.c:149
```

```
(gdb) bt -1
#8  0x00005555555587d7 in main (argc=3, argv=0x7fffffffe058) at objtool.c:149
```

查看帧信息：

```sh
info frame num
```

> num 为栈帧编号。
> 简写 `i f num`

查看当前帧的所有局部变量和函数参数：

```
info locals
```

```
info args
```

切换帧：

```
frame num
```

> num 是栈帧编号。简写 `f num`

### 结构体

查看结构体中的字段及类型：

```
ptype struct
```

```
(gdb) ptype cfi
type = struct cfi_state {
    struct hlist_node hash;
    struct cfi_reg regs[32];
    struct cfi_reg vals[32];
    struct cfi_reg cfa;
    int stack_size;
    int drap_reg;
    int drap_offset;
    unsigned char type;
    _Bool bp_scratch;
    _Bool drap;
    _Bool signal;
    _Bool end;
} *
```

查看结构体中的所有字段的值：

```
(gdb) p cfi
$9 = (struct cfi_state *) 0x7fffffffd9b0

(gdb) p *((struct cfi_state *) cfi)
$10 = {hash = {next = 0x0, pprev = 0x0}, regs = {{base = -1, offset = 0} <repeats 32 times>}, vals = {{base = -1,
      offset = 0} <repeats 32 times>}, cfa = {base = 31, offset = 0}, stack_size = 0, drap_reg = -1, drap_offset = -1,
  type = 2 '\002', bp_scratch = false, drap = false, signal = false, end = false}
```

> 强转一下。

### 调用函数

```
p func
```

```
(gdb) p offstr(insn->sec, insn->offset)
$13 = 0x555555ea0330 "mdscr_write+0x0"
```

### 多线程

- `info inferiors` 查看进程列表
- `attach pid`绑定进程 id
- `inferior num` 切换到指定进程上进行调试
- `print $_exitcode` 显示进程退出时的返回值
- `set follow-fork-mode child` 追踪子进程
- `set follow-fork-mode parent` 追踪父进程
- `set detach-on-fork on fork` 调用时只追踪其中一个进程
- `set detach-on-fork off fork` 调用时会同时追踪父子进程
- `set schedule-multiple on` 调试某进程时，其他进程正常执行
