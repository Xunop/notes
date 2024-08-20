# Linux Network sysctl parameters

## In Process（接收数据包）

1. 数据包到达NIC:

- MAC验证和FCS 检查: NIC 会检查数据包的 MAC 地址 (如果 NIC 不处于混杂模式) 和帧校验序列 (FCS)。如果 MAC 地址不匹配或 FCS 检查失败，数据包会被丢弃。
- DMA传输: 如果数据包通过了验证，NIC会使用直接内存访问 (DMA) 将数据包传输到内存中。内存区域由驱动程序预先准备并映射。
- 接收环形缓冲区: NIC 会将数据包的引用添加到接收环形缓冲区 (rx) 中。接收环形缓冲区是一个用于存储待处理数据包的队列。
- 硬件中断: NIC 会发出一个硬件中断 (IRQ) 通知 CPU 数据包已到达。

2. 驱动程序处理:

- 中断处理程序: CPU 会运行中断处理程序，该程序会执行驱动程序代码。
- NAPI 调度: 驱动程序会调度一个 NAPI (网络协议中断)，清除硬件中断并返回。
- 软中断: 驱动程序会发出一个软中断 (NET_RX_SOFTIRQ)。
- NAPI 循环: NAPI 会从接收环形缓冲区中轮询数据包，直到达到预设的时间限制或数据包数量限制。

3. Linux 内核处理:

- 内存分配: Linux 会为数据包分配一个 sk_buff 结构体，用于存储数据包的元数据。
- 元数据填充: Linux 会填充 sk_buff 结构体的元数据，包括协议类型、接口信息、MAC 头部等。
- 内核堆栈: Linux 会将 sk_buff 传递给内核堆栈 (netif_receive_skb)。
- 网络头部: 内核会设置网络头部，并将 sk_buff 克隆到其他地方 (例如 tcpdump) 用于调试。
- 流量控制: 数据包会进入一个由 netdev_max_backlog 参数定义的队列调度算法 (qdisc) 中。默认的队列调度算法由 default_qdisc 参数定义。
- IP 处理: 数据包会被传递给 IP 层 (ip_rcv)。
- 网络过滤器: 数据包会经过网络过滤器 (netfilter) 的 PREROUTING 阶段。
- 路由查找: 内核会查找路由表，决定数据包是进行转发还是本地处理。
- 本地处理: 如果数据包是本地处理的，它会经过网络过滤器 (LOCAL_IN) 阶段。
- L4 处理: 数据包会被传递给 L4 协议 (例如 TCP) 的处理函数 (例如 tcp_v4_rcv)。

4. 应用程序处理:

- 套接字查找: 内核会找到与数据包匹配的套接字。
- TCP 状态机: 数据包会进入 TCP 状态机。
- 接收缓冲区: 数据包会被添加到接收缓冲区中，缓冲区大小由 tcp_rmem 规则定义。
- 缓冲区自适应调整: 如果 tcp_moderate_rcvbuf 启用，内核会自动调整接收缓冲区的大小。
- 信号通知: 内核会向应用程序发送信号，通知应用程序有数据可读 (例如 epoll 或其他轮询机制)。
- 应用程序读取: 应用程序会醒来并读取数据。

## Out Process（发送数据包）

1. 应用程序发送数据:

- 数据包分配: 应用程序会使用 sendmsg 或其他方法发送数据包，并为数据包分配一个 sk_buff 结构体。
- 套接字写缓冲区: sk_buff 会被添加到套接字的写缓冲区中，缓冲区大小由 tcp_wmem 参数定义。

2. TCP 处理:

- TCP 头部构建: TCP 会构建 TCP 头部，包括源端口、目标端口和校验和。
- L3 处理: TCP 会调用 L3 处理函数 (例如 tcp_write_xmit 和 tcp_transmit_skb)，将数据包传递给 IP 层。

3. IP 处理:

- IP 头部构建: IP 层会构建 IP 头部，并调用网络过滤器 (LOCAL_OUT) 进行处理。
- 路由查找: IP 层会查找路由表，决定数据包的输出路径。
- 网络过滤器: 数据包会经过网络过滤器 (POST_ROUTING) 阶段。
- 数据包分片: 如果数据包太大，IP 层会将数据包分片 (ip_output)。

4. L2 处理:

- 发送函数: IP 层会调用 L2 发送函数 (dev_queue_xmit)，将数据包传递给网络接口卡 (NIC)。

5. NIC 处理:

