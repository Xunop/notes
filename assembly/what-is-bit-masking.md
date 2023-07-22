# 什么是掩码（mask）

记录一下 mask[^1] 这个概念。

掩码（英语：Mask）在计算机学科及数字逻辑中指的是一串二进制数字，通过与目标数字的按位操作
，达到屏蔽指定位而实现需求。

通俗的说，掩码定义了你想要保存的位和什么位你需要清除。

[参考这篇回答](https://stackoverflow.com/questions/10493411/what-is-bit-masking):

> Masking is the act of applying a mask to a value. This is accomplished by doing:
>
> - Bitwise ANDing in order to extract a subset of the bits in the value
> - Bitwise ORing in order to set a subset of the bits in the value
> - Bitwise XORing in order to toggle a subset of the bits in the value

用我自己的话将其描述一遍：masking 通过位运算（and/or/xor）将掩码（mask）作用在我们希望改变的值上。
其中有很好的例子说明，就不再搬运过来了。

---

[^1]: [wikpedia-mask](https://zh.wikipedia.org/zh-cn/掩码)
