# MSS、MTU 和 TCP 拥塞堵塞

## MTU

[MTU][2](Maximum Transmission Unit) 最大传输单元，是指数据链路层上面所能通过的最大数据包大小（以字节为单位）。这一分片过程发生在 IP 层（OSI 模型的第 3 层，即网络层）。

关于 [MTU](#MTU) 和 [MSS](#MSS)，[cloudflare 文章中提供了一张非常好理解的图][2]：

![Data packet](https://www.cloudflare.com/resources/images/slt3lc6tev37/29tC841gKxTb6c2fUFJro6/9c49654618fe84f3c00700629f30a6e4/MSS_TCP_segment_packet_diagram.png)

一个 MTU 最大 1500 bytes，如果超过这个数量则会被分片。

## MSS

[MSS][1](Maximum Segment Size) 最大分段大小，限制通过网络（例如互联 网）传输的数据包或小数据块的大小。通过网络传输的所有数据都被分解成数据包。数据包附有几个标头，其中包含有关其内容和目的地的信息。MSS 测量数据包的非标头部分，称为有效负载。它只是一个参数，一个限制。

如果将数据包比作运输卡车，标头是卡车本身，有效负载是拖车和货物，那么 MSS 就像只测量拖车的秤。如果拖车过重，则不允许卡车继续前往目的地。

MSS 是第 4 层（传输层）的参数，与 TCP 一起使用。

`MTU - (TCP 标头 + IP 标头) = MSS`

IP 标头 和 TCP 标头 分别占用 20 bytes。所以一个 MSS 最大 1460 bytes。TCP 一个包最大是可以发送 1460 bytes。

## TCP 拥塞堵塞

TCP 发送数据包并不是每次只发送一个，而是一次发送一组包，然后等待 ACK，接着发送下一组包。这里就涉及到拥塞控制窗口 cwnd 与 TCP 的拥塞控制机制。

TCP 拥塞堵塞就是根据 MSS 的大小来控制。比如拥塞控制窗口 cwnd 大小为 10 的时候，TCP 连接建立起来之后会发 10 个 MSS 数据（TCP 的单位一般都是 MSS 计数），等待对等方的 ACK 之后再进行下一轮的数据发送，并且逐渐增大 cwnd 的值。
当发生拥塞堵塞时，会从慢启动切换到拥塞控制算法。关于这两种算法详细参见[维基百科的解释][3]。

搭建了一个 100ms，关闭了 `tcp-segmentation-offload` 参数环境，在这里面测试的一段抓包数据：

```console
 1   0.000000  192.168.1.2 → 192.168.1.1  TCP 74 43218 → 5001 [SYN] Seq=0 Win=64240 Len=0 MSS=1460 SACK_PERM TSval=984956032 TSecr=0 WS=128
 2   0.100707  192.168.1.1 → 192.168.1.2  TCP 74 5001 → 43218 [SYN, ACK] Seq=0 Ack=1 Win=65160 Len=0 MSS=1460 SACK_PERM TSval=3503908013 TSecr=984956032 WS=128
 3   0.100771  192.168.1.2 → 192.168.1.1  TCP 66 43218 → 5001 [ACK] Seq=1 Ack=1 Win=64256 Len=0 TSval=984956133 TSecr=3503908013
 4   0.102053  192.168.1.2 → 192.168.1.1  TCP 130 43218 → 5001 [PSH, ACK] Seq=1 Ack=1 Win=64256 Len=64 TSval=984956134 TSecr=3503908013
 5   0.102122  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [ACK] Seq=65 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
 6   0.102130  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [PSH, ACK] Seq=1513 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
 7   0.102161  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [ACK] Seq=2961 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
 8   0.102165  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [PSH, ACK] Seq=4409 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
 9   0.102176  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [ACK] Seq=5857 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
10   0.102179  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [PSH, ACK] Seq=7305 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
11   0.102187  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [ACK] Seq=8753 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
12   0.102189  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [PSH, ACK] Seq=10201 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
13   0.102196  192.168.1.2 → 192.168.1.1  TCP 1514 43218 → 5001 [ACK] Seq=11649 Ack=1 Win=64256 Len=1448 TSval=984956134 TSecr=3503908013
14   0.202685  192.168.1.1 → 192.168.1.2  TCP 66 5001 → 43218 [ACK] Seq=1 Ack=65 Win=65152 Len=0 TSval=3503908115 TSecr=984956134
```

> 第二个字段是时间。

发现 1-2 之间花费了 1 个 RTT(100ms)，13-14 之间也花费了 1 个 RTT，第一个 RTT 用于建立连接，第二个 RTT 传输数据。4-13 则是 cwnd 的大小。

可以尝试修改 cwnd 的值，查看慢启动时的变化。尝试使用 `sudo ip netns exec ns2 ip route add default via 192.168.1.1 dev veth1 initcwnd 20` 但修改未生效。

## TSO(tcp-segmentation-offload)

我们抓包会发现实际上的 tcp payload 大小会超过 MTU(1500) 限制，其中一个原因（其他未了解）是开启了 [tcp-segmentation-offload 参数][4]，
这个参数利用 NIC（网络接收卡）接收较大的数据包，并在硬件层面将其分成适合 MTU 的较小段发送到网络。所以我们抓到的包实际上会显示成更大的包，
但是在网络上传输的是被分段的小包。

关闭 `tcp-segmentation-offload`，以后面测试环境为例：

```bash
#ethtool --show-offload veth1 | grep offload
sudo ip netns exec ns2 ethtool --show-offload veth1 | grep offload
#ethtool -K veth1 tso off
sudo ip netns exec ns2 ethtool -K veth1 tso off
```

## 测试环境构建

```bash
sudo ip link add veth0 type veth peer name veth1
ip link

sudo ip netns add ns1
sudo ip netns add ns5
sudo ip netns list

sudo ip link set veth0 netns ns1
sudo ip link set veth1 netns ns2

sudo ip netns exec ns1 ip link
sudo ip netns exec ns2 ip link

sudo ip netns exec ns1 ip addr add 192.168.1.1/24 dev veth0
sudo ip netns exec ns1 ip link set veth0 up
sudo ip netns exec ns2 ip addr add 192.168.1.2/24 dev veth1
sudo ip netns exec ns2 ip link set veth1 up

sudo ip netns exec ns1 ping 192.168.1.2

# 设置带宽为 1Mbps，延迟为 100ms，无丢包
sudo ip netns exec ns1 tc qdisc add dev veth0 root netem rate 1mbit delay 100ms

sudo ip netns exec ns1 ping 192.168.1.2 # 会发现延迟为 100 ms 以上
```

在 ns1 中启动 `iperf` 服务器：

```bash
sudo ip netns exec ns1 iperf -s -B 192.168.1.1
```

tcpdump 抓包：

```bash
sudo ip netns exec ns1 tcpdump -i veth0 -w iperf_traffic_ns1.pcap
```

同样，可以在 ns2 中抓取 veth1 接口的数据包：

```bash
sudo ip netns exec ns2 tcpdump -i veth1 -w iperf_traffic_ns2.pcap
```

在 ns2 中启动 `iperf` 客户端：

```bash
sudo ip netns exec ns2 iperf -c 192.168.1.1 -B 192.168.1.2 -t 30
```

这里测试 30 秒。

清理环境：

```bash
sudo ip netns del ns1
sudo ip netns del ns2
```

---

[1]: https://www.cloudflare.com/zh-cn/learning/network-layer/what-is-mss/ "什么是 MSS（最大分段大小）？"
[2]: https://www.cloudflare.com/zh-cn/learning/network-layer/what-is-mtu/ "什么是 MTU (最大传输单元)？"
[3]: https://en.wikipedia.org/wiki/TCP_congestion_control "TCP congestion control"
[4]: https://www.kernel.org/doc/html/latest/networking/segmentation-offloads.html#tcp-segmentation-offload "TCP Segmentation Offload"
