# 关于交叉编译的一些记录

编译的话文档有很多，这里记录一下自己交叉编译的一些命令。

## 编译前置条件

[前置条件](https://kernelnewbies.org/OutreachyfirstpatchSetup)

需要安装以下工具：

```
vim libncurses5-dev gcc make git exuberant-ctags libssl-dev bison flex libelf-dev bc dwarves zstd git-email
```

## 安装交叉编译工具链

跨平台编译需要安装交叉编译工具链：

```sh
sudo pacman -S aarch64-linux-gnu-gcc aarch64-linux-gnu-binutils aarch64-linux-gnu-glibc aarch64-linux-gnu-linux-api-headers
```

## 选择编译的配置

```sh
cp /boot/config-`uname -r`* .config
```

```sh
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- olddefconfig
```

有些发行版的内核中会自带一份自己发行版的一份内核配置：

```sh
ls arch/arm64/configs
```

```sh
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- xxx_defconfig
```

> 这会在 kernel 根目录生成一份 .config 文件，里面有发行版需要的所有默认配置。

可能需要自己更改一下配置：

```sh
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- menuconfig
```

## 编译内核

```sh
make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

更多信息参考 kernel 文档。
