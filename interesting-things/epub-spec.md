# EPUB 格式规范

EPUB 格式是一种 zip 格式，大概由这些内容组成：

```
❯ tree
.
├── META-INF
│   └── container.xml
├── mimetype
└── OEBPS
    ├── content.opf
    ├── Images
    │   ├── book01_01.jpg
    │   ├── book01_02.jpg
    │   ├── book01_03.jpg
    │   ├── book01_04.jpg
    │   ├── book01_05.jpg
    │   ├── book01_06.jpg
    │   └── book01_info.jpg
    ├── Styles
    │   └── style.css
    ├── Text
    │   ├── book01_back_cover.xhtml
    │   ├── book01_front_cover.xhtml
    │   ├── book01_illustration01.xhtml
    │   ├── book01_illustration02.xhtml
    │   ├── book01_illustration03.xhtml
    │   ├── book01_illustration04.xhtml
    │   ├── book01_index.xhtml
    │   ├── book01_info.xhtml
    │   ├── by.xhtml
    │   ├── cover.xhtml
    │   ├── Section0001.xhtml
    │   ├── Section0002.xhtml
    │   ├── Section0003.xhtml
    │   ├── Section0004.xhtml
    │   ├── Section0005.xhtml
    │   ├── Section0006.xhtml
    │   ├── Section0007.xhtml
    │   ├── Section0008.xhtml
    │   ├── Section0009.xhtml
    │   ├── Section0010.xhtml
    │   ├── Section0011.xhtml
    │   ├── Section0012.xhtml
    │   ├── Section0013.xhtml
    │   ├── Section0014.xhtml
    │   └── Section0015.xhtml
    └── toc.ncx
```

- Mime Type file: application/epub+zip.
- META-INF folder (container file which points to the location of the .opf file), signatures, encryption, rights, are xml files
- OEBPS folder stores the book content .(opf, ncx, html, svg, png, css, etc. files)

## META-INF

这个文件夹下主要存储关于 EPUB 文件本身的元数据信息和描述性信息。

### Container – META-INF/container.xml

`container.xml` 文件必须标识容器中包含的 EPUB 出版物的根文件的媒体类型和路径。

示例：

```
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
    <rootfiles>
        <rootfile full-path="OEBPS/My Crazy Life.opf"
            media-type="application/oebps-package+xml" />
    </rootfiles>
</container>
```

> 带有根文件 `OEBPS/My Crazy Life.opf`的 EPUB 出版物

```
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
    <rootfiles>
        <rootfile full-path="SVG/Sandman.opf"
            media-type="application/oebps-package+xml" />
        <rootfile full-path="XHTML/Sandman.opf"
            media-type="application/oebps-package+xml" />
    </rootfiles>
</container>
```

> 将包含 SVG 和 XHTML 的 《The Sandman》合并到同一个容器中

### Encryption – META-INF/encryption.xml

### Manifest – META-INF/manifest.xml

### Metadata – META-INF/metadata.xml

### Rights Management – META-INF/rights.xml

### Digital Signatures – META-INF/signatures.xml

## OEBPS

在 OEBPS 中包含两个必要文件：`*.opf` 和 `*.ncx`。

### OPF

OPF 包含四个子元素：metadata, manifest, spine, guide.

#### Metadata

EPUB 的元数据，比如 title, language, identifier, cover, etc. title 和 identifier 是必要的。

identifier 由数字图书的创建者定义，必须唯一。对于图书出版商来说，
这个字段一般包括 ISBN 或者 Library of Congress 编号；也可以使用 URL 或者随机生成的唯一用户 ID。

示例：

```
  <metadata xmlns:opf="http://www.idpf.org/2007/opf" xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="BookId" opf:scheme="UUID">urn:uuid:53a846f0-302c-4f90-9798-bb219328309f</dc:identifier>
    <dc:title>三毛全集1.撒哈拉的故事</dc:title>
    <dc:creator opf:role="aut">三毛</dc:creator>
    <dc:language>zh</dc:language>
    <dc:date opf:event="modification">2016-08-18</dc:date>
    <dc:publisher>哈尔滨出版社</dc:publisher>
    <dc:date opf:event="publication">2003-07-01</dc:date>
    <dc:identifier opf:scheme="ISBN">7-80639-879-1/I·235</dc:identifier>
    <meta content="0.9.6" name="Sigil version" />
    <meta name="cover" content="book01_01.jpg" />
  </metadata>
```

#### Manifest

列出了 package 中所包含的所有文件（包括 xhtml, css, png, ncx, etc）。

示例：

