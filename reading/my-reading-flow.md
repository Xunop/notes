# 阅读流程分享

最近入了一个墨水屏设备用来看和写，用以改善我的阅读流程（只是自己想要一个墨水屏设备罢了）。这里分享一下我的阅读流程。

PS: 墨水屏设备是「汉王 n10」

## 为什么需要改善？

我最初的阅读流程非常松散，没有一个明确的流程，以前阅读博客文章只在手机上手动管理 RSS 订阅，但是电脑上却没有 RSS 订阅，这就导致了在不同端上阅读的不一致。
虽然有尝试过使用 [FreshRSS](https://github.com/FreshRSS/FreshRSS) 来管理订阅，但是中途服务器过期了就再也没有折腾过了。
除此之外，我自己也想尝试养成阅读书籍的习惯，但是一直没有找到一个好的方法来管理自己的书籍，经常在电脑上看着看着就不知道丢哪了。
而且我更想的是在睡前或者闲暇时间看书，这就排除了电脑这个设备。手机显然不是一个合适的选择，于是在去年就想入手一个墨水屏设备，只是最近才下手买入。

## 如何改善？

下图是我改善后的阅读流程图：

![reading-process](https://github.com/Xunop/notes/blob/main/reading/resource/reading_flow.png?raw=true)

使用的工具：

- [Miniflux](https://github.com/miniflux/v2): 一个 feed reader，但是不一定要在网页上阅读。这个工具提供了许多集成功能，我是通过开启 Fever API 在我的墨水屏设备上使用 FeedMe 进行阅读。其实网页端也非常好了，我也可以不用 FeedMe 进行阅读而是直接在网页上进行。
- [slash](https://github.com/yourselfhosted/slash): 这个是一个链接缩短和共享平台，可以通过添加 url 和 name 快速访问网站。
- [einkbro](https://github.com/plateaukao/einkbro): 一个基于 Android WebView 的小型、快速的 Web 浏览器。它专为电子墨水设备量身定制，但也适用于普通 Android 设备。
- [dufs](https://github.com/sigoden/dufs): 一个支持静态服务、上传、搜索、访问控制、webdav...的文件服务器。
- [Round-Sync](https://github.com/newhinton/Round-Sync): 我用来与我的 webdav 服务器同步摘抄和笔记。
- [FeedMe](https://github.com/seazon/FeedMe): 这个阅读软件没有公布源码。其实只在网页上阅读已经完全够了。这个软件可有可无。
- [memos](https://github.com/usememos/memos): 一个开源、轻量级笔记服务。我用来记录自己的一些碎碎念。
- [plain-app](https://github.com/ismartcoding/plain-app): 是一个开源应用程序，允许通过网络浏览器管理您的手机。使用安全、易于使用的 Web 界面从桌面访问文件、视频、音乐、联系人、短信、通话等，我用来传输文件。
- [legado](https://github.com/gedoor/legado): 阅读 3.0, 阅读是一款可以自定义来源阅读网络内容的工具，为广大网络文学爱好者提供一种方便、快捷舒适的试读体验。

解决我在阅读时候的“痛点”，需要在以下方面改善：

- 稳定的阅读来源
- 多端同步阅读
- 方便添加阅读源（对于博客/公众号等一些网页链接）
- 摘抄/笔记同步

1. 关于阅读来源：

- RSS, 可以使用 [wewe-rss](https://github.com/cooderl/wewe-rss) 订阅公众号
- 网页文章
- 电子书

通过向 Miniflux 添加想要订阅的博客或者公众号来获取文章。除此之外，在我的墨水屏设备会有一些电子书。

2. 多端同步阅读：

- slash 用来同步网页链接文章

  - 使用 slash 进行文章链接的同步，可以通过 slash 的前端页面进行查看。可以通过 Telegram Bot 添加文章内容。
  - 在墨水屏设备上将 slash 设置为 einkbro 浏览器的主页，方便点击文章链接进行阅读。
    > 关于 einkbro 我准备自己改一下它的功能，因为它目前只支持将文章链接添加到 pocket，没有 slash，这就导致我如果看到我订阅的 RSS 中的有趣的文章想分享还需要转到 slash 页面去添加

- Miniflux 用来同步 RSS 文章

  - 使用 Miniflux 进行 RSS Feeds 的聚合，定时刷新订阅的 RSS 链接。
  - 使用 FeedMe 查看 Miniflux 的内容，或在 einkbro 中查看所需文章，实现对 RSS Feeds 的管理和阅读。

3. 添加阅读源/稍后阅读：

类似于 [pocket](https://getpocket.com/) 的需求，也就是 read it later。将想要稍后阅读的文章链接存放起来稍后阅读。

- Telegram Bot 添加
  - 可以通过 Telegram Bot (tgbot) 将想要阅读的文章链接添加到服务器。
- 网页添加
  - 也可以在网页中添加文章链接。不过就是需要打开浏览器输入网址（麻烦）。

关于电子书方面暂时没有什么大的需求，就算有也可以通过汉王的服务或者 plain-app 进行传输，主要还是各种文章。

4.  阅读摘抄和笔记同步：

- 通过 WebDav 将书籍摘抄和笔记同步到服务器中。
  - 服务器部署了 dufs 这样一个 webdav 服务器，我还可以利用它同步我的网文阅读进度。我用 legado 看网文。
- 对摘抄内容进行处理后发送到自己的 memos 网站，完善书籍阅读后的操作流程。
  - memos 部署的 memos。向这里倒一些垃圾是很必要的。

## 实现细节

其实需要我折腾写些代码的地方只是**如何方便地添加阅读源/稍后阅读**和**同步摘抄笔记到 memos**。
添加阅读源/稍后阅读我特意写了一个 Telegram Bot 来完成这件事情。

Telegram Bot: https://github.com/Xunop/save-link

目前只实现了向 Miniflux 添加 RSS 订阅源和向 slash 添加分享链接：

```
/start - Start the bot
/help - Get help
[website] [name] #tags - Save a link with a name
[rss feed] [category] - Save an rss feed
```

同步摘抄笔记到 memos 则是写了一个脚本：https://github.com/Xunop/notes2memos

那阅读设备呢？ ~~购买墨水屏设备~~

## 最后

我只希望我的墨水屏设备不会吃灰，然后自己养成看书的习惯。
