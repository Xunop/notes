objtool 执行顺序：

```
main -> objtool_run -> objtool_open_read -> check -> decode_sections
-> decode_instructions
```

目前问题在于 `decode_instructions` 函数中，在这段`if` 判断语句中会出现问题：

```c
			if (!find_insn(file, sec, func->offset)) {
				WARN("%s(): can't find starting instruction",
				     func->name);
				return -1;
			}
```

> 解决，将`decode_instructions`函数中以下代码注释：
>
> ```c
> 			struct symbol *obj_sym = find_object_containing(sec, offset);
> 			if (obj_sym) {
> 				/* This is data in the middle of text section, skip it */
> 				next_offset = obj_sym->offset + obj_sym->len;
> 				continue;
> 			}
> ```
>
> 原因：会有部分指令在这里跳过，导致后面的哈希表无法加入这些指令：
>
> `hash_add(file->insn_hash, &insn->hash, sec_offset_hash(sec, insn->offset));`

```c
struct instruction *find_insn(struct objtool_file *file,
			      struct section *sec, unsigned long offset)
{
	struct instruction *insn;

	hash_for_each_possible(file->insn_hash, insn, hash, sec_offset_hash(sec, offset)) {
		if (insn->sec == sec && insn->offset == offset)
			return insn;
	}

	return NULL;
}
```

一些宏的定义：

```c
/**
 * hash_for_each_possible - iterate over all possible objects hashing to the
 * same bucket
 * @name: hashtable to iterate
 * @obj: the type * to use as a loop cursor for each entry
 * @member: the name of the hlist_node within the struct
 * @key: the key of the objects to iterate over
 */
#define hash_for_each_possible(name, obj, member, key)			\
	hlist_for_each_entry(obj, &name[hash_min(key, HASH_BITS(name))], member)

/**
 * hlist_for_each_entry	- iterate over list of given type
 * @pos:	the type * to use as a loop cursor.
 * @head:	the head for your list.
 * @member:	the name of the hlist_node within the struct.
 */
#define hlist_for_each_entry(pos, head, member)				\
	for (pos = hlist_entry_safe((head)->first, typeof(*(pos)), member);\
	     pos;							\
	     pos = hlist_entry_safe((pos)->member.next, typeof(*(pos)), member))
```

```c
#define for_each_sec(file, sec)						\
	list_for_each_entry(sec, &file->elf->sections, list)


#define sec_for_each_sym(sec, sym)					\
	list_for_each_entry(sym, &sec->symbol_list, list)

/**
 * list_for_each_entry	-	iterate over list of given type
 * @pos:	the type * to use as a loop cursor.
 * @head:	the head for your list.
 * @member:	the name of the list_head within the struct.
 */
#define list_for_each_entry(pos, head, member)				\
	for (pos = list_first_entry(head, typeof(*pos), member);	\
	     !list_entry_is_head(pos, head, member);			\
	     pos = list_next_entry(pos, member))
```

```c
#define sec_for_each_insn(file, _sec, insn)				\
	for (insn = find_insn(file, _sec, 0);				\
	     insn && insn->sec == _sec;					\
	     insn = next_insn_same_sec(file, insn))

#define for_each_insn(file, insn)					\
	for (struct section *__sec, *__fake = (struct section *)1;	\
	     __fake; __fake = NULL)					\
		for_each_sec(file, __sec)				\
			sec_for_each_insn(file, __sec, insn)
```

接下来要做的事：

1. 解决 `unreachable instruction` 警告。

2. 解决 `call without frame pointer save/setup` 警告。

3. 解决 `unannotated intra-function call` 警告。

## unreachable instruction

将 patch 13 14 15 加入回合到 kernel 中。

## call without frame pointer save/setup

查看 patch

## unannotated intra-function

查看patch
