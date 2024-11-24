# 使用 Pandoc 把 Markdown 转为 PDF 文件

在 Arch Linux 上使用 Pandoc 把带中文的 Markdown 转换成 PDF。

## 必要的软件和字体

Pandoc 我选择安装 bin 包，我可不想看到更新的时候一堆 Haskell 依赖。

```console
pandoc-bin
```

Tex Live 环境

```console
texlive-core texlive-langchinese texlive-latexextra texlive-bin
```

## 转换 Markdown 为 PDF

Pandoc 默认使用的 pdflatex 命令无法处理 Unicode 字符，如果要把包含中文的 Markdown 文件转为 PDF，生成的 PDF 文件中文位置会是空白 [^1]。

```bash
pandoc --pdf-engine=xelatex -V CJKmainfont="Source Han Sans CN" file.md -o file.pdf
```

> `--pdf-engine=xelatex`：使用 XeLaTeX 作为 PDF 生成引擎，支持中文。`-V CJKmainfont="Source Han Sans CN"`：指定主中文字体，我这里使用思源。

## 参考资料

[^1]: [pandoc FAQ](https://pandoc.org/faqs.html#i-get-a-blank-document-when-i-try-to-convert-a-markdown-document-in-chinese-to-pdf)
