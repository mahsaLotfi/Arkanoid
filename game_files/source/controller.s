@ Assignment 3
@ Created by: Kevin Huynh 10162332, Heavenal Cerna and Austin So

gpio_bA		.req	r11
clearMask	.req	r10
pButton		.req	r9

.section	.text



.global main
main:
	ldr	r0, =authors		@ Prints the authors' names
	bl	printf
	
	bl	getGpioPtr		@ Called to get	base address of GPIO in r0
	ldr	r1, =GPIO_baseAddr	@ Loads GPIO_baseAddr address into r1
	str	r0, [r1]		@ Stores GPIO base address into GPIO_baseAddr address
	ldr	r0, =GPIO_baseAddr	@ ldr	r0, =0x3F200000
	ldr	gpio_bA, [r0]		@ Saves GPIO base address to r4

	@ Initializes the SNES lines
	mov	r0, #9			@ GPIO 9 = Latch line
	mov	r1, #1			@ Output function code
	bl	init_GPIO		@ Latch line to output

	mov	r0, #11			@ GPIO 10 = Clock line
	mov	r1, #1			@ Output function code
	bl	init_GPIO		@ Clock line to output

	mov	r0, #10			@ GPIO 11 = Data line
	mov	r1, #0			@ Input function code
	bl	init_GPIO		@ Data line to input


	mov	r4, #0xffff
prompt_loop:
	ldr	r0, =prompt		@ 
	bl	printf			@ 
	

wait:
	bl 	read_SNES
	mov	pButton, r0		

	mov 	r0,#10000		
	bl	delayMicroseconds
	
	bl 	read_SNES

	cmp	pButton, r0		
	beq 	wait			@ 

	cmp	r0, r4			
	beq	wait

	mov 	pButton, r0
	mov 	r0,pButton		
	bl	check_button

	cmp	pButton, #4
	bne 	prompt_loop


haltLoop$:
	b		haltLoop$


@@@@@ ---------- Subroutines ---------- @@@@@


init_GPIO:
	cmp 	r0,#9
	beq 	init_latch
	
	cmp 	r0,#11
	beq 	init_clock
		
	b 	init_data

init_latch:
	ldr 	r3,[gpio_bA]		
	
	mov 	r4, #0b111		
	bic	r3,r4,lsl #27		

	orr 	r3,r1,lsl #27		
	str 	r3,[gpio_bA]		

	mov	pc, lr 	

