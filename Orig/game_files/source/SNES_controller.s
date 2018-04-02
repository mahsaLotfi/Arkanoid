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

wait:
	bl 	read_SNES
	mov	pButton, r0		

	@ mov 	r0,#10000		
	@ bl	delayMicroseconds
	
	bl 	read_SNES

	cmp	pButton, r0		
	beq 	wait			@ 

	cmp	r0, r4			
	beq	wait

	mov 	pButton, r0
	mov 	r0,pButton		
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
	mov	r1, #9			@ move number9 into r1
	ldr	r4, =GPIO_baseAddr	@ lpad GPIO base address into r4
	ldr	r2, [r4]		@ load r4 content into r2
	mov	r3, #1			@ move number 1 into r3
	lsl	r3, r1			@ logical shift left 9 bits for r3

	teq	r0, #0			@ test equal r0 to number 0

	streq	r3, [r2, #40]		@ store r3 into r2 plus 40 if r0 equal to 0
	strne	r3, [r2, #28]		@ store r3 into r2 plus 28 if r0 not equal to 0
	pop	{r4}

	mov	pc, lr			@ Return call


write_clock:
	push	{r4}
	mov	r1, #11			@ mov number 11 into r1
	ldr	r4, =GPIO_baseAddr	@ load GPIO base address into r4
	ldr	r2, [r4]		@ load r2 with r4
	mov	r3, #1			@ mov number1 into r3
	lsl	r3, r1			@ logical shift left r3 11 bits

	teq	r0, #0			@ test equal r0 to 

	streq	r3, [r2, #40]		@ store r3 into r2 plus 40 if r0 equal to 0
	strne	r3, [r2, #28]		@ store r3 into r2 plus 28 if r0 not equal to 0
	pop	{r4}

	mov	pc, lr			@ Return call


read_data:
	push	{r4,r7}
	mov	r0, #10			@ move number 10 into r0
	ldr	r4, =GPIO_baseAddr	@ load GPIO basse address into r4
	ldr	r7, [r4]		@ load r7 with r4
	ldr	r1, [r7, #52]		@ load r1 with r7 plus 52
	mov	r3, #1			@ move number 1 into r3
	lsl	r3, r0			@ logical shift left r3 10 bits

	and	r1, r3			@ and r1 and r3 then store in r1
	teq	r1, #0			@ test equal r1 with 0

	moveq	r0, #0			@ move number 0 into r0 if r1 = 0
	movne	r0, #1			@ move number 1 into r0 if r1 != 0
	pop	{r4,r7}

	mov	pc, lr			@ Return call


read_SNES:
	push	{r7,r8,lr}
	mov	r0, #1			@ move number 1 into r0
	bl	write_clock		@ branch link to write_clock function

	mov	r0, #1			@ move nummber 1 into r0
	bl	write_latch		@  branch link to write_latch

	mov	r0, #12			@ move number 12 into r0
	bl	delayMicroseconds	@ brnach link to delatMicrseconds function

	mov	r0, #0			@ move number 0 into r0
	bl	write_latch		@ branch link to write_latch

	mov	r7, #0			@ Sampling button
	mov	r8, #0			@ Loop counter


clock_loop:
	mov	r0, #6			@ move number 6 into r0
	bl	delayMicroseconds	@ branch link to delayMicraseconds function

	mov	r0, #0			@ move number 0 into r0
	bl	write_clock		@ branch link to wrote_clock function

	mov	r0, #6			@ move number 6 into r0
	bl	delayMicroseconds	@ branch link to delayMicroseconds function

	bl	read_data		@ branch link read_data function
	lsl	r0, r7			@ logical shift left r0 by r7
	orr	r8, r0			@ or r8 and r0, store in r8

	mov	r0, #1			@ move number 1 into r0
	bl	write_clock		@ branch link to write_clock

	add	r7, #1			@ add r7 by 1
	cmp	r7, #16			@ compare r7 to 16
	blt	clock_loop		
	mov	r0, r8			@ move r8 value into r0
	pop	{r7,r8,pc}		


@ Checks which button is presssed
@ B - 1
@ Y - 2
@ select - 3
@ start - 4
@ up - 5
@ down - 6
@ left - 7
@ right - 8
@ A - 9
@ X - 10
@ lB - 11
@ rB - 12

check_button:
	push	{lr}
	mov	r1, #1

B:
	tst	r1, pButton
	bne	print_Y
	mov	r0, #1

	pop	{pc}			

Y:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_select
	mov	r0, #2

	pop	{pc}

select:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_start
	mov	r0, #3

	pop	{pc}			

start:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_up
	mov	r0, #4

	pop	{pc}			

up:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_down
	mov	r0, #5

	pop	{pc}			@ Return call

down:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_left
	mov	r0, #6

	pop	{pc}			@ Return call

left:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_right
	mov	r0, #7

	pop	{pc}			@ Return call

right:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_A
	mov	r0, #8

	pop	{pc}			@ Return call

A:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_X
	mov	r0, #9

	pop	{pc}			@ Return call

X:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_lB
	mov	r0, #10

	pop	{pc}			@ Return call

lB:
	lsl	r1, #1
	tst	r1, pButton
	bne	print_rB
	mov	r0, #11

	pop	{pc}			@ Return call

rB:
	lsl	r1, #1
	tst	r1, pButton
	bne	end_print
	mov	r0, #12

	pop	{pc}			@ Return call


@--------------------------------------------------------------------------------------


.section	.data

GPIO_baseAddr:	.word	0