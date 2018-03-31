@ SNES_controller: 

@ Is used by:

@ Uses:

gpio_bA		.req	r11
clearMask	.req	r10
pButton		.req	r9

.text

.global GPIO_init, button_press


GPIO_init:
	push	{fp, lr}
	
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

	pop	{fp, pc}


button_press:
	push	{r4, fp, lr}

wait_press:
	mov	r4, #0xffff

	bl 	read_SNES
	cmp	r0, r4
	beq	wait_press
	
read_press:				@ fix (idk)
	bl 	read_SNES

	cmp	pButton, r0		
	beq 	wait_press		@ 

	cmp	r0, r4			
	beq	wait_press

@	mov 	pButton, r0
@	mov 	r0,pButton		
	bl	check_button
	
	pop	{r4, fp, pc}


@@@@@ ---------- Subroutines ---------- @@@@@


init_GPIO:
	mov r3, #10				@ Get function Select Register number
	sdiv r0, r0, r3
	mov r6, r0				@ Keep parameters to safe variables
	mov r4, r1

	@ Get least significant digit of line number and control bit for that digit
	mov r3, #10
	mul r1, r0, r3
	sub r1, r6, r1
	mov r3, #3
	mul r5, r1, r3

	ldr	r0, [gpio_bA, r6, lsl #2] 	@ Load the value of Function Select Register 

	mov	r1, #7				@ Clear bits
	bic	r0, r1, lsl r5

	orr	r0, r4, lsl r5			@ Set bits to function code

	str	r0, [gpio_bA, r6, lsl #2]	@ Write back to Function Select Register 1

	mov	pc, lr				@ Returns call

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

B:
	tst	r1, pButton
	bne	print_Y

	pop	{pc}			

Y:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_select

	pop	{pc}

select:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_start

	pop	{pc}			

start:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_up

	pop	{pc}			

up:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_down

	pop	{pc}			@ Return call

down:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_left

	pop	{pc}			@ Return call

left:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_right

	pop	{pc}			@ Return call

right:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_A

	pop	{pc}			@ Return call

A:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_X

	pop	{pc}			@ Return call

X:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_lB

	pop	{pc}			@ Return call

lB:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_rB

	pop	{pc}			@ Return call

rB:
	lsl	r1, #1
	tst	r1, pButton
	bne	end_print

end_print:
	pop	{pc}			@ Return call


@--------------------------------------------------------------------------------------


.section	.data

GPIO_baseAddr:	.word	0