init_data:

	ldr 	r3,[gpio_bA, #0x04]	
	
	mov 	r4, #0b111		
	bic	r3,r4			

	orr 	r3,r1			
	str 	r3,[gpio_bA, #0x04]	

	mov	pc, lr

init_clock:
	ldr 	r3,[gpio_bA, #0x04]	

	mov 	r4, #0b111		
	bic	r3,r4,lsl #3		

	orr 	r3,r1,lsl #3		
	str 	r3,[gpio_bA, #0x04]	

	mov	pc, lr

write_latch:
	push	{r4}
	mov	r1, #9			@ 
	ldr	r4, =GPIO_baseAddr	@ 
	ldr	r2, [r4]		@ 
	mov	r3, #1			@ 
	lsl	r3, r1			@ 

	teq	r0, #0			@ 

	streq	r3, [r2, #40]		@ 
	strne	r3, [r2, #28]		@ 
	pop	{r4}

	mov	pc, lr			@ Return call


write_clock:
	push	{r4}
	mov	r1, #11			@ 
	ldr	r4, =GPIO_baseAddr	@ 
	ldr	r2, [r4]		@ 
	mov	r3, #1			@ 
	lsl	r3, r1			@ 

	teq	r0, #0			@ 

	streq	r3, [r2, #40]		@ 
	strne	r3, [r2, #28]		@ 
	pop	{r4}

	mov	pc, lr			@ Return call


read_data:
	push	{r4,r7}
	mov	r0, #10			@ 
	ldr	r4, =GPIO_baseAddr	@ 
	ldr	r7, [r4]		@ 
	ldr	r1, [r7, #52]		@ 
	mov	r3, #1			@ 
	lsl	r3, r0			@ 

	and	r1, r3			@ 
	teq	r1, #0			@ 

	moveq	r0, #0			@ 
	movne	r0, #1			@ 
	pop	{r4,r7}

	mov	pc, lr			@ Return call


read_SNES:
	push	{r7,r8,lr}
	mov	r0, #1			@
	bl	write_clock		@ 

	mov	r0, #1			@ 
	bl	write_latch		@ 

	mov	r0, #12			@ 
	bl	delayMicroseconds	@

	mov	r0, #0			@ 
	bl	write_latch		@ 

	mov	r7, #0			@ Sampling button
	mov	r8, #0			@ Loop counter


clock_loop:
	mov	r0, #6			@ 
	bl	delayMicroseconds	@ 

	mov	r0, #0			@ 
	bl	write_clock		@ 

	mov	r0, #6			@ 
	bl	delayMicroseconds	@ 

	bl	read_data		@ 
	lsl	r0, r7			@ 
	orr	r8, r0			@ 

	mov	r0, #1			@ 
	bl	write_clock		@ 

	add	r7, #1			@ 
	cmp	r7, #16			@ 
	blt	clock_loop		@ 
	mov	r0, r8			@ 
	pop	{r7,r8,pc}		@ 


@ Checks which button is presssed
check_button:
	push	{lr}
	mov	r1, #1

print_B:
	tst	r1, pButton
	bne	print_Y
	ldr	r0, =b_button		@ Prints X string
	bl	printf

	pop	{pc}			

print_Y:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_select
	ldr	r0, =y_button		@ Prints Y string
	bl	printf

	pop	{pc}

print_select:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_start
	ldr	r0, =select		@ Prints A string
	bl	printf

	pop	{pc}			

print_start:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_up
	ldr	r0, =start		@ Prints B string
	bl	printf

	b	haltLoop$			

print_up:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_down
	ldr	r0, =joy_up		@ Prints select string
	bl	printf

	pop	{pc}			@ Return call

print_down:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_left
	ldr	r0, =joy_down		@ Prints start string
	bl	printf

	pop	{pc}			@ Return call

print_left:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_right
	ldr	r0, =joy_left		@ Prints up string
	bl	printf

	pop	{pc}			@ Return call

print_right:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_A
	ldr	r0, =joy_right		@ Prints down string
	bl	printf

	pop	{pc}			@ Return call

print_A:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_X
	ldr	r0, =a_button		@ Prints left string
	bl	printf

	pop	{pc}			@ Return call

print_X:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_lB
	ldr	r0, =x_button		@ Prints right string
	bl	printf

	pop	{pc}			@ Return call

print_lB:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_rB
	ldr	r0, =left_trigger	@ Prints left trigger
	bl	printf

	pop	{pc}			@ Return call

print_rB:
	lsl	r1, #1
	tst	r1, pButton
	bne	end_print
	ldr	r0, =right_trigger	@ Prints right trigger
	bl	printf

end_print:
	pop	{pc}			@ Return call


@--------------------------------------------------------------------------------------


.section	.data


GPIO_baseAddr:	.word	0

authors:	.asciz	"\nCreated by: Kevin Huynh, Heavenel Cerna and Austin So\n"
prompt:		.asciz	"\nPlease press a button...\n"
x_button:	.asciz	"\nYou have pressed X\n"
y_button:	.asciz	"\nYou have pressed Y\n"
a_button:	.asciz	"\nYou have pressed A\n"
b_button:	.asciz	"\nYou have pressed B\n"
select:		.asciz	"\nYou have pressed Select\n"
start:		.asciz	"\nProgram is terminating...\n"
joy_up:		.asciz	"\nYou have pressed Joy-pad UP\n"
joy_down:	.asciz	"\nYou have pressed Joy-pad DOWN\n"
joy_left:	.asciz	"\nYou have pressed Joy-pad LEFT\n"
joy_right:	.asciz	"\nYou have pressed Joy-pad RIGHT\n"
left_trigger:	.asciz	"\nYou have pressed LEFT trigger\n"
right_trigger:	.asciz	"\nYou have pressed RIGHT trigger\n"
