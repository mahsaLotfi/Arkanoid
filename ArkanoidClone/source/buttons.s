
@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text
	gBase	.req	r9

@ functions 
.global	init_SNES
	init_SNES:
		push	{lr}
		bl	getGpioPtr		@ load base address
		ldr	r1, =gpioBaseAddress	@ load to variable
		str	r0, [r1]		@ store
		ldr	r0, =gpioBaseAddress
		ldr	gBase, [r0]		@ load address to register

		mov	r0, #9			@ GPIO9
		mov	r1, #0b001		@ as output
		bl	Init_GPIO		@ set

		mov	r0, #10			@ GPIO10
		mov	r1, #0b000		@ as input
		bl	Init_GPIO		@ set

		mov	r0, #11			@ GPIO11
		mov	r1, #0b001		@ as output
		bl	Init_GPIO		@ set

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

		mov	btns, #0		@ reset pushed buttons to 0

		mov	r0, #1
		bl	Write_Clock

		mov	r0, #1			@ set latch
		bl	Write_Latch

		@ wait 12microSeconds to signal controller
		mov	r0, #12
		bl	delayMicroseconds

		mov	r0, #0			@ clear latch
		bl	Write_Latch

		inc	.req	r7
		mov	inc, #0			@ increment

		pulseLoop:
			mov	r0, r6
			bl	delayMicroseconds

			mov	r0, #0		@ rise edge
			bl	Write_Clock

			mov	r0, r6
			bl	delayMicroseconds

			bl	Read_Data

			cmp	r0, #0		@ is data returned 0?
			lsl	btns, #1	@ make space for new bit
			addeq	btns, #0b1	@ if so, add 1 (pressed) to btns

			mov	r0, #1		@ fall edge
			bl	Write_Clock

			add	inc, #1		@ increment
			cmp	inc, #16	@ end when greater than/equal to 16
			blt	pulseLoop

		mov	r0, btns		@ return buttons
		pop	{r6-r8, pc}

	.unreq	inc
	.unreq	btns

	Init_GPIO:

		@ r0: GPIO number
		@ r1: function code

		push	{r4, r5, lr}		@ store vars in stack

		toAdd	.req	r3		@ name r3 immediate scratch value
		fSel	.req	r4		@ name r4 function select

		mov	r2, #0

		initLoop:
			cmp	r0, #9		@ r0 is GPIO number
			SUBHI	r0, #10		@ loop divides r0 to get GPIOSELn
			ADDHI	r2, #1
			BHI	initLoop
		lsl	toAdd, r2, #2		@ toAdd is the increment from gBase


		ldr	fSel, [gBase, toAdd]	@ load GPIO to r1

		add	r0, r0, lsl #1		@ r0 is multiplied to become the pin number
		lsl	r1, r0			@ function code is left shifted to pin number

		mov	r5, #0b111		@ set bitmask
		lsl	r5, r0

		bic	fSel, r5		@ bit clear at desired pins
		orr	fSel, r1		@ apply function code
		str	fSel, [gBase, toAdd]	@ store back to gBase

		pop	{r4, r5, pc}
		.unreq	fSel			@ unset register names
		.unreq	toAdd



	@GPIO9  - LAT (latch): OUTPUT
	@GPIO10 - DAT (data): INPUT
	@GPIO11 - CLK (clock): OUTPUT

	Write_Latch:
		teq	r0, #0			@ Clear Register if true
		mov	r0, #0x200		@ latch address
		streq	r0, [gBase, #0x28]	@ clear latch	@ 0x200 = 1 lsl 0x9
		strne	r0, [gBase, #0x1C]	@ or set latch
		mov	pc, lr

	Write_Clock:
		teq	r0, #0			@ Clear Register if true
		mov	r0, #0x800		@ clock address
		streq	r0, [gBase, #0x28]
		strne	r0, [gBase, #0x1C]	@ set/clear clock	0x800 = 1 lsl 0x11
		mov	pc, lr

	Read_Data:
		ldr	r0, [gBase, #0x34]	@ get GPLEV0
		tst	r0, #0x400		@ and with GPIO10 (data) bitmask

		movne	r0, #1
		moveq	r0, #0			@ equal means bit is 0
		mov	pc, lr

	.unreq	gBase
