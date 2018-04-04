@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

.global draw_center_image, draw_cell

@ Center menu, game won, game over
@r0 - Image address
@r1 - Image width
@r2 - Image length
draw_center_image:
	address	.req	r5
	width	.req	r6
	length	.req	r7
	x	.req	r8
	y	.req	r9

	push	{r4-r9, lr}

        mov	address, r0
	mov	width,	r1
	mov	length,	r2
	
	mov	x, #360
	sub	x, x, width, lsr #1
	
	mov	y, #480
	sub	y, y, length, lsr #1

        add	r4, width, x
	
draw_center_loop:
	mov r0, x
	mov r1, y
	ldr r2, [address], #4
	bl  drawPx
    
	add x, x, #1
    
	cmp x, r4
	subeq x, x, width
	addeq y, y, #1
    
	mov r0, #480
	add r0, r0, length, lsr #1
	cmp y, r0
	blt draw_center_loop
    
	pop		{r4-r9, pc}

.unreq	address
.unreq	width
.unreq	length
.unreq	x
.unreq	y
    
@r0 - Image address
@r1 - Image width
@r2 - Image length
draw_cell:

	address	.req	r5
	width	.req	r6
	length	.req	r7

	push	{r5-r9, lr}

	x	.req	r8
	y	.req	r9

	mov	x, #0
	mov	y, #0
	
	mov	address, r0
	
	mov	width,	r1
	mov	length,	r2
	
tileLoop:
	mov r0, x
	mov r1, y
	ldr r3, [address], #4
	mov r2, r3
	bl  drawPx
    
	add x, x, #1
    
	cmp x, width
	moveq x, #0
	addeq y, y, #1
    
	cmp y, length
	blt tileLoop
    
	pop		{r5-r9, pc}

	.unreq	address
	.unreq	width
	.unreq	length
	.unreq	x
	.unreq	y
