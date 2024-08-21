# QEMU-aarch64 启动！（使用 QEMU 运行 aarch64 虚拟机）

## 机器信息

```sh
echo "OS: ${OSTYPE:-N/A} | Vendor: ${VENDOR:-N/A} | Machine: ${MACHTYPE:-N/A} | CPU: ${CPUTYPE:-N/A} | Processor: ${$(uname -p 2>/dev/null):-N/A} | Hardware: ${$(uname -m 2>/dev/null):-N/A}"
```

```
OS: linux-gnu | Vendor: pc | Machine: x86_64 | CPU: x86_64 | Processor: unknown | Hardware: x86_64
```

## 前置条件

```sh
sudo pacman -S edk2-aarch64 qemu-system-aarch64
```

> `qemu-emulators-full` 会提供支持架构的全系统模拟（如 `qemu-system-aarch64` 或 `qemu-x86_64` ）
> `edk2-aarch64` 提供 uefi 固件

## 创建 flash 镜像

```sh
dd if=/dev/zero of=flash1.img bs=1M count=64
dd if=/dev/zero of=flash0.img bs=1M count=64
dd if=/usr/share/edk2/aarch64/QEMU_EFI.fd of=flash0.img conv=notrunc
```

> `/usr/share/edk2/aarch64/QEMU_EFI.fd` 这边不同的发行版会存放在不同的位置

## 创建镜像文件

```sh
qemu-img create -f qcow2 vm.qcow2 32G
```

## 虚拟机，启动

### QEMU[^1]

```bash
img_path=vm.qcow2
iso_path=vm.iso

qemu-system-aarch64 -nographic -machine virt,gic-version=max -m 16G -cpu max -smp 4 \
-netdev user,id=vnet,hostfwd=:127.0.0.1:0-:22 -device virtio-net-pci,netdev=vnet \
-drive file=$img_path, -device virtio-blk,drive=drive0,bootindex=0 \
-drive file=$iso_path,if=none,id=drive1,cache=writeback -device virtio-blk,drive=drive1,bootindex=1 \
-drive file=flash0.img,format=raw,if=pflash -drive file=flash1.img,format=raw,if=pflash
```

> 如果这样无法启动，那就用 libvirt 咯。

### libvirt

```bash
img_path=vm.qcow2
iso_path=vm.iso

virt-install \
  --name arm64-vm-5 \
  --arch aarch64 \
  --machine virt \
  --os-variant linux2022 \
  --ram 16384 \
  --vcpus 8 \
  --import \
  --disk $img_path \
  --graphics none \
  --network user,model=virtio \
  --features acpi=off \
  --boot uefi \
  --location $iso_path
```

查看虚拟机：

```sh
virsh list
```

开启虚拟机 vm：

```sh
virsh start vm
```

关闭虚拟机 vm：

```sh
virsh shutdown vm
```

强制关闭虚拟机 vm：

```sh
virsh destroy vm
```

删除虚拟机 vm：

```sh
virsh undefine vm
```

> 或许可能会出现一个关于 `nvram` 的错误，那么就需要加上 `nvram` 这个参数：
> `virsh undefine vm --nvram`

[^1]: [How to launch ARM aarch64 VM with QEMU from scratch.](https://futurewei-cloud.github.io/ARM-Datacenter/qemu/how-to-launch-aarch64-vm/)
