## arch/arm64/net/Makefile:

OBJECT_FILES_NON_STANDARD_bpf_jit_comp.o := y

warning:

```
arch/arm64/net/bpf_jit_comp.o: warning: objtool: dummy_tramp() falls through to next function jit_fill_hole()
```

> 这个报错是函数调用了一个不会返回的函数(noreturn)，只需要在 `check.c` 中的 `global_noreturns`
> 数组中添加这个不会返回的函数即可，但是这个地方是汇编。

## arch/arm64/kernel/Makefile:

OBJECT_FILES_NON_STANDARD_hyp-stub.o := y

warning:

```
arch/arm64/kernel/hyp-stub.o: warning: objtool: __hyp_stub_vectors+0x0: unreachable instruction
```

OBJECT_FILES_NON_STANDARD_head.o := y

warning:

```
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x3c
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x40
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x44
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x54
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x6c
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x78
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x84
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x94
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x9c
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0xc4
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0xfc
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x104
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x10c
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x11c
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x124
arch/arm64/kernel/head.o: warning: objtool: undecoded insn at .head.text:0x144
```

OBJECT_FILES_NON_STANDARD_proton-pack.o := y

warning:

```
arch/arm64/kernel/proton-pack.o: warning: objtool: qcom_link_stack_sanitisation+0x4: unannotated intra-function call
```

> 如果是汇编代码是可以通过加：`ANNOTATE_INTRA_FUNCTION_CALL` 解决，但是这个是 c 代码。

OBJECT_FILES_NON_STANDARD_entry-fpsimd.o := y

warning:

```
arch/arm64/kernel/entry-fpsimd.o: warning: objtool: undecoded insn at .text:0x3c8
arch/arm64/kernel/entry-fpsimd.o: warning: objtool: undecoded insn at .text:0x3e0
arch/arm64/kernel/entry-fpsimd.o: warning: objtool: undecoded insn at .text:0x3f4
arch/arm64/kernel/entry-fpsimd.o: warning: objtool: undecoded insn at .text:0x40c
free(): invalid pointer
```

OBJECT_FILES_NON_STANDARD_sleep.o := y

```
arch/arm64/kernel/sleep.o: warning: objtool: can't find insn for unwind_hints[0]
```

OBJECT_FILES_NON_STANDARD_efi-rt-wrapper.o := y

```
arch/arm64/kernel/efi-rt-wrapper.o: warning: objtool: __efi_rt_asm_wrapper+0x70: sibling call from callable instruction with modified stack frame
```

> 可以尝试解决

## arch/arm64/kvm/hyp/Makefile:

OBJECT_FILES_NON_STANDARD_hyp-entry.o := y

warning:

```
arch/arm64/kvm/hyp/hyp-entry.o: warning: objtool: .text+0x0: unreachable instruction
```

## arch/arm64/kvm/hyp/vhe/Makefile:

OBJECT_FILES_NON_STANDARD_switch.o := y

warning:

```
arch/arm64/kvm/hyp/vhe/switch.o: warning: objtool: __get_fault_info+0x58: unreachable instruction
```

OBJECT_FILES_NON_STANDARD_hyp-entry.o := y

## arch/arm64/mm/Makefile:

OBJECT_FILES_NON_STANDARD_trans_pgd-asm.o := y

warning:

```
arch/arm64/mm/trans_pgd-asm.o: warning: objtool: hyp_stub_el2t_sync_invalid+0x0: unreachable instruction
```

## drivers/irqchip/Makefile:

OBJECT_FILES_NON_STANDARD_irq-gic-v3.o := y

warning:

```
drivers/irqchip/irq-gic-v3.o: warning: objtool: gic_dist_base_alias.part.0() is missing an ELF size annotation
```

## kernel/bpf/Makefile:

OBJECT_FILES_NON_STANDARD_core.o := y

warning:

```
kernel/bpf/core.o: warning: objtool: ___bpf_prog_run+0x34: sibling call from callable instruction with modified stack frame
```
