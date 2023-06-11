# git submodule 基本使用

在 git 仓库中，我们可以嵌入一些子模块。使用 `git submodule` 来完成这个操作。

## 新建子模块

`git submodule add <url> <path>` 将子模块指定到一个特定的目录。

之后在项目目录中会出现 `.gitmodules` 文件，这里存放子模块的 URL 及其在父项目中的路径。

## clone 含有子模块的项目

`git clone <url>` 将 clone 一个项目下来，里面虽然有子模块目录，但是并没有任何文件，
你需要运行两个命令：`git submodule init` 用来初始化本地配置文件，
`git submodule update` 从该项目中 fetch 所有数据并 check out 与父项目中列出的相应提交。
这个命令会 clone 子模块仓库，并将其 checkout 到指定的提交。
以上两个命令可以简洁成：`git submodule update --init`

除了上述的方式之外，还可以给 `git clone` 命令用 `--recurse-submodules` 参数。
它会自动初始化并更新仓库中的每一个子模块。

## 子模块内容的更新

子模块就是一个完整的 git 仓库，使用正常的 git 代码管理规范操作即可。

### 子模块的更新

`git submodule update --remote` 将会从 remote 更新**所有**子模块，如果你不需要修改这个子模块，那么这样是没有问题的。

更新之后不要忘了在父项目中提交本次更新。

### 修改子模块

如果你需要修改子模块的代码，那么你需要在前放那个命令前加上 `--rebase` 参数，来并入本地：
`git submodule update --remote --rebase`

单纯的运行 `git submodule update --remote` 之后，进入到子模块目录时，会发现处于 `detached HEAD` 状态下，
并没有本地分支跟踪，我们修改的话是可能会丢失修改的，所以需要我们 `checkout` 到一个分支中。
不过当我们运行 `git submodule update --remote --rebase` 时会自动进行这一操作。

因为子模块也是一个单独的 git 仓库，所以在子模块目录中的是另外的一个 git 了，我们正常进行管理就行。
只是要在父项目中额外提交一次来更新我们这个地方的修改。

## 删除子模块

`git submodule deinit <submodule>` 将卸载子模块。

之后可以执行 `git rm <submodule-path>` 移除这个文件夹。
