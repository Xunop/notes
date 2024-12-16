# Samsung S24 和 Samsung Watch 5 国行刷外版系统（可能通用）

Samsung 设备更改其他地区系统时需要退出 Google 账号和 Samsung 账号。

## Samsung S24

1. 需要找到想要刷的指定地区版本的固件，一般通过以下两个网站查找：

- https://samfw.com
- https://sxrom.cn

比如 S24 国行版系统固件：https://sxrom.cn/Find.aspx?MODEL=SM-S9210&CSC=CHC

> S24 型号为 SM-S9210，CSC 是国家代码，这里的 CHC 是中国，港版为 TGY，台版为 BRI。

**注意**：确保互刷的系统版本**安全策略**版本对应正确：

> - ROM（刷机包）的倒数第 5 位，即是“安全政策”版本。 这个数字，不能小于手机上“安全政策”版本，但可以等于。如有版本号为 N9760ZCS6HWH1 的“安全政策”版本就是 6 。
> - 手机上“安全政策”版本查找方式：手机设置 - 关于手机 - 软件信息 - 基带版本。
> - 对比它们倒数第5位的数字（如下图）：如果 ROM 的版本低于手机，那么该ROM无法刷入手机，但也不会损坏手机，会在刷机一开始就报错。
> - 如果该机型的国行和港版ROM可以互刷，也要遵循这个规则。
> - 官方一般每隔几个月，在随ROM的更新时，更新一次这个数字，官方称之为“安全政策”更新。安全政策的更新之后，将无法退回。
> - 港版的更新有时快于国行，如果恰好手机上港版已经升级到新的“安全政策”，但国行ROM还是老的“安全政策”版本，那么此时就无法刷到国行，请等待数日，国行ROM更新后即可刷回国行。
> - 因为“安全政策”只用一个字符来表示，所以 9 之后就是 A， A 之后又是 B 。
>
> 源自：https://sxrom.cn/help4.aspx

2. 下载 Samsung Odin

Samsung Odin 是适用于 Samsung Android 智能手机和平板电脑设备的刷机工具。

- Odin 下载地址：https://odindownload.com。
- 如果 Odin 连接不上设备（设备需要在 Download 模式下，参见后面步骤），可能还需要下载驱动：https://developer.samsung.com/android-usb-driver。

3. 解压在第 1 步下载的固件，会发现有 AP, BL, CP, CSC, HOME-CSC 开头的这几个文件。

4. 将手机进入 Download 模式（手机插上线，关机状态下同时按音量加减）看到警告界面后按音量上。解压官方四件套之后，使用 Odin 刷入。只需要将 BL、AP、CP、CSC 开头的 tarball 放入 Odin 的对应槽位刷入即可。

5. PASS，结束。

刷回步骤应该也一样，没有测试过。

## Samsung Watch 5

1. 下载固件以及 NetOdin，但是 Watch 5 的固件比较少。

> - NetOdin - https://t.me/swapplication/258
> - Firmware for Galaxy Watch 5
> - Galaxy Watch 5 SM-R900 40 mm - https://t.me/swapplication/296
> - Galaxy Watch 5 SM-R910 44 mm - https://t.me/swapplication/297
> - Galaxy Watch 5 PRO SM - R920 45mm - https://t.me/swapplication/298
>
> 源自：https://xdaforums.com/t/flash-sgw5-with-netodin-succeed.4551903/post-89809935

> 我手上的是 44 mm。

2. 刷写步骤。
   1. 手表开机状态下，长按右侧两个按键，重启直到出现 SAMSUNG logo 且下方有 Rehbooting 字样时连按三次上键。
   2. 此时会进入一个界面（可能是fastboot模式？），这个模式下**上键短按**是切换，长按是选择。选择 Download(Wireless)。
   3. 电脑搜索连接手表的开启的热点，名称应该是手表的型号。
   4. 打开 NetOdin, 在 AP 栏选择指定的固件包，刷入即可。（似乎只支持 tar 包，如果下载的固件不是 tar 格式可以先解压再转成 tar 包)
   5. PASS，结束。

## 参考

- https://www.coolapk.com/feed/48366338?shareKey=ODg3ZDg1YTE1OGMzNjVlZWQ3ZDU
- https://samfw.com
- https://sxrom.cn/help4.aspx
- https://xdaforums.com/t/flash-sgw5-with-netodin-succeed.4551903/
- https://xdaforums.com/t/flash-sgw5-with-netodin-succeed.4551903/post-89809935