- 发送队列: 数据包会进入 NIC 的发送队列 (txqueuelen)，队列调度算法由 default_qdisc 参数定义。
- 环形缓冲区: NIC 驱动程序会将数据包添加到发送环形缓冲区 (tx) 中。
- 软中断: 驱动程序会发出一个软中断 (NET_TX_SOFTIRQ)，通知 CPU 数据包已准备好发送。
- 硬件中断使能: 驱动程序会重新使能 NIC 的硬件中断。
- DMA 传输: 驱动程序会将数据包从内存映射到 DMA 区域，并由 NIC 通过 DMA 传输到网络。
- 硬件中断: NIC 发送完毕后，会发出一个硬件中断，通知 CPU 数据包已发送完成。

6. 驱动程序处理:

- 中断处理: 驱动程序会处理硬件中断，并关闭中断。
- NAPI 轮询: 驱动程序会调度 NAPI 轮询系统，处理接收数据包并释放内存。

## 环形缓冲区 (Ring Buffer - tx,rx)

接收环形缓冲区 (rx):

- 作用: 接收环形缓冲区用于缓冲从网络接收到的数据包。当 NIC 接收数据包的速度超过内核处理数据包的速度时，数据包会被放入接收环形缓冲区中等待处理。
- 为什么要使用接收环形缓冲区: 使用接收环形缓冲区可以避免数据包丢失，特别是当网络流量突然增加时。
- 调整大小: 如果出现数据包丢失或溢出 (即接收数据包的速度超过内核处理速度)，可以尝试增加接收环形缓冲区的大小。
- 副作用: 增加接收环形缓冲区的大小可能会增加延迟。

发送环形缓冲区 (tx):

- 作用: 发送环形缓冲区用于存储待发送的数据包。当应用程序发送数据包的速度超过 NIC 处理数据包的速度时，数据包会被放入发送环形缓冲区中等待发送。
- 为什么要使用发送环形缓冲区: 使用发送环形缓冲区可以避免数据包丢失，并提高网络性能。
- 调整大小: 如果出现数据包丢失或溢出，可以尝试增加发送环形缓冲区的大小。
- 副作用: 增加发送环形缓冲区的大小可能会增加延迟。

如何查看和调整环形缓冲区大小:

- 查看命令: `ethtool -g ethX` | --show-ring
- 调整命令: `ethtool -G ethX rx value tx value` | --set-ring (其中 value 是新的环形缓冲区大小)

如何监控环形缓冲区状态:

- 监控命令: `ethtool -S ethX | grep -e "err" -e "drop" -e "over" -e "miss" -e "timeout" -e "reset" -e "restar" -e "collis" -e "over" | grep -v "\: 0"` | --statistics
- 监控指标: 该命令会显示一些错误、丢包、溢出、超时等指标，可以用来监控环形缓冲区的状态。

## 中断合并 (Interrupt Coalescence, IC)

- 定义: 中断合并技术是指将多个硬件中断合并成一个中断，以减少 CPU 中断次数，从而提高 CPU 利用率和网络性能。
- 工作原理: NIC 会在收到一定数量的数据包或经过一定时间后，才会发出一个硬件中断。
- 参数: 中断合并技术通常使用以下参数来控制：
  rx-usecs: 接收数据包时，NIC 等待的时间 (微秒)，超过该时间才会发出中断。
  tx-usecs: 发送数据包时，NIC 等待的时间 (微秒)，超过该时间才会发出中断。
  rx-frames: 接收数据包时，NIC 等待的帧数，超过该帧数才会发出中断。
  tx-frames: 发送数据包时，NIC 等待的帧数，超过该帧数才会发出中断。

为什么要使用中断合并:

- 减少 CPU 使用率: 中断合并可以减少 CPU 处理中断的次数，从而降低 CPU 使用率。
- 提高网络吞吐量: 减少中断次数可以提高网络吞吐量，因为 CPU 可以花更多时间处理数据包，而不是处理中断。

中断合并的副作用:

- 增加延迟: 中断合并可能会增加延迟，因为 NIC 需要等待更长时间才能发出中断。

如何查看和调整中断合并参数:

- 查看命令: `ethtool -c ethX` | --show-coalesce
- 调整命令: `ethtool -C ethX rx-usecs value tx-usecs value` | --coalesce (其中 value 是新的中断合并参数值)

如何监控中断状态:

- 监控命令: cat /proc/interrupts
- 监控指标: 该命令会显示每个中断的触发次数，可以用来监控中断合并的效果。

