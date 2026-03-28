global _start 
section .data 
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
	;rsi address to stores readed charactor 
	;rdx number of character to read 
	
	MULTIPLICATION 	equ	52
	ADDITION	equ	53
	SUBTRACTION	equ	55		
	FLOORDIVISION 	equ	57
	SPACE		equ	32
	opd1	db 0
	opd2	db 0
	debug1Msg	db	"debug111111111111 ", NULL 
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

	;mov rax, SYS_write 
	;mov rdi, STDOUT
	;mov rsi, buffer
	;sub rsi, 52 
	; compare thing then 
	;add rsi, 52
	;mov rdx, 255
	;syscall
	jmp maibok
exit: 
	mov rax, EXIT_SUCCESS
	mov rdi, 0
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;cin func;;;;;;;;;;;;;;;;;;;;;;;;;;;
global maibok
maibok:
	push rbx
	mov rbx, buffer
	call trimSpace	
firstOp:
	mov rcx, 4 
firstOpLoop:
	cmp byte[rbx], 48 
	
	;;;;debugging
	;movzx rdi, byte[rbx]
	;call printString

	je debug1
	cmp byte[rbx], 57
	jg failDone

	movzx r10, byte[rbx]
	sub r10, 48
	imul r11, 10
	add r11, r10
	pop rdx
	pop rax

	inc rbx
	dec rcx 
	cmp rcx, 0 
	jne firstOpLoop
	
	mov rdi, r11
	add rdi, 48
	call printString 
	;mov rdi, rbx
	;call printString
maibokDone:	
	pop rbx
	ret
failDone:
	mov rdi, errMsg
	call printString 
wellDone:
debug1: 
	mov rdi, debug1Msg
	call printString

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;function for trim space;;;;;;;;;;;;;;;;;;;;;;
;promise , string buffer in rbx register
global trimSpac
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
	
