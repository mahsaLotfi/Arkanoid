@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text
.global initFrame
initFrame:
	push	{lr}

	ldr	r0, =frameBufferInfo
	bl	initFbInfo

	pop	{pc}

@ r0 - xStart
@ r1 - yStart
@ r2 - color
@ r3 - length
@ r4 - xLength (height)
.global drawCell
drawCell:
	length	.req 	r3
	pxDrawn	.req	r6
	offset	.req	r4
	frame	.req	r5
	width	.req	r6
	xval	.req	r7
	yval	.req	r8
	color	.req	r9

	push	{r5-r6, lr}
	height	.req	r4

	ldr	r5, =frameBufferInfo
	ldr	r5, [r5, #4]

	mov	pxDrawn, #0
	tileLoop:
		bl	drawHLn
		add	r0, r0, r5
		sub	r0, r0, length
		sub	r0, r0, #1
		add	pxDrawn, pxDrawn, #1
		cmp	pxDrawn, height
		ble	tileLoop

	pop	{r5-r6, pc}

.global drawPx
@ r0 - xStart
@ r1 - yStart
@ r2 - color

drawPx:
	push	{r3-r9, lr}

	mov	xval, r0
	mov	yval, r1
	mov	color, r2

	ldr	frame, =frameBufferInfo
	ldr	width, [frame, #4]

	@ making the offset
	mul	yval, width
	add	offset, xval, yval
	lsl	offset, #2	@ * 4

	ldr	r3, [frame]
	str	color, [r3, offset]

	pop	{r3-r9, pc}


	.unreq	offset
	.unreq	frame
	.unreq	width

@ r0 - xStart
@ r1 - yStart
@ r2 - color
@ r3 - length
.global drawHLn
drawHLn:
	push	{r6, lr}

	mov	pxDrawn, #0
	hlPxLoop:
		bl	drawPx
		add	r0, r0, #1
		add	pxDrawn, pxDrawn, #1
		cmp	pxDrawn, length
		ble	hlPxLoop

	pop	{r6, lr}
	mov	pc, lr


	.unreq	length
	.unreq	height
	.unreq	pxDrawn

@ Draw the character in r0
@ r1=x
@ r2=y
@ r3=colour
.global drawChar
drawChar:
	push		{r4-r9, lr}

	chAdr		.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask		.req	r8
        colour		.req	r9

	ldr		chAdr, =font		@ load the address of the font map
	add		chAdr,	r0, lsl #4	@ char address = font base + (char * 16)

	mov		py, r2			@ init the Y coordinate (pixel coordinate)

	ldr		r2 , =initX
	str		r1, [r2]

	charLoop:
		ldr		px, =initX
		ldr		px, [px]		@ init the X coordinate
		mov		mask, #0x01		@ set the bitmask to 1 in the LSB
		LDRB		row, [chAdr], #1	@ load the row byte, post increment chAdr

	rowLoop:
		tst		row, mask		@ test row byte against the bitmask
		Beq		noPixel

		mov		r0, px
		mov		r1, py
		mov		r2, colour
		bl		drawPx			@ draw pixel at (px, py)

	noPixel:
		add		px, px, #1		@ increment x coordinate by 1
		lsl		mask, #1		@ shift bitmask left by 1

		tst		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
		Beq		rowLoop

		add		py,py, #1		@ increment y coordinate by 1

		tst		chAdr, #0xF
		Bne		charLoop		@ loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r9, pc}


@ r0 - char array address
@ r1 - initial x
@ r2 - y
@ r3 - color
.global drawWord
drawWord:
	push	{r4-r7, lr}
	mov	r5, r0
	mov	r6, r1
	mov	r7, r2
	mov	r4, r3
	drawWordLoop:
		LDRB	r0, [r5], #1
		cmp	r0, #0
		popeq	{r4-r7, pc}

		mov	r1, r6
		mov	r2, r7
		mov	r3, r4
		bl	drawChar
		add	r6, r6, #11
		B	drawWordLoop

.global blackScreen @blacks out game screen takes and returns no arguments
blackScreen:
	push {r4, r5, lr}
	mov r4, #0
	mov r5, #0

drawblackscreen:
	mov	r0, r4
	mov	r1, r5
	mov	r2, #0
	bl	drawPx

	add	r4, r4, #1
    	cmp 	r4, #720
    		moveq	r4, #0
   	 	addeq r5, r5, #1

    cmp   r5, #960
    blt drawblackscreen
    pop {r4,r5, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section .data

.align 4
font:		.incbin	"font.bin"
initX:		.int 0

.global frameBufferInfo
frameBufferInfo:
	.int	0	@ frame buffer pointer
	.int	0	@ width
	.int	0	@ height