## 软中断合并 (Interrupt Coalescing, soft IRQ) 和入站队列 (ingress qdisc)

- `netdev_budget_usecs`: 定义了 NAPI (网络协议中断) 轮询周期中允许的最大时间长度 (微秒)。NAPI 轮询会持续进行，直到时间超过 netdev_budget_usecs 或处理的数据包数量达到 netdev_budget。
- 作用: 软中断合并可以减少 CPU 处理软中断的次数，提高 CPU 利用率和网络性能。
- 监控指标: `cat /proc/net/softnet_stat` 可以查看软中断合并的统计信息，包括 dropped (由于 netdev_max_backlog 溢出而丢弃的数据包数量) 和 squeezed (由于 netdev_budget 或时间限制而无法处理完的数据包数量)。
- 调整命令: `sysctl -w net.core.netdev_budget_usecs value` 可以调整 netdev_budget_usecs 的值。

> 可以使用 `sysctl parameter` 来查看值，包括后面。

### NAPI 轮询预算 (netdev_budget):

- `netdev_budget`: 定义了 NAPI 轮询周期中允许从所有网络接口处理的最大数据包数量。在一次轮询周期中，所有注册了 NAPI 轮询的网络接口会以循环方式进行轮询。
- 作用: `netdev_budget` 限制了 NAPI 轮询周期中处理的数据包数量，避免单个网络接口占用过多 CPU 资源。
- 监控指标: `cat /proc/net/softnet_stat` 可以查看 NAPI 轮询的统计信息。
- 调整命令: `sysctl -w net.core.netdev_budget value` 可以调整 netdev_budget 的值。

### 网络接口权重 (dev_weight):

- `dev_weight`: 定义了内核在 NAPI 中断中处理单个网络接口的最大数据包数量，这是一个每个 CPU 的变量。对于支持 LRO (大型接收卸载) 或 GRO_HW (硬件聚合接收) 的驱动程序，一个硬件聚合的数据包会被计为一个数据包。
- 作用: `dev_weight` 限制了 NAPI 中断中处理单个网络接口的数据包数量，避免单个网络接口占用过多 CPU 资源。
- 监控指标: `cat /proc/net/softnet_stat` 可以查看 NAPI 轮询的统计信息。
- 调整命令: `sysctl -w net.core.dev_weight value` 可以调整 dev_weight 的值。

### 入站队列最大长度 (netdev_max_backlog):

- `netdev_max_backlog`: 定义了网络接口接收数据包的速度超过内核处理速度时，在入站队列 (ingress qdisc) 中允许的最大数据包数量。
- 作用: `netdev_max_backlog` 限制了入站队列的大小，避免数据包溢出导致丢包。
- 监控指标: `cat /proc/net/softnet_stat` 可以查看入站队列的统计信息。
- 调整命令: `sysctl -w net.core.netdev_max_backlog value` 可以调整 `netdev_max_backlog` 的值。

### softnet_stat

https://insights-core.readthedocs.io/en/latest/shared_parsers_catalog/softnet_stat.html

## 出站队列长度 (txqueuelen) 和 默认队列调度器 (default_qdisc)

### 出站队列长度 (txqueuelen):

- `txqueuelen`: 定义了网络接口发送数据包的速度超过网络处理速度时，在出站队列 (egress qdisc) 中允许的最大数据包数量。
- 作用: `txqueuelen` 限制了出站队列的大小，避免数据包溢出导致丢包。它也为流量控制 (Traffic Control, TC) 提供了一个缓冲区，可以用来应对连接突发和流量整形。
- 监控指标: `ip -s link` 可以查看出站队列的统计信息。
- 调整命令: `ip link set dev ethX txqueuelen N` 可以调整 txqueuelen 的值，其中 ethX 是网络接口名称，N 是新的队列长度。

### 默认队列调度器 (default_qdisc):

- `default_qdisc`: 定义了内核为网络设备使用的默认队列调度器。
- 作用: 队列调度器负责管理出站队列中的数据包，并决定数据包发送的顺序。不同的队列调度器有不同的算法，可以用来优化网络性能，例如减少延迟、提高吞吐量、防止缓冲区膨胀 (bufferbloat) 等。
- 监控指标: `tc -s qdisc ls dev ethX` 可以查看当前使用的队列调度器。
- 调整命令: `sysctl -w net.core.default_qdisc value` 可以调整 default_qdisc 的值，其中 value 是新的队列调度器名称。

