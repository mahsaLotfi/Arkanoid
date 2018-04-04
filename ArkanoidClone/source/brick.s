@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section .text

.global generate_bricks, init_bricks, hit_brick, brick_pos, update_bricks, check_game_won


@ Updates and draws brick
@ r0 - X
@ r1 - Y
@ r2 - Color

generate_bricks:
	push	{r4-r6, lr}
	
	mov	r4, r0			@ r4 - x
	mov	r5, r1			@ r5 - y
	mov	r6, r2			@ r6 - color
	bl	check_brick
	strb	r6, [r0]		@ Stores the brick's type

	@ Draws the brick
	mov	r0, r4			@ r0 - x
	mov	r1, r5			@ r1 - y
	mov	r2, r6			@ r2 - Brick's type
	bl	draw_brick

	pop	{r4-r6, lr}
	
	mov	pc, lr


@ Initializes the brick
init_bricks:
	push	{r4-r6, lr}

	mov	r4, #0			@ x direction
	mov	r5, #0			@ y direction
	add	r6, r5, #3

init_all_bricks:
	mov	r0, r4			@ r0 - x
	mov	r1, r5			@ r1 - y

	bl	check_brick
	strb	r6, [r0]		@ Stores the brick's type

	@ Checks if there was an error for getting the brick's type
	cmp	r0, #0
	movne	r2, r6
	movne	r0, r4
	movne	r1, r5
	blne	draw_brick

	@ Checks X
	add	r4, r4, #1
	cmp	r4, #10
	blt	init_all_bricks

	@ Check Y
	add	r5, r5, #1
	sub	r6, r6, #1
	cmp	r5, #3
	movlt	r4, #0
	blt	init_all_bricks

	pop	{r4-r6, pc}


@ Draws the brick
@ r0 - Brick's x position
@ r1 - Brick's y position
@ r2 - Brick type

draw_brick:
	xPos		.req	r5
	yPos		.req	r6
	brickColor	.req	r7

	push	{r3-r8, lr}
	
	bl	get_coord

	mov	xPos, r0		@ r0 - X
	mov	yPos, r1		@ r1 - Y
	mov	brickColor, r2		@ r2 - Brick's type

	mov	r3, #64
	mov	r4, #32

	mov	r2, #0x0		@ Make the outside brick

	add	xPos, xPos, #4
	add	yPos, yPos, #4

	mov	r3, #56
	mov	r4, #24

	cmp	brickColor, #0
	moveq	r2, #0

	cmp	brickColor, #1
	moveq	r2, #0x99FF		@ Color for weak bricks

	cmp	brickColor, #2
	moveq	r2, #0x66FF		@ Color for medium bricks

	cmp	brickColor, #3
	moveq	r2, #0x6699		@ Color for strong bricks


	mov	r0, xPos
	mov	r1, yPos

	bl	drawCell
	pop	{r3-r8, pc}


@ Arguments:
@ r0 - X 
@ r1 - Y
@ Return:
@ r0 - Brick state 
hit_brick:
	push	{r4-r7, lr}

	@ store brick state on register
	bl	brick_pos
	mov	r4, r0
	mov	r5, r1
	bl	check_brick
        ldrb	r7, [r0]

	cmp	r7, #0

	moveq	r0, #0		@ Didn't hit brick
	popeq	{r4-r7, lr}
	moveq	pc, lr

	sub	r2, r7, #1	@ Degrade the brick
	mov	r0, r4
	mov	r1, r5
	bl	generate_bricks
	@ r2 is the color

	mov	r0, #1		@ Brick is hit

	pop	{r4-r7, lr}
	mov	pc, lr


@ r0 r1 - xy code
@ returns r0 r1 - xy
get_coord:
	lsl	r0, r0, #6
	add	r0, r0, #36

	lsl	r1, r1, #5
	add	r1, r1, #96
	mov	pc, lr


@ Arguments:
@ r0 - X
@ r1 - Y
@ Returns:
@ r0 - X
@ r1 - Y
brick_pos:
	push	{r4,r5,lr}

	mov	r4, r0
	mov	r5, r1

	cmp	r5, #96
	movlt	r0, #44			@ Return a not real position
	movlt	r1, #44
        poplt 	{r4-r5, lr}
	
	movlt	PC, LR

	cmp	r5, #192
	movgt	r0, #44			@ Return a not real position
	movgt	r1, #44
        popgt 	{r4-r5, lr}
	
	movgt	PC, LR

	mov	r5, #0 			@ Default layer
	sub	r1, r1, #96

yloop:
	cmp	r1, #32
	sub	r1, r1, #32
	movlt	r1, r5
	add	r5, r5, #1
	bge	yloop

	mov	r4, #0			@ Default start
	sub	r0, r0, #36

xloop:
	cmp	r0, #64
	sub	r0, r0, #64
	movlt	r0, r4
	add	r4,r4, #1
	bge	xloop

	pop	{r4,r5, lr}

	mov	pc, lr


@ Arguments:
@ r0 - x
@ r1 - y
@ Return:
@ r0 - Brick's type address
check_brick:
	push	{lr}

	cmp	r0, #9
	ldrgt	r0, =destroyedBrick 
	popgt	{lr}
	movgt	pc, lr

	cmp	r1, #1
	blt	top_bricks
	beq	middle_bricks

	cmpgt	r1, #2
	beq	bottom_bricks
	ldr	r0, =destroyedBrick

	pop	{lr}
	mov	pc, lr

