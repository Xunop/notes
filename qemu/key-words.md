# 关键信息

- vhost-user 允许将 VIRTIO 设备实现为 QEMU 外的单独进程，使设备仿真代码能用任何编程语言编写，并与 QEMU 之外的其他仿真器共享设备仿真代码。
- vhost-user 通过直接访问客户 RAM 实现良好的性能，但由于安全原因或主机平台支持限制，不总是希望暴露客户 RAM。
- 目前，QEMU 配置客户端，使得 vhost-user 设备直接在 I/O 请求准备好时得到通知，并在完成 I/O 请求时直接通知客户端。项目将添加一种模式，其中 QEMU 拦截 I/O 请求，复制数据缓冲区，然后转发通知。
- 该项目将添加一种 vhost-user 设备的替代模式，其中客户 RAM 不暴露。
- 新增一种 vhost-user 设备模式，不将客户 RAM 暴露为共享内存。
- 项目将重用 Shadow Virtqueue 实现并将其集成到 vhost-user 代码中。确保现有的 vhost-user 设备可以与内存隔离一起工作，不需要 vhost-user 协议更改。

## Virtio

Virtio 是一个开放标准，定义了一种用于驱动程序与不同类型设备（块设备和网络适配器）通信的协议。它最初作为一个由虚拟机监视器实现的半虚拟化设备的标准而开发，但也可以用于将任何符合规范的设备（真实或模拟的）与驱动程序进行通信。

即 virtio 被开发为客户机访问主机设备的接口标准。它定义了一种通信协议和数据结构，使得虚拟机可以与虚拟化设备进行交互。

> Virtio is an open standard that defines a protocol for communication between drivers and devices of different types, see Chapter 5 ("Device Types") of the virtio spec. Originally developed as a standard for paravirtualized devices implemented by a hypervisor, it can be used to interface any compliant device (real or emulated) with a driver.

> https://docs.kernel.org/driver-api/virtio/virtio.html

虚拟化网络中有两个重要概念：

1. 控制层 (Control plane) ：控制层用于主机和客户机之间的能力交换协商，既用于建立数据层也用于终止数据层。在控制层中，主要进行的是与网络功能相关的参数交换和协商，例如设备的能力和配置。

2. 数据层 (Data plane) ：数据层用于在主机和客户机之间传输实际的数据（数据包）。在数据层中，主要进行的是实际的数据传输，即网络数据包在主机和客户机之间的交换和传递。

Virtio 提供了一种通信机制，使得虚拟机可以与虚拟化网络设备进行交互，包括在控制层和数据层上。

> PS: 这两个概念是不是计算机网络中的“控制层”和“数据层”？有些疑惑。应该只是类似的概念？

Virtio 可以分成两个部分：

1. virtio 规范 (virtio spec) ：
   [virtio](https://docs.oasis-open.org/virtio/virtio/v1.3/virtio-v1.3.html) 规范由 [OASIS](https://www.oasis-open.org/org) 维护，它定义了如何在客户机和主机之间创建控制层 (control plane) 和数据层 (data plane) 。例如，数据层 (data plane) 由缓冲区 ( buffers) 和环形队列布局 (rings layout) 组成，这些细节在规范中进行了详细描述。

2. vhost 协议 (vhost protocol) ：
   vhost 协议是一种协议，允许将 virtio 数据层的实现外部化到另一个元素（用户进程或内核模块）中，以提高性能。

出于性能考虑，virtio 控制层 (control plane) 是基于 virtio 规范在 QEMU 进程中实现的，但数据层却没有。

> The control plane for virtio is implemented in the qemu process based on the virtio spec however the data plane is not.

> If we simply implemented the virtio spec data plane in qemu we’d have a context switch for every packet going from the kernel to the guest, and vice versa. This is an expensive operation that adds latency and requires more processing time (remember that qemu is yet another Linux process), so we want to avoid it if possible.

所以 QEMU 只是实现了控制层 (control plane) ， 并没有实现数据层 (data plane) 。这时候需要用到 vhost 协议，它使我们能够绕过 qemu 进程直接从内核（主机）到 guest 虚拟机的数据层 (data plane)。

![virtio vhost relationship](./resource/virtio.png)

## Vhost Protocol

Vhost 协议在内核实现叫 vhost-net ，在用户空间 (user space) 实现叫 vhost-user 。

## Vhost-user Protocol

vhost-user 协议旨在补充 Linux 内核中用于控制 vhost 实现的 ioctl 接口。它实现了建立控制平面，以在同一主机上的用户空间进程之间建立 virtqueue 共享所需的控制平面。该协议通过 Unix 域套接字进行通信，在消息的辅助数据中共享文件描述符。

> This protocol is aiming to complement the ioctl interface used to control the vhost implementation in the Linux kernel. It implements the control plane needed to establish virtqueue sharing with a user space process on the same host. It uses communication over a Unix domain socket to share file descriptors in the ancillary data of the message.

> 注意，这个协议是负责通信。

这个协议的通信有“前端”和“后端”，前端是共享其 virtqueues 的应用程序，此处是 QEMU。后端是 virtqueues 的消费者（消耗 virtio 队列的外部进程，例如运行在用户空间的软件以太网交换机（如 Snabbswitch），或者用于处理对虚拟磁盘的读写的块设备后端）。

Vhost-user 负责通信，那它的信息会具有一定的格式。

我觉得不如直接看文档：https://www.qemu.org/docs/master/interop/vhost-user.html

---

- [Introduction to virtio-networking and vhost-net ](https://www.redhat.com/en/blog/introduction-virtio-networking-and-vhost-net)
