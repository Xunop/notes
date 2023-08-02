# 使用 qemu-nbd 对虚拟机进行扩容[^1]

## 使用 qemu-img 扩容

```sh
qemu-img resize disk.qcow2 +10G
```

或者直接指定虚拟磁盘的大小

```sh
qemu-img resize disk.qcow2 64G
```

## 通过使用 NBD 修改磁盘镜像分区

Nbd 是 [Network Block Device](https://www.kernel.org/doc/Documentation/blockdev/nbd.txt)
的缩写：它是一种允许一台机器访问另一台机器上的块设备的协议。在 linux 中，这一功能由 nbd 模块实现，需要加载该模块：

```sh
sudo modprobe nbd
```

检查是否开启成功：

```sh
sudo lsmod | grep nbd
```

> ~~遇到错了怎么办？不知道诶~~

加载模块之后，挂载这个磁盘：

```sh
sudo qemu-nbd -c /dev/nbd0 disk.qcow2
```

> [qemu-nbd look here](https://manpages.debian.org/bullseye/qemu-utils/qemu-nbd.8.en.html)

之后就可以使用 `cfdisk`/`gparted` 进行分区：

```sh
gparted /dev/nbd0
```

> 经典问题，使用 root 用户运行 GUI。参考 [Arch Wiki](https://wiki.archlinux.org/title/Running_GUI_applications_as_root)
> 我使用 `sudo -E gparted /dev/nbd0`

## 往 image 里面塞一些文件

既然都可以分区，那自然可以通过这种方式往虚拟机里面塞东西啦。

执行完`qemu-ndb -c /dev/nbd0 disk.qcow2` 之后，执行以下命令将其挂载到本地电脑上：

```sh
sudo mount /dev/nbd0px /mnt
```

> `nbd0px` 其中的 x 表示一个数字。

之后跟挂载硬盘一样操作。

[^1]: [参考文章 1](https://linuxconfig.org/how-to-resize-a-qcow2-disk-image-on-linux)