```
  <manifest>
    <item id="ncx" href="toc.ncx" media-type="application/x-dtbncx+xml"/>
    <item id="style.css" href="Styles/style.css" media-type="text/css"/>
    <item id="book01_front_cover.xhtml" href="Text/book01_front_cover.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_back_cover.xhtml" href="Text/book01_back_cover.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_index.xhtml" href="Text/book01_index.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0001.xhtml" href="Text/Section0001.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0002.xhtml" href="Text/Section0002.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0003.xhtml" href="Text/Section0003.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0004.xhtml" href="Text/Section0004.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0005.xhtml" href="Text/Section0005.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0006.xhtml" href="Text/Section0006.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0007.xhtml" href="Text/Section0007.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0008.xhtml" href="Text/Section0008.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0009.xhtml" href="Text/Section0009.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0010.xhtml" href="Text/Section0010.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0011.xhtml" href="Text/Section0011.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0012.xhtml" href="Text/Section0012.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0013.xhtml" href="Text/Section0013.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0014.xhtml" href="Text/Section0014.xhtml" media-type="application/xhtml+xml"/>
    <item id="Section0015.xhtml" href="Text/Section0015.xhtml" media-type="application/xhtml+xml"/>
    <item id="by.xhtml" href="Text/by.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_01.jpg" href="Images/book01_01.jpg" media-type="image/jpeg"/>
    <item id="book01_02.jpg" href="Images/book01_02.jpg" media-type="image/jpeg"/>
    <item id="book01_03.jpg" href="Images/book01_03.jpg" media-type="image/jpeg"/>
    <item id="book01_04.jpg" href="Images/book01_04.jpg" media-type="image/jpeg"/>
    <item id="book01_05.jpg" href="Images/book01_05.jpg" media-type="image/jpeg"/>
    <item id="book01_06.jpg" href="Images/book01_06.jpg" media-type="image/jpeg"/>
    <item id="book01_illustration01.xhtml" href="Text/book01_illustration01.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_illustration02.xhtml" href="Text/book01_illustration02.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_illustration04.xhtml" href="Text/book01_illustration04.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_illustration03.xhtml" href="Text/book01_illustration03.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_info.xhtml" href="Text/book01_info.xhtml" media-type="application/xhtml+xml"/>
    <item id="book01_info.jpg" href="Images/book01_info.jpg" media-type="image/jpeg"/>
    <item id="cover.xhtml" href="Text/cover.xhtml" media-type="application/xhtml+xml"/>
  </manifest>
```

#### Spine

所有 xhtml 文档的阅读顺序，可以将 OPF spine 理解为是书中 “页面” 的顺序，
解析的时候按照文档顺序从上到下依次读取 spine。

在 spine 中的每个 itemref 元素都需要有一个 idref 属性，这个属性和 manifest 中的某个 ID 匹配。

spine 中的 linear 属性表明该项是作为线性阅读顺序中的一项，还是和先后次序无关。

示例：

```
  <spine toc="ncx">
    <itemref idref="cover.xhtml"/>
    <itemref idref="book01_front_cover.xhtml"/>
    <itemref idref="book01_back_cover.xhtml"/>
    <itemref idref="book01_info.xhtml"/>
    <itemref idref="book01_illustration01.xhtml"/>
    <itemref idref="book01_illustration02.xhtml"/>
    <itemref idref="book01_illustration03.xhtml"/>
    <itemref idref="book01_illustration04.xhtml"/>
    <itemref idref="book01_index.xhtml"/>
    <itemref idref="Section0001.xhtml"/>
    <itemref idref="Section0002.xhtml"/>
    <itemref idref="Section0003.xhtml"/>
    <itemref idref="Section0004.xhtml"/>
    <itemref idref="Section0005.xhtml"/>
    <itemref idref="Section0006.xhtml"/>
    <itemref idref="Section0007.xhtml"/>
    <itemref idref="Section0008.xhtml"/>
    <itemref idref="Section0009.xhtml"/>
    <itemref idref="Section0010.xhtml"/>
    <itemref idref="Section0011.xhtml"/>
    <itemref idref="Section0012.xhtml"/>
    <itemref idref="Section0013.xhtml"/>
    <itemref idref="Section0014.xhtml"/>
    <itemref idref="Section0015.xhtml"/>
    <itemref idref="by.xhtml"/>
  </spine>
```

#### Guide

出版物基本结构特征的一组参考，例如目录、前言、参考书目等。

### NCX file

NCX file 是 Navigation Control file for XML 的缩写，通常命名为 toc.ncx。
该文件由 EPUB 文件的分层目录组成。

NCX 的 <head> 标记中包含四个 meta 元素：

- uid：数字图书的惟一 ID。该元素应该和 OPF 文件中的 dc:identifier 对应。
- depth：反映目录表中层次的深度。
- totalPageCount 和 maxPageNumber：仅用于纸质图书，保留 0 即可。

