	.file	"cs.c"
	.text
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"%p\n"
	.text
	.globl	qux
	.type	qux, @function
qux:
.LFB11:
	.cfi_startproc
  # Save the current value of the base pointer (rbp) onto the stack
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	# Set the base pointer to the current stack frame by copying the stack pointer (rsp) into it
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	# Save the current value of the base pointer (rbx) onto the stack
	pushq	%rbx
	# Allocate space on the stack by subtracting 8 from the stack pointer (rsp)
	subq	$8, %rsp
	.cfi_offset 3, -24
 	# Copy the value of the base pointer (rbp) into rbx
	movq	%rbp, %rbx
.L2:
	# Copy the value of rbx into the second argument register (rsi) for the printf function call
	movq	%rbx, %rsi
	# Load the address of the string ".LC0" into the first argument register (rdi) for the printf function call
	leaq	.LC0(%rip), %rdi
	# Set the return value register (eax) to 0
	movl	$0, %eax
	# Call the printf function
	call	printf@PLT
	# Copy the value of rbx into the return value register (rax)
	movq	%rbx, %rax
	# Load the value at the memory location pointed to by rbx into rbx
	movq	(%rbx), %rbx
	# Compare the value in rbx with the value in the return value register (rax)
	# If the value in rbx is less than the value in rax, jump back to label .L2
	cmpq	%rbx, %rax
	jb	.L2
	# Load the value at memory location 8 bytes below the current base pointer (rbp) into rbx
	movq	-8(%rbp), %rbx
	# Restore the previous value of the base pointer (rbp) by copying it from the stack into the base pointer register
	# two instructions below are equivalent to leave
	# 	movq	%rbp, %rsp
	# 	popq	%rbp
	leave
	.cfi_def_cfa 7, 8
	# Return from the function
	ret
	.cfi_endproc
.LFE11:
	.size	qux, .-qux
	.globl	bar
	.type	bar, @function
bar:
.LFB12:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$0, %eax
	call	qux
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE12:
	.size	bar, .-bar
	.globl	foo
	.type	foo, @function
foo:
.LFB13:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$0, %eax
	call	bar
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE13:
	.size	foo, .-foo
	.globl	main
	.type	main, @function
main:
.LFB14:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$0, %eax
	call	foo
	movl	$0, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE14:
	.size	main, .-main
	.ident	"GCC: (GNU) 13.1.1 20230429"
	.section	.note.GNU-stack,"",@progbits