常见队列调度器:

- pfifo_fast: 先入先出 (FIFO) 队列调度器，简单高效，但无法进行流量控制。
- pfifo_backlog: 与 pfifo_fast 相似，但会记录每个连接的已发送数据包数量，可以用来防止连接突发。
- codel: 一种基于延迟的队列调度器，可以有效地防止缓冲区膨胀。
- fq_codel: 一种基于公平度的队列调度器，可以保证不同连接的公平性。
- htb: 一种基于层次结构的队列调度器，可以用来进行复杂的流量控制。

## TCP Read and Write Buffers/Queues

**内存压力策略由 `tcp_mem` 和 `tcp_moderate_rcvbuf` 定义。**

### 接收缓冲区 (`tcp_rmem`)

- **作用:** `tcp_rmem` 定义了 TCP 套接字接收缓冲区的大小，用来存储从网络接收到的数据。接收缓冲区可以帮助应用程序应对网络延迟和突发流量，并提高数据传输效率。
- **参数:** `tcp_rmem` 包含三个值：
  - `min`: 在系统内存压力较大的情况下，接收缓冲区会缩小到 `min` 的大小。
  - `default`: TCP 套接字创建时，接收缓冲区的大小会初始化为 `default` 的大小。
  - `max`: 接收缓冲区的大小不会超过 `max` 的大小。
- **监控指标:** `cat /proc/net/sockstat` 可以查看 TCP 套接字的接收缓冲区使用情况。
- **调整命令:** `sysctl -w net.ipv4.tcp_rmem="min default max"` 可以调整 `tcp_rmem` 的值。

### 发送缓冲区 (`tcp_wmem`)

- **作用:** `tcp_wmem` 定义了 TCP 套接字发送缓冲区的大小，用来存储要发送到网络的数据。发送缓冲区可以帮助应用程序应对网络延迟和突发流量，并提高数据传输效率。
- **参数:** `tcp_wmem` 包含三个值：
  - `min`: 在系统内存压力较大的情况下，发送缓冲区会缩小到 `min` 的大小。
  - `default`: TCP 套接字创建时，发送缓冲区的大小会初始化为 `default` 的大小。
  - `max`: 发送缓冲区的大小不会超过 `max` 的大小。
- **监控指标:** `cat /proc/net/sockstat` 可以查看 TCP 套接字的发送缓冲区使用情况。
- **调整命令:** `sysctl -w net.ipv4.tcp_wmem="min default max"` 可以调整 `tcp_wmem` 的值。

### 接收缓冲区自动调整 (`tcp_moderate_rcvbuf`)

- **作用:** `tcp_moderate_rcvbuf` 启用后，TCP 会根据网络条件自动调整接收缓冲区的大小，以优化数据传输效率。
- **监控指标:** `cat /proc/net/sockstat` 可以查看 TCP 套接字的接收缓冲区使用情况。
- **调整命令:** `sysctl -w net.ipv4.tcp_moderate_rcvbuf value` 可以启用或禁用接收缓冲区自动调整功能。

**注意:**

- 调整 `tcp_rmem` 和 `tcp_wmem` 的值可能会影响应用程序的性能，建议在调整之前进行测试。
- 调整 `tcp_rmem` 和 `tcp_wmem` 的值需要重启应用程序才能生效。
- 启用 `tcp_moderate_rcvbuf` 会让内核自动调整接收缓冲区的大小，可能会导致一些应用程序出现问题，建议谨慎使用。

**命令汇总:**

| 参数                  | 查看命令                              | 调整命令                                        | 监控指标                 |
| --------------------- | ------------------------------------- | ----------------------------------------------- | ------------------------ |
| `tcp_rmem`            | `sysctl net.ipv4.tcp_rmem`            | `sysctl -w net.ipv4.tcp_rmem="min default max"` | `cat /proc/net/sockstat` |
| `tcp_wmem`            | `sysctl net.ipv4.tcp_wmem`            | `sysctl -w net.ipv4.tcp_wmem="min default max"` | `cat /proc/net/sockstat` |
| `tcp_moderate_rcvbuf` | `sysctl net.ipv4.tcp_moderate_rcvbuf` | `sysctl -w net.ipv4.tcp_moderate_rcvbuf value`  | `cat /proc/net/sockstat` |

---

## 参考

- [linux-network-performance-parameters](https://github.com/leandromoreira/linux-network-performance-parameters)