`docTitle/text` 的内容是图书的标题，和 OPF 中的 dc:title 匹配。

`navMap` 定义了图书的目录。`navMap` 包含一个或多个 `navPoint` 元素，每个 `navPoint`
都要包含下列元素：

- `playOrder`: 说明文档的阅读顺序。和 OPF spine 中 `itemref` 元素的顺序相同。
- `navLabel/text`: 该章节的标题。通常是本章的标题或者数字。
- `content`: 其中的 `src` 属性指向包含这些内容的物理资源。为 OPF manifest 中声明的文件。
- 可以拥有多个 `navPoint` 元素。

```
<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE ncx PUBLIC "-//NISO//DTD ncx 2005-1//EN"
 "http://www.daisy.org/z3986/2005/ncx-2005-1.dtd"><ncx version="2005-1" xmlns="http://www.daisy.org/z3986/2005/ncx/">
  <head>
    <meta content="urn:uuid:53a846f0-302c-4f90-9798-bb219328309f" name="dtb:uid"/>
    <meta content="2" name="dtb:depth"/>
    <meta content="0" name="dtb:totalPageCount"/>
    <meta content="0" name="dtb:maxPageNumber"/>
  </head>
  <docTitle>
    <text>三毛全集</text>
  </docTitle>
  <navMap>
    <navPoint id="navPoint-1" playOrder="1">
      <navLabel>
        <text>撒哈拉的故事</text>
      </navLabel>
      <content src="Text/book01_front_cover.xhtml"/>
      <navPoint id="navPoint-2" playOrder="2">
        <navLabel>
          <text>目录</text>
        </navLabel>
        <content src="Text/book01_index.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-3" playOrder="3">
        <navLabel>
          <text>妈妈的一封信（代序）</text>
        </navLabel>
        <content src="Text/Section0001.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-4" playOrder="4">
        <navLabel>
          <text>回乡小笺（四版代序）</text>
        </navLabel>
        <content src="Text/Section0002.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-5" playOrder="5">
        <navLabel>
          <text>沙漠中的饭店</text>
        </navLabel>
        <content src="Text/Section0003.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-6" playOrder="6">
        <navLabel>
          <text>结婚记</text>
        </navLabel>
        <content src="Text/Section0004.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-7" playOrder="7">
        <navLabel>
          <text>悬壶济世</text>
        </navLabel>
        <content src="Text/Section0005.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-8" playOrder="8">
        <navLabel>
          <text>娃娃新娘</text>
        </navLabel>
        <content src="Text/Section0006.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-9" playOrder="9">
        <navLabel>
          <text>荒山之夜</text>
        </navLabel>
        <content src="Text/Section0007.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-10" playOrder="10">
        <navLabel>
          <text>沙漠观浴记</text>
        </navLabel>
        <content src="Text/Section0008.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-11" playOrder="11">
        <navLabel>
          <text>爱的寻求</text>
        </navLabel>
        <content src="Text/Section0009.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-12" playOrder="12">
        <navLabel>
          <text>芳邻</text>
        </navLabel>
        <content src="Text/Section0010.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-13" playOrder="13">
        <navLabel>
          <text>素人渔夫</text>
        </navLabel>
        <content src="Text/Section0011.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-14" playOrder="14">
        <navLabel>
          <text>死果</text>
        </navLabel>
        <content src="Text/Section0012.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-15" playOrder="15">
        <navLabel>
          <text>天梯</text>
        </navLabel>
        <content src="Text/Section0013.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-16" playOrder="16">
        <navLabel>
          <text>白手成家</text>
        </navLabel>
        <content src="Text/Section0014.xhtml"/>
      </navPoint>
      <navPoint id="navPoint-17" playOrder="17">
        <navLabel>
          <text>三毛一生大事记</text>
        </navLabel>
        <content src="Text/Section0015.xhtml"/>
      </navPoint>
    </navPoint>
    <navPoint id="navPoint-18" playOrder="18">
      <navLabel>
        <text>制作说明</text>
      </navLabel>
      <content src="Text/by.xhtml"/>
    </navPoint>
  </navMap>
</ncx>
```

### NCX vs OPF spine

NCX 中有章节内容，OPF spine 主要描述章节顺序。NCX 更详细。

参考链接：

[epub 文件结构](https://www.w3.org/AudioVideo/ebook/)

[OCF 文件结构](https://idpf.org/epub/30/spec/epub30-ocf.html#sec-container-metainf)

[OPF 文件结构](https://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.0)

[Epub 基础知识介绍](https://www.cnblogs.com/Alex80/p/5127104.html)
