global _start 
section .data 
	;store op1 at r9 , op2 at r11 and operator at r12, r9 = (r9) <r12> (r11)
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
	EXIT_SUCCESS	equ	60
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

	call maibok
	jmp exit
exit: 
	mov rax, EXIT_SUCCESS
	mov rdi, 0
	syscall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cin func;;;;;;;;;;;;;;;;;;;;;;;;;;;
global maibok
maibok:
	push rbx
	push r9		;first operand
	push r10	;temp
	push r11	;second operand
	push r12	;operator
	xor r9, r9 
	xor r10, r10
	xor r11, r11
	xor r12, r12
	mov rbx, buffer
	call trimSpace	

firstOp:
	mov rcx, 4	;extract first 4 valid digit , excess one consider to be operator 
	cmp byte[rbx], NULL 
	je invalidOp1

firstOpLoop:
	cmp byte[rbx], SPACE	;treat SPACE as terminate point of operand1
	je firstOpDone
	cmp byte[rbx], 48 
	jl firstOpDone
	cmp byte[rbx], 57
	jg firstOpDone
	
	; r9 = 10*r9 + (ascii - 48)
	movzx r10, byte[rbx]
	sub r10, 48
	imul r9, 10
	add r9, r10

	;loop thing 
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

	;consider if exited first op loop with ascii that not in range 48 - 57 or space 
	;then it migt be one of available operator, which was previously checked by above block and skipped this. 
	;eventually it must be 
	cmp rcx, 0 
	je invalidOperator
	jmp invalidOp1

skipInvalidOperator:
	movzx r12, byte[rbx]
	inc rbx

	call trimSpace
	xor r10, r10 
secOp:
	mov rcx, 4
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

	;loop thing 
	inc rbx
	dec rcx 
	cmp rcx, 0 
	jne secOpLoop

	;loop done
	call trimSpace
	cmp byte[rbx], NULL 
	je secOpDone
	cmp byte[rbx], LF
	je secOpDone 
	jmp invalidOp2
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
	jmp maibokDone 
maibokDone:	
	pop r12 
	pop r11
	pop r10
	pop r9
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
	
