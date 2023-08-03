# 记录一下在 aarch64 架构上编译 kernel 的坑吧

编译的话文档有很多，这里记录一下自己的一些需求和踩的坑。以下并不是在 Arch 环境下。

## 编译前置条件

[前置条件](https://kernelnewbies.org/OutreachyfirstpatchSetup)

需要安装以下工具：

```
vim libncurses5-dev gcc make git exuberant-ctags libssl-dev bison flex libelf-dev bc dwarves zstd git-email
```

## 选择编译的配置

```
cp /boot/config-`uname -r`* .config
```

```
make olddefconfig
```

## generic
