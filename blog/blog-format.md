# 博客格式化脚本及使用 github action 自动化处理

最近博客改了主题，然后刚好在看《UNIX 传奇》这本书，里面讲述了 Unix 的起源及各种小工具的故事，
其中使用各种小工具来帮助处理文本或是一些工作很吸引我，于是就为自己的 hexo 博客写了一个格式化处理的脚本。

因为 hexo 的文章都需要使用头信息，大概是这样的：

```
--
title: title
date: xxxx-xx-xx
---
```

所以每次做完笔记都要自己手动加这些东西，稍微有些麻烦了呢。于是就配合 `sed` 用 shell 写了一个脚本，写出来的东西真的太糟糕了。

[脚本在这](https://github.com/Xunop/hexo-format)

这个脚本实现的功能就是将 title 和 date 加上去，还有一些主题需要的信息。写这种脚本很有意思。

现在脚本有了，如何让它自动化处理呢？最开始是想使用 git hook，但是发现并不是我想要的效果，
后面使用了 github action 实现了我想要的效果。

因为我的博客中有多个 `submodule` 分别是 `hexo-format` 这个脚本仓库和 `notes` 这个仓库。
`notes` 我额外创仓库是方便管理我自己的笔记，然后可以使用 `hexo-format` 对 `notes` 中的笔记进行处理发表为博客的文章。

`notes` 在主分支上提交之后就会触发一个 `web hook` 这个会触发 `blog` 仓库的 action，
在 `blog` 的 action 中会有一系列操作执行脚本，将 `notes` 新增的文章或者修改的文章进行处理之后提交 commit。
