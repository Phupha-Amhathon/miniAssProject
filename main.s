global _start 
section .data 
	;store op1 at r11 and operator add r12
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;count <<;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SYS_write 	equ	1	;sys code 
	STDOUT	equ	1 	;output location 
	NULL	equ	0
	msgInstruction1 db	"Enter statement: ", NULL 
	errMsg		db	"fuck", NULL
	;rax move sys_code 
	;rdi move output location , stdout 
	;rsi = address of characters to output 
	;rdx = Number of characters to output
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cin;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	SYS_read	equ	0
	SYS_exit	equ	60
	STDIN		equ	STDOUT 
	STDERR		equ	2
	EXIT_SUCCESS	equ	0
	LF	equ	10 

	newLine		db	LF, NULL 
	;rax selected sys servcie after called it return how many number of byte was read 
	;rsi address to stores readed charactor 
	;rdx number of character to read 
	
	MULTIPLICATION 	equ	42
	ADDITION	equ	43
	SUBTRACTION	equ	45		
	FLOORDIVISION 	equ	47
	SPACE		equ	32
	opd1	db 0
	opd2	db 0
	debug1Msg	db	"debug111111111111 ", NULL 
;;;;;;;error message;;;;;;;;;;;;;;;;;;
	errOperand1		db	"invalid operand1", NULL
	errOperand2		db	"invalid operand2", NULL
	errOperator		db	"invalid operator", NULL 
	
section .bss
	buffer	resb	255	;input buffer 
section .text 
_start:
	mov rdi, msgInstruction1
	call printString
	
	;reading  
	mov rax, SYS_read 
	mov rdi, STDIN 
	mov rsi, buffer 
	mov rdx, 255 
	syscall 
	mov byte[buffer + rax], NULL ;;;;mark the terminator of current buffer 

	jmp maibok
exit: 
	mov rax, EXIT_SUCCESS
	mov rdi, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cin func;;;;;;;;;;;;;;;;;;;;;;;;;;;
global maibok
maibok:
	push rbx
	push r11
	push r9
	xor r9, r9 
	xor r11, r11
	mov rbx, buffer
	call trimSpace	
firstOp:
	mov rcx, 4

	cmp byte[rbx], NULL 
	je invalidOp1
firstOpLoop:
	cmp byte[rbx], NULL 
	je firstOpDone
	cmp byte[rbx], 48 
	jl firstOpDone
	cmp byte[rbx], 57
	jg firstOpDone

	movzx r10, byte[rbx]
	sub r10, 48
	imul r11, 10
	add r11, r10

	inc rbx
	dec rcx 
	cmp rcx, 0 
	jne firstOpLoop
firstOpDone:
	
	call trimSpace	
operator: 
	cmp byte[rbx], ADDITION 
	je skipInvalidOperator
	cmp byte[rbx], SUBTRACTION
	je skipInvalidOperator
	cmp byte[rbx], MULTIPLICATION
	je skipInvalidOperator
	cmp byte[rbx], FLOORDIVISION
	je skipInvalidOperator 
	cmp rcx, 0 
	je invalidOperator
	jmp invalidOp1
skipInvalidOperator:
	mov r12, rbx
	inc rbx

	call trimSpace
secOp:
	mov rcx, 2
	xor r10, r10 
	xor r11, r11
	cmp byte[rbx], NULL 
	je invalidOp2
	cmp byte[rbx], LF
	je invalidOp2
secOpLoop:
	cmp byte[rbx], NULL 
	je secOpDone
	cmp byte[rbx], LF 
	je secOpDone
	cmp byte[rbx], SPACE
	je secOpDone
	cmp byte[rbx], 48 
	jl invalidOp2
	cmp byte[rbx], 57
	jg invalidOp2

	movzx r10, byte[rbx]
	sub r10, 48
	imul r11, 10
	add r11, r10

	inc rbx
	dec rcx 

	cmp rcx, 0 
	jne secOpLoop
secOpDone:
	jmp maibokDone
invalidOp1:
	mov rdi, errOperand1
	jmp failDone
invalidOp2:
	mov rdi, errOperand2
	jmp failDone
invalidOperator:
	mov rdi, errOperator
	jmp failDone
failDone:
	call printString 
maibokDone:	
	pop r11
	pop rbx
	ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;function for trim space;;;;;;;;;;;;;;;;;;;;;;
;promise , string buffer in rbx register
global trimSpace
trimSpace:
	cmp byte[rbx], SPACE 
	jne trimSpaceDone
	inc rbx
	jmp trimSpace
trimSpaceDone:
	ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;count func;;;;;;;;;;;;;;;;;;;;;
global printString 
printString: 
	push rbx 
	mov  rbx, rdi 
	mov  rdx, 0 
strCountLoop:
	cmp byte [rbx], NULL 
	je strCountDone 
	inc rbx
	inc rdx
	jmp strCountLoop
strCountDone:
	cmp rdx, 0 
	je prtDone

	mov rax, SYS_write 
	mov rsi, rdi
	mov rdi, STDOUT 
	syscall
prtDone: 
	pop rbx
	ret 
;handout for this func -> move target message to rdi then call this function 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
