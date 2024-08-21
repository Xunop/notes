# TCP Fast Open

折腾 TCP 的同时看到了 TCP Fast Open 这个有趣的参数，它是对 TCP 的优化，无需等待 3 次握手，应用程序就可以通过 TCP 发送数据。

正常 TCP 建立连接过程：

```
      Client                                               Server

  1.  CLOSED                                               LISTEN

  2.  SYN-SENT    -->           SYN M                  --> SYN-RECEIVED

  3.  ESTABLISHED <--        SYN N,ACK M+1             <-- SYN-RECEIVED

  4.  ESTABLISHED -->          ACK N+1                 --> ESTABLISHED
```

当前 TCP 实现的问题是，只有在连接发起方收到来自对等 TCP 的 ACK（确认）段后，才能在连接上交换数据。也就是说，只有在三次握手的第三步（发起方发送的 ACK 报文段）中，数据才能从客户端发送到服务器。因此，在对等点之间交换数据之前，就会损失一个完整的往返时间 (round trip time) 。这种丢失的 RTT 是短网络对话延迟的重要组成部分。TCP Fast Open 就是为了解决这个问题。

## 消除 RTT

```
      Client                                               Server

  1.  CLOSED                                               LISTEN

  2.  SYN-SENT    --> SYN, with cookie + data          --> SYN-RECEIVED---
                                                                         | Server TCP validates cookie, passes data to application
  3.  Client      <--        SYN-ACK                   <-- SYN-RECEIVED---

  4.  Client      <--        responses                 <-- Server          Server can send responses before receiving client ACK

  4.  ESTABLISHED -->          ACK                     --> ESTABLISHED
```

上图所示步骤如下：

1. 客户端 TCP 发送 SYN，其中包含 TFO cookie（指定为 TCP 选项）和来自客户端应用程序的数据。

2. 服务器 TCP 通过基于新 SYN 的源 IP 地址重复加密过程来验证 TFO cookie。如果 cookie 被证明是有效的，那么服务器 TCP 就可以确信这个 SYN 来自它声称来自的地址。这意味着服务器 TCP 可以立即将应用程序数据传递给服务器应用程序。

3. 从这里开始，TCP 会话正常进行：服务器 TCP 向客户端发送 SYN-ACK 段，然后客户端 TCP 进行确认，从而完成三向握手。服务器 TCP 还可以在收到客户端的 ACK **之前** 向客户端 TCP 发送响应数据段。

这是一个使用 `tcpdump` 查看使用了 `TCP_FAST_OPEN` 选项的抓包记录：

```
1. IP 127.0.0.1.51902 > 127.0.0.1.8000: Flags [S], seq 3550480872:3550480878, win 33280, options [mss 65495,sackOK,TS val 1437621030 ecr 0,nop,wscale 7,tfo  cookie ce80700cf8e6113c,nop,nop], length 6
2. IP 127.0.0.1.8000 > 127.0.0.1.51902: Flags [S.], seq 2245778431, ack 3550480873, win 33280, options [mss 65495,sackOK,TS val 1437621030 ecr 1437621030,nop,wscale 7], length 0
3. IP 127.0.0.1.51902 > 127.0.0.1.8000: Flags [P.], seq 3550480873:3550480879, ack 2245778432, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 6
4. IP 127.0.0.1.8000 > 127.0.0.1.51902: Flags [.], ack 3550480879, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 0
5. IP 127.0.0.1.8000 > 127.0.0.1.51902: Flags [P.], seq 2245778432:2245778438, ack 3550480879, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 6
6. IP 127.0.0.1.51902 > 127.0.0.1.8000: Flags [.], ack 2245778438, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 0
7. IP 127.0.0.1.8000 > 127.0.0.1.51902: Flags [F.], seq 2245778438, ack 3550480879, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 0
8. IP 127.0.0.1.51902 > 127.0.0.1.8000: Flags [F.], seq 3550480879, ack 2245778439, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 0
9. IP 127.0.0.1.8000 > 127.0.0.1.51902: Flags [.], ack 3550480880, win 260, options [nop,nop,TS val 1437621030 ecr 1437621030], length 0
```

可以看到 `3` 这个数据段在 `4` 这个 ACK 数据包之前。并且 options 中有一个 `cookie` 字段。

Server.py:

```py
import socket


server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)


server_address = ('localhost', 8880)
print('Starting up on {} port {}'.format(*server_address))
# SO_REUSEADDR
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
# TCP_FASTOPEN
server_socket.setsockopt(socket.IPPROTO_TCP, socket.TCP_FASTOPEN, 1)
server_socket.bind(server_address)

server_socket.listen(1)

while True:
    print('Waiting for a connection...')
    connection, client_address = server_socket.accept()
    try:
        print('Connection from', client_address)

        while True:
            data = connection.recv(1024)
            # TCP_QUICKACK
            connection.setsockopt(socket.IPPROTO_TCP, socket.TCP_QUICKACK, 1)
            print('Received:', data.decode())

            if not data:
                print('No data received from', client_address)
                break

    finally:
        connection.close()
```

Client.py:

```py
import socket

addr = ("localhost", 8880)
s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

s.sendto("hello!".encode(), 536870912, addr)

print(s.recv(1000))
```

> `sendto` 需要提供 ip, 因为是 connectionless.

具体参考：

[1] https://lwn.net/Articles/508865/
