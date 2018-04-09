@ Assignment 3: SNES Controller
@ Created by: Kevin Huynh 10162332, Heavenel Cerna 30019914 and Austin So 30021027

    gpio_bA		.req	r11		@ GPIO base address
    pButton		.req	r10		@ Pressed button
    sampButton		.req	r9		@ Sample button

@@@@@ ---------- Code Section ---------- @@@@@
    .section	.text
    .global main
    
main:
	ldr	r0, =authors		@ Prints the authors names
	bl	printf

	bl	getGpioPtr		@ Called to get	base address of GPIO in r0
	ldr	r1, =GPIO_baseAddr	@ Loads GPIO_baseAddr address into r1
	str	r0, [r1]		@ Stores GPIO base address into GPIO_baseAddr address
	ldr	r0, =GPIO_baseAddr	@ ldr	r0, =0x3F200000
	ldr	gpio_bA, [r0]		@ Saves GPIO base address to r11

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
	ldr	r0, =prompt		@ Prints prompt
	bl	printf

wait:
	bl 	read_SNES		@ Branch link to read_SNES function
	mov	pButton, r0		@ Move r0 value into r10

	mov 	r0,#1000		@ Wait 0.0001 second
	bl	delayMicroseconds
	
	bl 	read_SNES		@ Branch link to read_SNES function

	cmp	pButton, r0		@ Compare r10 with r0
	beq 	wait			@ If button is not pressed

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
	mov r3, #10			@ Get function Select Register number
	sdiv r0, r0, r3
	mov r6, r0			@ Keep parameters to safe variables
	mov r4, r1

	@ Get least significant digit of line number
	@ and control bit for that digit
	mov r3, #10
	mul r1, r0, r3
	sub r1, r6, r1
	mov r3, #3
	mul r5, r1, r3
 
	ldr	r0, [gpio_bA, r6, lsl #2] @ Load the value of Function Select Register

	mov	r1, #7			@ Clear bits
	bic	r0, r1, lsl r5
	
	orr	r0, r4, lsl r5		@ Set bits to function code

	str	r0, [gpio_bA, r6, lsl #2] @ Write back to Function Select Register 1

	mov	pc, lr			@ Returns call

write_latch:
	push	{r4}			

	mov	r1, #9			@ move number 9 into r1
	ldr	r4, =GPIO_baseAddr	@ load register r5 with the GPIO base address
	ldr	r2, [r4]		@ load register r3 with the value store in r5's address
	mov	r3, #1			@ move number 1 into r2
	lsl	r3, r1			@ logical shit left on r3 by the number on bits in r1

	teq	r0, #0			@ test equivalent to see id r0 is the number 0

	streq	r3, [r2, #40]		@ store r3 value into r2 + 40
	strne	r3, [r2, #28]		@ store r3 value into r2 +28

	pop	{r4}			

	mov	pc, lr			@ Return call


write_clock:
	push	{r4}			

	mov	r1, #11			@ mov #11 into r1
	ldr	r4, =GPIO_baseAddr	@ load register r5 with GPIO base address
	ldr	r2, [r4]		@ load register r3 with the value store in r5's address
	mov	r3, #1			@ move number 1 into r2
	lsl	r3, r1			@ logical shift left on r2 by the number of bit store in r1

	teq	r0, #0			@ test equivalent to see if the numbers are the same r0 is 0

	streq	r3, [r2, #40]		@ store if r0 equal 0, store r2 value into r3 +40 
	strne	r3, [r2, #28]		@ store if r0 not equal 0, store r2 value into r3 +28

	pop	{r4}			

	mov	pc, lr			@ Return call


read_data:
	push	{r4,r7}			

	mov	r0, #10			@ move number 10 into r0
	ldr	r4, =GPIO_baseAddr	@ load r5 with the GPIO base address address
	ldr	r7, [r4]		@ load register r6 with the value store in r5's address
	ldr	r1, [r7, #52]		@ load register r1 with the value store in the address r6 +52
	mov	r3, #1			@ move number 1 into r2
	lsl	r3, r0			@ logical shift left on r2 with the number of bit in r0

	and	r1, r3			@ and operation between r1 and r3
	teq	r1, #0			@ test equivalent r1 with number 0

	moveq	r0, #0			@ move number 0 into r0 if r2 = 0
	movne	r0, #1			@ move number 1 into r0 if r2 != 0

	pop	{r4,r7}			

	mov	pc, lr			@ Return call


read_SNES:
	push	{r8,sampButton,lr}	

	mov	r0, #1			@ move number 1 into r0
	bl	write_clock		@ branch link to write clock function

	mov	r0, #1			@ move number 1 into r0
	bl	write_latch		@ branch link to write_latch function

	mov	r0, #12			@ move number 12 into r0
	bl	delayMicroseconds	@ branch link to delayMicroseconds functions

	mov	r0, #0			@ move number 0 into r0
	bl	write_latch		@ branch link to write_latch function

	mov	sampButton, #0		@ Sampling button
	mov	r8, #0			@ Loop counter


pulse_loop:
	mov	r0, #6			@ move number 6 into r0
	bl	delayMicroseconds	@ branch link delayMicroseconds function

	mov	r0, #0			@ move number 0 into r0
	bl	write_clock		@ branch link write_clock function

	mov	r0, #6			@ move number 6 into r0
	bl	delayMicroseconds	@ branch link to delayMicroseconds function

	bl	read_data		@ branch link read_data function 
	lsl	r0, sampButton		@ logical shift left in r0 by the number of bits in sampleButton
	orr	r8, r0			@ r8 = r8 + r0

	mov	r0, #1			@ move number 1 into r0
	bl	write_clock		@ branch link write_clock function 

	add	sampButton, #1		@ sampleButton = sampleButton + 1
	cmp	sampButton, #16		@ compare sampleButton with number 16
	blt	pulse_loop		@ branch less than clock_loop function 
	mov	r0, r8			@ move r8 value into r0

	pop	{r8,sampButton,pc}	 


@ Checks which button is presssed
check_button:
	push	{lr}			
	mov	r1, #1			@ Button pressed checker

print_B:
	tst	r1, pButton		@ Checks if B is pressed
	bne	print_Y
	ldr	r0, =b_button		@ Prints X string
	bl	printf

	pop	{pc}			

print_Y:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if Y is pressed
	bne	print_select
	ldr	r0, =y_button		@ Prints Y string
	bl	printf

	pop	{pc}

print_select:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if select is pressed
	bne	print_start
	ldr	r0, =select		@ Prints A string
	bl	printf

	pop	{pc}			

print_start:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if start is pressed
	bne	print_up
	ldr	r0, =start		@ Prints B string
	bl	printf

	b	haltLoop$			

print_up:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if up is pressed
	bne	print_down
	ldr	r0, =joy_up		@ Prints select string
	bl	printf

	pop	{pc}			@ Return call

print_down:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if down is pressed
	bne	print_left
	ldr	r0, =joy_down		@ Prints start string
	bl	printf

	pop	{pc}			@ Return call

print_left:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if left is pressed
	bne	print_right
	ldr	r0, =joy_left		@ Prints up string
	bl	printf

	pop	{pc}			@ Return call

print_right:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if right is pressed
	bne	print_A
	ldr	r0, =joy_right		@ Prints down string
	bl	printf

	pop	{pc}			@ Return call

print_A:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if A is pressed
	bne	print_X
	ldr	r0, =a_button		@ Prints left string
	bl	printf

	pop	{pc}			@ Return call

print_X:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if X is pressed
	bne	print_lB
	ldr	r0, =x_button		@ Prints right string
	bl	printf

	pop	{pc}			@ Return call

print_lB:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if left trigger is pressed
	bne	print_rB
	ldr	r0, =left_trigger	@ Prints left trigger
	bl	printf

	pop	{pc}			@ Return call

print_rB:
	lsl	r1, #1
	tst	r1, pButton		@ Checks if right trigger is pressed
	bne	print_end
	ldr	r0, =right_trigger	@ Prints right trigger
	bl	printf

print_end:
	pop	{pc}			@ Return call


@@@@@ ---------- Data Section ---------- @@@@@
    .section    .data
    GPIO_baseAddr:	.word	0

authors:
	.asciz	"\nCreated by: Kevin Huynh, Heavenel Cerna and Austin So\n"
prompt:
	.asciz	"\nPlease press a button...\n"
x_button:
	.asciz	"\nYou have pressed X\n"
y_button:
	.asciz	"\nYou have pressed Y\n"
a_button:
	.asciz	"\nYou have pressed A\n"
b_button:
	.asciz	"\nYou have pressed B\n"
select:
	.asciz	"\nYou have pressed Select\n"
start:
	.asciz	"\nProgram is terminating...\n"
joy_up:
	.asciz	"\nYou have pressed Joy-pad UP\n"
joy_down:
	.asciz	"\nYou have pressed Joy-pad DOWN\n"
joy_left:
	.asciz	"\nYou have pressed Joy-pad LEFT\n"
joy_right:
	.asciz	"\nYou have pressed Joy-pad RIGHT\n"
left_trigger:
	.asciz	"\nYou have pressed LEFT trigger\n"
right_trigger:
	.asciz	"\nYou have pressed RIGHT trigger\n"
