 
.text
.global Init_Frame
Init_Frame:
		push	{lr}

		ldr	r0, =frameBufferInfo
		bl	initFbInfo

		pop	{pc}

@ r0 - xStart
@ r1 - yStart
@ r2 - color
@ r3 - length
@ r4 - height
.global drawCell
drawCell:
	length	.req 	r3
	cellDrawn	.req	r6
	offset	.req	r4
	frame	.req	r5
	width	.req	r6
	xval	.req	r7
	yval	.req	r8
	color	.req	r9

	push	{r5-r6, lr}
	@ length r3
	height	.req	r4

	ldr	r5, =frameBufferInfo
	ldr	r5, [r5, #4]

	mov	cellDrawn, #0
	cellLoop:
		bl	drawHL
		add	r0, r0, r5
		sub	r0, r0, length
		sub	r0, r0, #1
		add	cellDrawn, cellDrawn, #1
		cmp	cellDrawn, height
		ble	cellLoop

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

	@ calculate offset
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
.global drawHL
drawHL:
	push	{r6, lr}

	mov	cellDrawn, #0
	hlLoop:
		bl	drawPx
		add	r0, r0, #1
		add	cellDrawn, cellDrawn, #1
		cmp	cellDrawn, length
		ble	hlLoop

	pop	{r6, lr}
	mov	pc, lr


	.unreq	length
	.unreq	height
	.unreq	cellDrawn

@ Draw the character in r0
@ r1=x
@ r2=y
@ r3=colour
.global printChar
printChar:
	push		{r4-r9, lr}

	charAddress		.req	r4
	px		.req	r5
	py		.req	r6
	row		.req	r7
	mask		.req	r8
        colour		.req	r9

	ldr		charAddress, =font		@ load the address of the font map
	add		charAddress,	r0, lsl #4	@ char address = font base + (char * 16)

	mov		py, r2			@ initialize y 

	ldr		r2 , =initX
	str		r1, [r2]

	charLoop:
		ldr		px, =initX
		ldr		px, [px]		@ initialize X 
		mov		mask, #0x01		@ set the bitmask to 1 in the LSB
		LDRB		row, [charAddress], #1	@ load the row byte, post increment charAddress

	rowLoop:
		tst		row, mask		@ test row byte against the bitmask
		Beq		noPx

		mov		r0, px
		mov		r1, py
		mov		r2, colour
		bl		drawPx			@ draw pixel 

	noPx:
		add		px, px, #1		@ increment x  by 1
		lsl		mask, #1		@ shift bitmask left by 1

		tst		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
		Beq		rowLoop

		add		py,py, #1		@ increment y  by 1

		tst		charAddress, #0xF
		Bne		charLoop		@ loop back to charLoop, unless address evenly divisibly by 16 

	.unreq	charAddress
	.unreq	px
	.unreq	py
	.unreq	row
	.unreq	mask

	pop		{r4-r9, pc}


@ r0 - char array address
@ r1 - initial x
@ r2 - y
@ r3 - color
.global printWord
printWord:
	push	{r4-r7, lr}
	mov	r5, r0
	mov	r6, r1
	mov	r7, r2
	mov	r4, r3
	wordLoop:
		LDRB	r0, [r5], #1
		cmp	r0, #0
		popeq	{r4-r7, pc}

		mov	r1, r6
		mov	r2, r7
		mov	r3, r4
		bl	printChar
		add	r6, r6, #11
		B	wordLoop

.global blackScn @black screen 
blackScn:
	push {r4, r5, lr}
	mov r4, #0
	mov r5, #0

drawBlackScn:
	mov	r0, r4
	mov	r1, r5
	mov	r2, #0
	bl	drawPx

	add	r4, r4, #1
    	cmp 	r4, #720
    		moveq	r4, #0
   	 	addeq r5, r5, #1

    cmp   r5, #960
    blt drawBlackScn
    pop {r4,r5, pc}

 
.section .data

.align 4
font:		.incbin	"font.bin"

initX:		.int 0

.global frameBufferInfo
frameBufferInfo:
	.int	0	@ frame buffer pointer
	.int	0	@ width
	.int	0	@ height
