# linux kernel hashtable

记录一下自己对 linux kernel 中的 hashtable 实现的理解（当然是查的资料）。
因为最近写的 objtool 就有很多地方用到 hashtable，
不记录一下每次去看都很烦。

## declare hashtable

声明哈希表：

```c
#define DECLARE_HASHTABLE(name, bits)                                   	\
	struct hlist_head name[1 << (bits)]
```

> 有一个叫 `DEFINE_HASHTABLE` 的宏，这个宏是会初始化哈希表，
> `DECLARE_HASHTABLE` 是不会初始化哈希表的。需要使用 `hash_init` 这个宏手动初始化。
> emm, 我看了看感觉这两个效果好像是一样的？

哈希表只是一个固定大小的`hlist_head`数组。
`hlist_head` 结构体如下：

```c
struct hlist_head {
	struct hlist_node *first;
};

struct hlist_node {
	struct hlist_node *next, **pprev;
};
```

这个数组中的每一个都代表一个存储桶，并且是链表的头部。每个存储桶都保存相同哈希的对象（哈希冲突）。
哈希表只是许多个由`struct hlist_node`组成的链表组成的。

## add object to hashtable

往哈希表中加东西：

```c
/**
 * hash_add - add an object to a hashtable
 * @hashtable: hashtable to add to
 * @node: the &struct hlist_node of the object to be added
 * @key: the key of the object to be added
 */
#define hash_add(hashtable, node, key)						\
	hlist_add_head(node, &hashtable[hash_min(key, HASH_BITS(hashtable))])
```

`hash_min` 这个宏用于判断这个元素将进入哪个存储桶。

## iterate all elements

```c
/**
 * hash_for_each - iterate over a hashtable
 * @name: hashtable to iterate
 * @bkt: integer to use as bucket loop cursor
 * @obj: the type * to use as a loop cursor for each entry
 * @member: the name of the hlist_node within the struct
 */
#define hash_for_each(name, bkt, obj, member)				\
	for ((bkt) = 0, obj = NULL; obj == NULL && (bkt) < HASH_SIZE(name);\
			(bkt)++)\
		hlist_for_each_entry(obj, &name[bkt], member)
```

其实是两层遍历，外层遍历用于遍历存储桶，
内层遍历用于遍历元素。

有关更多 hashtable 的实现请看：
[hashtable.h](https://elixir.bootlin.com/linux/v6.4.10/source/include/linux/hashtable.h)

## example

将用模块的形式展示哈希表的使用。

```c
#include <linux/hashtable.h>
#include <linux/module.h>
#include <linux/init.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("xun");
MODULE_DESCRIPTION("hashtable API example");

struct my_node {
        int data;
        struct hlist_node node;
};

DECLARE_HASHTABLE(a, 3);

static int __init my_init(void)
{
        int bkt;
        struct my_node * cur;

        struct my_node first = {
                .data = 10,
                .node = 0
        };
        struct my_node sec = {
                .data = 20,
                .node = 0
        };
        struct my_node third = {
                .data = 30,
                .node = 0
        };

        hash_init(a);

        hash_add(a, &first.node, first.data);
        hash_add(a, &sec.node, sec.data);
        hash_add(a, &third.node, third.data);

        hash_for_each(a, bkt, cur, node) {
                pr_info("myhashtable: element: data = %d\n",
                        cur->data);
        }
        return 0;
}

static void __exit my_exit(void)
{
        pr_info("myhashtable: module unloaded\n");
}

module_init(my_init);
module_exit(my_exit);
```

Makefile:

```
ifneq ($(KERNELRELEASE),)
obj-m :=hashtable.o
else
KDIR :=/lib/modules/$(shell uname -r)/build
all:
	make -C $(KDIR) M=$(PWD) modules
clean:
	rm -f *.ko *.o *.mod.o *.mod.c *.symvers *.order
endif
```

模块加载命令：

```
make
sudo insmod hashtable.ko
sudo dmesg
sudo rmmod hashtable
```

`dmesg`输出：

```
[143076.692484] hashtable: loading out-of-tree module taints kernel.
[143076.692490] hashtable: module verification failed: signature and/or required key missing - tainting kernel
[143076.695218] myhashtable: element: data = 30
[143076.695222] myhashtable: element: data = 20
[143076.695223] myhashtable: element: data = 10
[143101.180665] myhashtable: module unloaded
```

因为直接使用 data 作为 key，所以会出现
`hashtable: module verification failed: signature and/or required key missing - tainting kernel`
这个报错。

## 参考文章：

- [How does the kernel implements Hashtables?](https://kernelnewbies.org/FAQ/Hashtables)

- [How to use the kernel hashtable API?](https://stackoverflow.com/questions/60870788/how-to-use-the-kernel-hashtable-api)
