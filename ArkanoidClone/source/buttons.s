
@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section	.text

GPIO_base	.req	r9


@ functions 
.global	init_SNES
init_SNES:
	push	{lr}

	bl	getGpioPtr		@ load base address
	ldr	r1, =gpioBaseAddress	@ load to variable
	str	r0, [r1]
	ldr	r0, =gpioBaseAddress
	ldr	GPIO_base, [r0]		@ load address to register

	mov	r0, #9			@ Latch
	mov	r1, #0b001		@ Set output
	bl	Init_GPIO

	mov	r0, #10			@ Latch
	mov	r1, #0b000		@ Set input
	bl	Init_GPIO

	mov	r0, #11			@Latch
	mov	r1, #0b001		@ Set output
	bl	Init_GPIO

	pop	{pc}


@ params:
@ r0 - delay
@ returns:
@ r0 - code for button pressed

.global read_SNES
read_SNES:
	push	{r6-r8, lr}
	btns	.req	r8
	mov	r6, r0

	mov	btns, #0

	mov	r0, #1
	bl	write_clock

	mov	r0, #1
	bl	write_latch

	@ wait 12microSeconds to signal controller
	mov	r0, #12
	bl	delayMicroseconds

	mov	r0, #0
	bl	write_latch

	inc	.req	r7
	mov	inc, #0

wait:
	mov	r0, r6
	bl	delayMicroseconds

	mov	r0, #0
	bl	write_clock

	mov	r0, r6
	bl	delayMicroseconds

	bl	read_data

	cmp	r0, #0
	lsl	btns, #1
	addeq	btns, #0b1

	mov	r0, #1
	bl	write_clock

	add	inc, #1
	cmp	inc, #16
	blt	wait

	mov	r0, btns
	pop	{r6-r8, pc}


Init_GPIO:

	@ r0: GPIO number
	@ r1: function code

	push	{r4, r5, lr}

	toAdd	.req	r3
	fSel	.req	r4

	mov	r2, #0

GPIO_loop:
	cmp	r0, #9
	SUBHI	r0, #10	
	ADDHI	r2, #1
	BHI	GPIO_loop
	lsl	toAdd, r2, #2

	ldr	fSel, [GPIO_base, toAdd]

	add	r0, r0, lsl #1
	lsl	r1, r0

	mov	r5, #0b111
	lsl	r5, r0

	bic	fSel, r5
	orr	fSel, r1
	str	fSel, [GPIO_base, toAdd]

	pop	{r4, r5, pc}

.unreq	fSel
.unreq	toAdd


write_latch:
	teq	r0, #0			@ Clear Register if true
	mov	r0, #0x200		@ latch address
	streq	r0, [GPIO_base, #0x28]	@ clear latch	@ 0x200 = 1 lsl 0x9
	strne	r0, [GPIO_base, #0x1C]	@ or set latch
	mov	pc, lr

write_clock:
	teq	r0, #0			@ Clear Register if true
	mov	r0, #0x800		@ clock address
	streq	r0, [GPIO_base, #0x28]
	strne	r0, [GPIO_base, #0x1C]	@ set/clear clock	0x800 = 1 lsl 0x11
	mov	pc, lr

read_data:
	ldr	r0, [GPIO_base, #0x34]	@ get GPLEV0
	tst	r0, #0x400		@ and with GPIO10 (data) bitmask
	movne	r0, #1
	moveq	r0, #0			@ equal means bit is 0
	mov	pc, lr