top_bricks:
	cmp	r0, #0
	ldreq	r0, =brickt1
	beq	brick_end

	cmp	r0, #1
	ldreq	r0, =brickt2
	beq	brick_end

	cmp	r0, #2
	ldreq	r0, =brickt3
	beq	brick_end

	cmp	r0, #3
	ldreq	r0, =brickt4
	beq	brick_end

	cmp	r0, #4
	ldreq	r0, =brickt5
	beq	brick_end

	cmp	r0, #5
	ldreq	r0, =brickt6
	beq	brick_end

	cmp	r0, #6
	ldreq	r0, =brickt7
	beq	brick_end

	cmp	r0, #7
	ldreq	r0, =brickt8
	beq	brick_end

	cmp	r0, #8
	ldreq	r0, =brickt9
	beq	brick_end

	cmp	r0, #9
	ldr	r0, =brickt10
	beq	brick_end

middle_bricks:
	cmp	r0, #0
	ldreq	r0, =brickM1
	beq	brick_end

	cmp	r0, #1
	ldreq	r0, =brickM2
	beq	brick_end

	cmp	r0, #2
	ldreq	r0, =brickM3
	beq	brick_end

	cmp	r0, #3
	ldreq	r0, =brickM4
	beq	brick_end

	cmp	r0, #4
	ldreq	r0, =brickM5
	beq	brick_end

	cmp	r0, #5
	ldreq	r0, =brickM6
	beq	brick_end

	cmp	r0, #6
	ldreq	r0, =brickM7
	beq	brick_end

	cmp	r0, #7
	ldreq	r0, =brickM8
	beq	brick_end

	cmp	r0, #8
	ldreq	r0, =brickM9
	beq	brick_end

	cmp	r0, #9
	ldr	r0, =brickM10
	beq	brick_end

bottom_bricks:
	cmp	r0, #0
	ldreq	r0, =brickB1
	beq	brick_end

	cmp	r0, #1
	ldreq	r0, =brickB2
	beq	brick_end

	cmp	r0, #2
	ldreq	r0, =brickB3
	beq	brick_end

	cmp	r0, #3
	ldreq	r0, =brickB4
	beq	brick_end

	cmp	r0, #4
	ldreq	r0, =brickB5
	beq	brick_end

	cmp	r0, #5
	ldreq	r0, =brickB6
	beq	brick_end

	cmp	r0, #6
	ldreq	r0, =brickB7
	beq	brick_end

	cmp	r0, #7
	ldreq	r0, =brickB8
	beq	brick_end

	cmp	r0, #8
	ldreq	r0, =brickB9
	beq	brick_end

	cmp	r0, #9
	ldr	r0, =brickB10

brick_end:
	pop	{lr}
	mov	pc, lr


@ Re-draws all the bricks 
update_bricks:
	push	{r4-r6, lr}
	
	mov	r4, #0
	mov	r5, #0

get_bricks_state:
	mov	r0, r4
	mov	r1, r5

	bl	check_brick
	ldrb	r6, [r0]

	mov	r2, r6
	mov	r0, r4
	mov	r1, r5
	cmp	r2, #0
	blne	draw_brick

	@ Check X
	add	r4, r4, #1
	cmp	r4, #10
	blt	get_bricks_state

	@ Check Y
	add	r5, r5, #1
	cmp	r5, #3
	movlt	r4, #0
	blt	get_bricks_state

	pop	{r4-r6, lr}
	mov	pc, lr


@ Returns:
@ r0: Is Game Won
check_game_won:
	push	{r4, r5, lr}
	
	mov	r4, #0
        ldr	r5, =brickt1

checkBricks:
	ldrb	r0, [r5, r4]
	add	r4, r4, #1
        cmp	r0, #0
        movne	r0, #0
        popne	{r4,r5,lr}
	movne	PC, lr

	cmp	r4, #30
	blt	checkBricks

	mov	r0, #1
	
	pop	{r4, r5, lr}

	mov	pc, lr



@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

@ 0 - No brick
@ 1 - 1 hit brick
@ 2 - 2 hits brick
@ 3 - 3 hits brick

.global brickM3, brickB9


destroyedBrick:	.byte	0
    
brickt1:	.byte 	1
brickt2:	.byte	1
brickt3:	.byte	1
brickt4:	.byte	1
brickt5:	.byte	1
brickt6:	.byte	1
brickt7:	.byte	1
brickt8:	.byte	1
brickt9:	.byte	1
brickt10:	.byte	1

brickM1:	.byte 	2
brickM2:	.byte	2
brickM3:	.byte	2
brickM4:	.byte	2
brickM5:	.byte	2
brickM6:	.byte	2
brickM7:	.byte	2
brickM8:	.byte	2
brickM9:	.byte	2
brickM10:	.byte	2

brickB1:	.byte 	3
brickB2:	.byte	3
brickB3:	.byte	3
brickB4:	.byte	3
brickB5:	.byte	3
brickB6:	.byte	3
brickB7:	.byte	3
brickB8:	.byte	3
brickB9:	.byte	3
brickB10:	.byte	3
