# 博客迁移 & 一些改动

主要是把博客换了一个主题和域名，还是用的 hexo，因为方便。

写了一个格式化脚本。因为每次写笔记的时候要传到 hexo 那边需要处理一个头信息，要在每篇文章前面加上"---"这种样式的头信息，让我很苦恼。
最近又看了《UNIX 传奇》这本书，很喜欢里面道格还是谁提到的一句话：“任何重复的工作都应该自动化。”
于是用 sed 写了一个脚本专门处理这些信息，将笔记和文章分隔开，我只需要写文章就行了。
不觉得这很 awesome 吗？😎️

脚本地址：https://github.com/Xunop/hexo-format

还准备用 nlp 处理处理每篇文章的 tags，有时间就整上！

博客源码：https://github.com/Xunop/blog

里面有三个 submodule，分别是主题、脚本和笔记，我将这三部分拆散以这种形式放在一起。
之后也准备写关于 git submodule 的文章笔记，记录一下我自己的常用操作。
