/* Real Mode Hello World */
#.code16

#
#.global start
#start:
#	movw %cs, %ax
#	movw %ax, %ds
#	movw %ax, %es
#	movw %ax, %ss
#	movw $0x7d00, %ax
#	movw %ax, %sp # setting stack pointer to 0x7d00

#loop:
#	jmp loop


/* Protected Mode Hello World */
#.code16
#
#.global start
#start:
#	movw %cs, %ax
#	movw %ax, %ds
#	movw %ax, %es
#	movw %ax, %ss
#
#.code32
#start32:
#	movw $0x10, %ax # setting data segment selector
#	movw %ax, %ds
#	movw %ax, %es
#	movw %ax, %fs
#	movw %ax, %ss
#loop32:
#	jmp loop32
#
#
#.p2align 2

#.global start
#start:
#    movw %cs, %ax
#    movw %ax, %ds
#    movw %ax, %es
#    movw %ax, %ss
#    movw $0x7d00, %ax
#    movw %ax, %sp # setting stack pointer to 0x7d00
#    pushw $13 # pushing the size to print into stack
#    pushw $message # pushing the address of message into stack
#    callw displayStr # calling the display function
#loop:
#    jmp loop

#message:
#    .string "Hello, World!\n\0"

#displayStr:
#    pushw %bp
#    movw 4(%esp), %ax
#    movw %ax, %bp
#    movw 6(%esp), %cx
#    movw $0x1301, %ax
#    movw $0x000c, %bx
#    movw $0x0000, %dx
#    int $0x10
#    popw %bp
#    ret

/* Protected Mode Hello World */




/* Protected Mode Loading Hello World APP */
.code16

.global start
start:
	movw $message,%ax
	movw %ax,%bp
	movw $13,%cx
	movw $0x1301,%ax
	movw $0x000c,%bx
	movw $0x0800,%dx
	int $0x10 
	movw %cs, %ax
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %ss
	#TODO: Protected Mode Here


	cli
	inb $0x92,%al       #enable a20
	orb $0x02,%al
	outb %al,$0x92
	data32 addr32 lgdt gdtDesc 	#exec gdtr
	

	movl %cr0,%eax
	orb $0x1,%al
	movl %eax,%cr0      # set cr0
	data32 ljmp $0x08, $start32 	#长跳转切换至保护模式	

.code32
start32:
	movw $0x10, %ax # setting data segment selector
	movw %ax, %ds
	movw %ax, %es
	movw %ax, %fs
	movw %ax, %ss
	movw $0x18, %ax # setting graphics data segment selector
	movw %ax, %gs
	
	movl $0x8000, %eax # setting esp
	movl %eax, %esp


	pushl $13
	pushl $message
	calll displayStr
	jmp bootMain # jump to bootMain in boot.c   #  如果load app，注释下三行，否则这一行




loop32:
	jmp loop32

message:
	.string "Hello, World!\n\0"

displayStr:
	movl 4(%esp), %ebx
	movl 8(%esp), %ecx
	movl $((80*5+0)*2), %edi
	movb $0x0c, %ah
nextChar:
	movb (%ebx), %al
	movw %ax, %gs:(%edi)
	addl $2, %edi
	incl %ebx
	loopnz nextChar # loopnz decrease ecx by 1
	ret		

.p2align 2
gdt: # 8 bytes for each table entry, at least 1 entry
	.word 0,0 #GDT第一个表项必须为空
	.byte 0,0,0,0

	.word 0xffff,0  #代码段描述符
	.byte 0,0x9a,0xcf,0

	.word 0xffff,0  #数据段描述符
	.byte 0,0x92,0xcf,0

	.word 0xffff,0x8000  #视频段描述符
	.byte 0x0b,0x92,0xcf,0

gdtDesc: 
	.word (gdtDesc - gdt -1) 
	.long gdt  # address gdt .long后面的参数为gdt运行时生成的值，即gdt表的地址

