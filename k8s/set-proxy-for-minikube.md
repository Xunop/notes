# minikube 设置代理

在好久以前就折腾过 minikube 的代理配置，但是当时懒得写下来（其实也没啥配置步骤），想了想还是写下来算了，以后免得又忘记。

minikube 会在宿主机上创建一个 bridge 让集群与宿主机通信：

```bash
39: br-820c7fa60371: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:8d:3f:96:ae brd ff:ff:ff:ff:ff:ff
    inet 192.168.49.1/24 brd 192.168.49.255 scope global br-820c7fa60371
       valid_lft forever preferred_lft forever
```

也就是可以将环境变量修改成 `192.168.49.1` 地址就可以将让集群使用宿主机的代理：

```bash
k8s_proxy() {
  proxy_server="http://192.168.49.1:10809"
  no_proxy="localhost,127.0.0.1,.local,192.168.49.2"
  export http_proxy="$proxy_server"
  export https_proxy="$proxy_server"
  export all_proxy="$proxy_server"
  export HTTP_PROXY="$proxy_server"
  export HTTPS_PROXY="$proxy_server"
  export ALL_PROXY="$proxy_server"

  export no_proxy="$no_proxy"
  export NO_PROXY="$no_proxy"
}
```

代理客户端监听至 `0.0.0.0` ~~（虽然有些危险，但是自己的电脑应该也没事吧）~~。
