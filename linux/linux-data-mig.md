# linux 服务器数据迁移

前段时间把社团服务器上的数据进行了迁移，这里记录一下大概的迁移方式。

ssh 配合 tar 直接将文件传到我本机电脑：

```sh
ssh -i $HOME/.ssh/tmp_rsa  root@host tar -cp --exclude-from=/root/exclude.txt /  | pv -ptr | tar x -C /home/xun/Workspace/sastback
```

附上 exclude.txt 文件：

```
/dev
/proc
/sys
/tmp
/run
/mnt
/media
/lost+found
/sastback
/var/backups
/var/cache
/var/snap
/var/tmp
/var/lib/docker
/tmp
/snap
/var/lib/lxcfs
node_modules
```

> 这里将 `var/lib/docker` 去掉是因为里面东西太多了备份的时候会报错。
> 没有找到解决方法，当时时间也急。

使用 rsync 将一些 docker 的容器备份一下：

```sh
rsync -av -e 'ssh -p port -i /home/xun/.ssh/tmp_rsa' root@host:/sastback /home/xun/Workspace/docker_back
```

在下面的例子中，`/location/of/new/root` 代指新的根目录所在的文件夹。用 `chroot` 命令之前先临时挂载 API 文件系统：

```sh
cd /location/of/new/root
mount -t proc /proc proc/
mount -t sysfs /sys sys/
mount --rbind /dev dev/
```

`chroot` 到这个备份的目录下后需要设置以下环境变量：

```sh
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
```

很遗憾，我也不知道能不能真正的恢复数据。
不过
SAST FOREVER :)
