# vlc 使用 nfs 访问 linux

最近在 vlc 上将电脑的一些文件挂载到手机上，这样
手机就可以看电脑上的番了。

## nfs 设置[^1]

前置条件：下载安装 `nfs-utils`

将 vlc 需要访问的文件挂载到 `/srv/nfs/` 目录中：

```
mkdir -p /srv/nfs/anime
mount --bind /run/media/xun/E/Anime /srv/nfs/anime
```

修改 `/etv/exports` 配置，以保证安全性，
这里只允许读：

```
/srv/nfs/anime		192.168.1.0/24(ro,subtree_check,insecure)
```

> Tip:
> `subtree_check`:这是一个安全选项，表示在允许访问子目录之前会检查访问权限，以确保客户端不会越权访问。
> `insecure`: 允许使用不安全的端口进行连接。如果不加这个参数，vlc 是无法正确显示文件的。[^2]
> NFS 服务器和客户端之间的通信通常需要建立连接并交换数据。默认情况下，NFS 使用一些随机的高端口（通常在 1024
> 以上）进行通信，这是为了增加安全性。这里需要使用 1024 以下的端口。

使配置生效：

```
exportfs -arv
```

启动服务器：
```
systemctl start nfs-server.service
```

## 电源设置

电脑 suspend 之后似乎是会把 nfs 断掉的，这边断开不知道是网断还是哪里的原因，
总之就是 suspend 之后会导致我无法连接我的电脑。但是平时又得把屏幕熄灭，
所以需要设置一下电源设置[^3]：

```
/etc/systemd/sleep.conf.d/disable-suspend.conf

[Sleep]
AllowSuspend=no
```

[^1]: [NFS-ArchWiki](https://wiki.archlinux.org/title/NFS)
[^2]: [does not show nfs share directory content](https://code.videolan.org/videolan/vlc-android/-/issues/335)
[^3]: [disable-suspend](https://wiki.archlinux.org/title/Power_management#Disabling_suspend)
