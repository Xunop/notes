# TCP 三次握手

最近在看某个项目的一个功能：[network-lock](https://www.criu.org/TCP_connection#Checkpoint_and_restore_TCP_connection), 感觉还挺有意思的，于是写了一个 TCP Demo 来测试这个功能，但是在我手动将 server 关闭的时候发现不能马上使用上次 server 监听的端口，而是跟我说端口已被占用，有些好奇，于是就有了以下的一些折腾。顺便在这里记录一下关于 TCP 三次握手的笔记。顺带 `tcpdump` 分析。

## 介绍

在网络通信中，TCP（Transmission Control Protocol）是一种可靠的传输协议，而TCP三次握手是建立TCP连接时的重要过程之一。

## 概述

TCP 三次握手，包括三个步骤：

1. 客户端发送SYN请求：客户端向服务器发送一个SYN（同步）标志的数据包，表明它想要建立连接。

2. 服务器响应ACK和SYN：服务器接收到客户端的SYN请求后，向客户端发送一个ACK（确认）数据包，表示已收到客户端的请求，并发送自己的SYN标志，以示同意建立连接。

3. 客户端发送ACK：客户端接收到服务器的ACK和SYN后，向服务器发送一个ACK确认数据包，表示已收到服务器的响应，连接建立完成。

## 代码示例与 tcpdump 分析

下面是一个 client 和 server 建立 TCP 连接的代码。我最开始是用 C 写的，但是后面发现 Python 写起来舒服多了。

这个 Server 会监听 localhost 的 8880 端口。
`Server.py`:

```py
import socket


server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


server_address = ('localhost', 8880)
print('Starting up on {} port {}'.format(*server_address))
# SO_REUSEADDR
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
server_socket.bind(server_address)

server_socket.listen(1)

while True:
    print('Waiting for a connection...')
    connection, client_address = server_socket.accept()
    try:
        print('Connection from', client_address)

        while True:
            data = connection.recv(1024)
            print('Received:', data.decode())

            if not data:
                print('No data received from', client_address)
                break

    finally:
        connection.close()
```

这个 Client 会与 Server 建立连接并每隔 2s 发送当前时间给 Server 。
`Client.py`:

```py
import socket
import time

client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

server_address = ('localhost', 8880)
print('Connecting to {} port {}'.format(*server_address))
client_socket.connect(server_address)

try:
    while True:
        message = 'Hello, server! Time is {}'.format(time.ctime())
        print('Sending:', message)
        client_socket.sendall(message.encode())
        time.sleep(2)

finally:
    print('Closing the connection')
    client_socket.close()
```

运行这两个代码，使用 `tcpdump` 来监听 8880 端口的 tcp 数据包：

三次握手：

```
$ tcpdump -i lo -n port 8880  --absolute-tcp-sequence-numbers

tcpdump: verbose output suppressed, use -v[v]... for full protocol decode
listening on lo, link-type EN10MB (Ethernet), snapshot length 262144 bytes
16:18:18.333865 IP 127.0.0.1.57830 > 127.0.0.1.8880: Flags [S], seq 1857514943, win 33280, options [mss 65495,sackOK,TS val 3851230309 ecr 0,nop,wscale 7], length 0
16:18:18.333874 IP 127.0.0.1.8880 > 127.0.0.1.57830: Flags [S.], seq 3256784619, ack 1857514944, win 33280, options [mss 65495,sackOK,TS val 3851230309 ecr 3851230309,nop,wscale 7], length 0
16:18:18.333880 IP 127.0.0.1.57830 > 127.0.0.1.8880: Flags [.], ack 3256784620, win 260, options [nop,nop,TS val 3851230309 ecr 3851230309], length 0

16:18:18.333910 IP 127.0.0.1.57830 > 127.0.0.1.8880: Flags [P.], seq 1857514944:1857514991, ack 3256784620, win 260, options [nop,nop,TS val 3851230309 ecr 3851230309], length 47
16:18:18.333912 IP 127.0.0.1.8880 > 127.0.0.1.57830: Flags [.], ack 1857514991, win 260, options [nop,nop,TS val 3851230309 ecr 3851230309], length 0
```

> PS: tcpdump 的参数说明：
>
> i lo: 监听 lo 网卡
> n: 不解析 IP 地址
> port 8880: 只监听 8880 端口的数据包
> absolute-tcp-sequence-numbers: 显示绝对的 TCP 序列号，如果不加这个参数，tcpdump 会显示相对的序列号。

`tcpdump` 输出的 Flags 字段解释：

[.] - ACK (Acknowledgment)
[S] - SYN (Start Connection)
[P] - PSH (Push Data)
[F] - FIN (Finish Connection)
[R] - RST (Reset Connection)
[S.] - SYN-ACK (SynAcK Packet)

可以看到，Client 发送了一个 SYN 数据包，Server 回复了一个 SYN+ACK 数据包，Client 再回复一个 ACK 数据包，三次握手完成。

seq 和 ack 是 TCP 数据包中的两个重要字段，seq 表示数据包的序列号，ack 表示确认号。SYN 数据包的 seq 是随机的，SYN+ACK 数据包的 seq 是随机的，ack 是 SYN 数据包的 seq+1，ACK 数据包的 seq 是 SYN+ACK 数据包的 ack，ack 是 SYN+ACK 数据包的 seq+1。

seq 和 ack 的作用是用来保证数据包的可靠传输。TCP 通过 seq 和 ack 来保证数据包的有序传输和可靠接收。

三次挥手和四次挥手：

```
16:21:10.284200 IP 127.0.0.1.57830 > 127.0.0.1.8880: Flags [F.], seq 1857515790, ack 3256784620, win 260, options [nop,nop,TS val 3851402259 ecr 3851400314], length 0
16:21:10.284297 IP 127.0.0.1.8880 > 127.0.0.1.57830: Flags [F.], seq 3256784620, ack 1857515791, win 260, options [nop,nop,TS val 3851402259 ecr 3851402259], length 0
16:21:10.284308 IP 127.0.0.1.57830 > 127.0.0.1.8880: Flags [.], ack 3256784621, win 260, options [nop,nop,TS val 3851402259 ecr 3851402259], length 0
```
> 这里三次挥手是 Linux 默认开启 [TCP 延迟确认机制](https://en.wikipedia.org/wiki/TCP_delayed_acknowledgment)，而 RFC795 中是四次挥手：https://www.rfc-editor.org/rfc/rfc793#section-3.5
> 关于 TCP 延迟确认机制，可以使用 `TCP_QUICKACK` 关闭：https://www.man7.org/linux/man-pages/man7/tcp.7.html

四次挥手的过程：

1. Client 发送一个 FIN 数据包，表示不再发送数据了。
2. Server 收到 FIN 数据包后，回复一个 ACK 数据包，表示收到了 Client 的 FIN 数据包。
3. Server 发送一个 FIN 数据包，表示不再发送数据了。
4. Client 收到 FIN 数据包后，回复一个 ACK 数据包，表示收到了 Server 的 FIN 数据包。

三次挥手的过程只是将 FIN 与 ACK 数据包一同发送。

首先发出 FIN 的一侧，如果给“对侧”的 FIN 响应了 ACK，那么就会超时等待 2 *MSL 时间，然后关闭连接。在这段超时等待时间内，本地的端口不能被新连接使用；避免延时的包的到达与随后的新连接相混淆。RFC793 定义了 MSL 为 2 分钟，Linux 设置成了 [30s](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/net/ipv4/tcp.c?h=linux-6.8.y#n2863) 。参数 tcp_max_tw_buckets 控制并发的 TIME_WAIT 的数量，默认值是 180000，如果超限，那么，系统会把多的 TIME_WAIT 状态的连接给 destory 掉，然后在日志里打一个警告（如：time wait bucket table overflow）

这也就是手动将 server 进程杀掉之后，端口仍被占用的原因。TCP 连接关闭之后，不会马上释放这个 socket ，之后任何想将新 socket 绑定到相同的 地址 和端口的操作都会失败，直到旧的 socket 关闭为止。

> 可以使用 `SO_REUSEADDR` 解决这个问题。
> https://stackoverflow.com/questions/14388706/how-do-so-reuseaddr-and-so-reuseport-differ
