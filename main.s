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
	STDIN		equ	0       ; (Fixed to 0 so SYS_read works properly)
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
  errDivZero		db	"division by zero error", NULL ; (copter): added error message for division by zero
  errOutOfRange	db	"out of range error", NULL ; (copter): added error message for out of range
	
section .bss
	buffer	resb	255	;input buffer 
  ; (Removed error flags)

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
 ;   cmp byte[rbx], SUBTRACTION ; (copter): treat '-' as terminate point of operand1
  ;  je invalidOp1          ;(copter): '-' is not allowed in operand1

	cmp byte[rbx], SPACE	;treat SPACE as terminate point of operand1
	je firstOpDone

	cmp byte[rbx], ADDITION         ; (copter): treat '+' as terminate point of operand1
	je firstOpDone                  ; (copter): jump out of loop safely
	cmp byte[rbx], SUBTRACTION      ; (copter): treat '-' as terminate point of operand1
	je firstOpDone                  ; (copter): jump out of loop safely
	cmp byte[rbx], MULTIPLICATION   ; (copter): treat '*' as terminate point of operand1
	je firstOpDone                  ; (copter): jump out of loop safely
	cmp byte[rbx], FLOORDIVISION    ; (copter): treat '/' as terminate point of operand1
	je firstOpDone                  ; (copter): jump out of loop safely
	
	; (Fixed logic: catch invalid letters here immediately!)
	cmp byte[rbx], 48 
	jl invalidOp1
	cmp byte[rbx], 57
	jg invalidOp1
	
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
; (copter): check if any digit was read for operand1
	; rcx started at 4, if still 4 --> leading '-'
	cmp rcx, 4
	je invalidOp1

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

	; (Fixed logic: If it didn't jump from checks above, it's definitely invalid)
	jmp invalidOperator

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
    cmp byte[rbx], SUBTRACTION
    je invalidOp2          ;(copter): '-' is not allowed in operand2

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
  ; Now r9 has opr1 (r9), r11 has opr2, r12 has operator
  ; (copter): Perform calculation and store result in rax
  mov rax, r9

  cmp r12, ADDITION
  je doAdd
  
  cmp r12, SUBTRACTION
  je doSub
  
  cmp r12, MULTIPLICATION
  je doMul
  
  cmp r12, FLOORDIVISION
  je doDiv

doAdd:
  add rax, r11
  jmp printResult

doSub:
  sub rax, r11
  jmp printResult

doMul:
  mul r11				; (copter): rax = rax * r11 and rdx will be 0 because numbers are small
  jmp printResult

doDiv:
  cmp r11, 0            ; (copter): check if divisor op2 is zero
  je invalidDivZero         ; (copter): if it is 0, jump to error handler
  xor rdx, rdx			; (copter): clear rdx for division
  div r11				; (copter): rax = floor(rax / r11)
  jmp printResult

printResult:

  cmp rax, 0            ; (copter): check if result is less than 0
  jl invalidRange       ; (copter): if negative, throw error

  cmp rax, 9999         ; (copter): check if result is greater than 9999
  jg invalidRange       ; (copter): if too big, throw error

  ; (copter): result is now in rax ---> print it as decimal string
  call printNumber

  ; (copter): print newline after the result 
  mov rdi, newLine
  call printString

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

invalidDivZero:         ; (copter): new error handler block
	mov rdi, errDivZero ; (copter): load the "divide by 0 error" string
	jmp failDone        ; (copter): print it and exit

invalidRange:           ; (copter): new error handler block
	mov rdi, errOutOfRange ; (copter): load the "out of range error" string
	jmp failDone        ; (copter): print it and exit

failDone:
    call printString

    ; (copter): print newline after error message
	mov rdi, newLine
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
	
global printNumber
printNumber:
	push rbx
	mov rbx, 10
	xor rcx, rcx			; (copter): count number of digits

digitLoop:				
	xor rdx, rdx
	div rbx
	add rdx, 48				; (copter): remainder 
	push rdx
	inc rcx
	test rax, rax
	jnz digitLoop

	; (copter): now rcx = number of digits
	mov rbx, rcx			; (copter): move counter to rbx

printLoop:					; (copter): print digits from highest to lowest
	mov rax, SYS_write
	mov rdi, STDOUT
	mov rsi, rsp			; (copter): low byte of stack top is the asscii char
	mov rdx, 1
	syscall
	pop rdx
	dec rbx
	jnz printLoop			; (copter): use rbx instead of rcx

	pop rbx
	ret
