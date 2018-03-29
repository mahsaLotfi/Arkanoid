
@ Code section
.section .text

.global main
main:
	@ ask for frame buffer information
	ldr 		r0, =frameBufferInfo 	@ frame buffer information structure
	bl		initFbInfo

	bl		DrawCharB		@ Draw the character 'B' to (200,200)	

	@ stop
	haltLoop$:
		b	haltLoop$


@ Draw Pixel
@  r0 - x
@  r1 - y
@  r2 - colour

DrawPixel:
	push		{r4, r5}

	offset		.req	r4

	ldr		r5, =frameBufferInfo	

	@ offset = (y * width) + x
	
	ldr		r3, [r5, #4]		@ r3 = width
	mul		r1, r3
	add		offset,	r0, r1
	
	@ offset *= 4 (32 bits per pixel/8 = 4 bytes per pixel)
	lsl		offset, #2

	@ store the colour (word) at frame buffer pointer + offset
	ldr		r0, [r5]		@ r0 = frame buffer pointer
	str		r2, [r0, offset]

	pop		{r4, r5}
	bx		lr


@ Draw the character 'B' to (0,0)
DrawCharB:
	push		{r4-r8, lr}

	chAdr		.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask		.req	r8

	ldr		chAdr, =font		@ load the address of the font map
	mov		r0, #'B'		@ load the character into r0
	add		chAdr,	r0, lsl #4	@ char address = font base + (char * 16)

	mov		py, #200		@ init the Y coordinate (pixel coordinate)

charLoop$:
	mov		px, #200		@ init the X coordinate

	mov		mask, #0x01		@ set the bitmask to 1 in the LSB
	
	ldrb		row, [chAdr], #1	@ load the row byte, post increment chAdr

rowLoop$:
	tst		row,	mask		@ test row byte against the bitmask
	beq		noPixel$

	mov		r0, px
	mov		r1, py
	mov		r2, #0x00FF0000		@ red
	bl		DrawPixel		@ draw red pixel at (px, py)

noPixel$:
	add		px, #1			@ increment x coordinate by 1
	lsl		mask, #1		@ shift bitmask left by 1

	tst		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
	beq		rowLoop$

	add		py, #1			@ increment y coordinate by 1

	tst		chAdr, #0xF
	bne		charLoop$		@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r8, pc}
@ Data section
.section .data

.align
.globl frameBufferInfo
frameBufferInfo:
	.int	0		@ frame buffer pointer
	.int	0		@ screen width
	.int	0		@ screen height

.align 4
font:		.incbin	"font.bin"
