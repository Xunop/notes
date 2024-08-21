# 给虚拟机替换内核

因为开源之夏项目写的是 arm64 架构上的内核，本机使用的是 x86，所以只能开虚拟机进行测试。我之前的笨方法安装是将所有 kernel 根目录的文件全都使用 `rsync` 同步到虚拟机，然后在虚拟机里面使用 `make modules_install install` 和 `make install`。
简直不要太笨。每次修改代码都要 `rsync` 一次。后来问了一下开源之夏的导师，才想起来可以将虚拟机镜像挂载然后在本机安装内核进虚拟机镜像中。在这里记录一下步骤。

挂载虚拟机镜像

```sh
sudo guestmount -a img.qcow2 -i --rw /mnt/vm
```

安装 module

```sh
sudo make ARCH=arm64 INSTALL_MOD_PATH=/mnt/vm modules_install
```

安装内核

```sh
sudo make ARCH=arm64 INSTALL_PATH=/mnt/vm/boot install
```

卸载虚拟机镜像

```sh
sudo guestunmount /mnt/vm
```

之后进可以进入虚拟机更新 grub 等一些操作。

ps: 可以像磁盘一样挂载也就可以修改磁盘文件，所以可以通过这种方式修改虚拟机里的文件，包括但不限于修改 root 用户密码。
