/* Linker Script 语法可以参⻅：http://www.scoberlin.de/content/media/http/informatik/gcc_docs/ld_3.h
/* ⽬标架构 */
OUTPUT_ARCH(riscv)
/* 执⾏⼊⼝ */
ENTRY(_start)
/* 数据存放起始地址 */
BASE_ADDRESS = 0xffffffff80200000; /* 修改为虚拟地址 */

SECTIONS
{
	/* . 表示当前地址（location counter） */
	. = BASE_ADDRESS;

	/* start 符号表示全部的开始位置 */
	kernel_start = .;

	/* 加⼊对⻬ */
	. = ALIGN(4K);
	text_start = .;

	/* .text 字段 */
	.text : {
		/* 把 entry 函数放在最前⾯ */
		*(.text.entry)
		/* 要链接的⽂件的 .text 字段集中放在这⾥ */
		*(.text .text.*)
	}

	/* 加⼊对⻬ */
	. = ALIGN(4K);
	rodata_start = .;

	/* .rodata 字段 */
	.rodata : {
		/* 要链接的⽂件的 .rodata 字段集中放在这⾥ */
		*(.rodata .rodata.*)
	}

	/* 加⼊对⻬ */
	. = ALIGN(4K);
	data_start = .;

	/* .data 字段 */
	.data : {
		/* 要链接的⽂件的 .data 字段集中放在这⾥ */
		*(.data .data.*)
	}

	/* 加⼊对⻬ */
	. = ALIGN(4K);
	bss_start = .;

	/* .bss 字段 */
	.bss : {
		/* 要链接的⽂件的 .bss 字段集中放在这⾥ */
		*(.sbss .bss .bss.*)
	}

	/* 结束地址 */
	/* 加⼊对⻬ */
	. = ALIGN(4K);
	kernel_end = .;
}
