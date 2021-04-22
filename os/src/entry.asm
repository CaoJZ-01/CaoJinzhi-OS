# 操作系统启动时所需的指令以及字段
#
# 我们在 linker.ld 中将程序⼊⼝设置为了 _start，因此在这⾥我们将填充这个标签
# 它将会执⾏⼀些必要操作，然后跳转⾄我们⽤ rust 编写的⼊⼝函数
#
# 关于 RISC-V 下的汇编语⾔，可以参考 https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.m
# %hi 表示取 [12,32) 位，%lo 表示取 [0,12) 位
	.section .text.entry
	.globl _start
# ⽬前 _start 的功能：将预留的栈空间写⼊ $sp，然后跳转⾄ rust_main
_start:
	# 计算 boot_page_table 的物理⻚号
	lui t0, %hi(boot_page_table)
	li t1, 0xffffffff00000000
	sub t0, t0, t1
	srli t0, t0, 12
	# 8 << 60 是 satp 中使⽤ Sv39 模式的记号
	li t1, (8 << 60)
	or t0, t0, t1
	# 写⼊ satp 并更新 TLB
	csrw satp, t0
	sfence.vma

	# 加载栈地址
	lui sp, %hi(boot_stack_top)
	addi sp, sp, %lo(boot_stack_top)
	# 跳转⾄ rust_main
	lui t0, %hi(rust_main)
	addi t0, t0, %lo(rust_main)
	jr t0

	# 回忆：bss 段是 ELF ⽂件中只记录⻓度，⽽全部初始化为 0 的⼀段内存空间
	# 这⾥声明字段 .bss.stack 作为操作系统启动时的栈
	.section .bss.stack
	.global boot_stack
boot_stack:
	# 16K 启动栈⼤⼩
	.space 4096 * 16
	.global boot_stack_top
boot_stack_top:
	# 栈结尾
	# 初始内核映射所⽤的⻚表
	.section .data
	.align 12
boot_page_table:
	.quad 0
	.quad 0
	# 第 2 项：0x8000_0000 -> 0x8000_0000，0xcf 表示 VRWXAD 均为 1
	.quad (0x80000 << 10) | 0xcf
	.zero 507 * 8
	# 第510项：0xffff_ffff_8000_0000 -> 0x8000_0000，0xcf表示VRWXAD均为1
	.quad (0x80000 << 10) | 0xcf
	.quad 0

