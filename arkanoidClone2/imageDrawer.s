@r0= address of image data
@r1=image width
@r2=image length

.section	.text
.global drawCenterTile
drawCenterTile:
	push	{r4-r9, lr}
	
	address	.req	r5
	width	.req	r6
	length	.req	r7
	x	.req	r8
	y	.req	r9
	
	@store values
    mov	address, r0
	mov	width,	r1
	mov	length,	r2
	
	@initalize x and y start positions
	mov x, #360
	sub x, x, width, lsr #1
	
	mov y, #480
	sub y, y, length, lsr #1

    add r4, width, x
	
centertileloop:
    @draw a pixel
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
    blt centertileloop

  	.unreq	address
	.unreq	width
	.unreq	length
	.unreq	x
	.unreq	y
    
    pop		{r4-r9, pc}
    
@r0= address of image data
@r1=image width
@r2=image length
.global drawTile
drawTile:

	push	{r5-r9, lr}
	
	address	.req	r5
	width	.req	r6
	length	.req	r7
	x	.req	r8
	y	.req	r9

	@intialize offset, x and y to 0
	mov		x, #0
	mov		y, #0
	
	mov	address, r0
	
	mov	width,	r1
	mov	length,	r2
	
tileloop:
    @draw a pixel
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
    blt tileloop

  	.unreq	address
	.unreq	width
	.unreq	length
	.unreq	x
	.unreq	y
    
    pop		{r5-r9, pc}
