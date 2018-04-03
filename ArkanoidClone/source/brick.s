@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section .text

@ Updates and draws brick
@ r0 - X
@ r1 - Y
@ r2 - Color
.global generateBricks
generateBricks:
	push	{r4-r6, lr}
	
	mov	r4, r0			@ r4 - x
	mov	r5, r1			@ r5 - y
	mov	r6, r2			@ r6 - color
	bl	codeToTile
	strb	r6, [r0]		@ Stores the brick's type

	@ Draws the brick
	mov	r0, r4			@ r0 - x
	mov	r1, r5			@ r1 - y
	mov	r2, r6			@ r2 - Brick's type
	bl	drawBrick

	pop	{r4-r6, lr}
	
	mov	pc, lr


@ Initializes the brick
.global	initBricks
initBricks:
	push	{r4-r6, lr}

	mov	r4, #0			@ x direction
	mov	r5, #0			@ y direction
	add	r6, r5, #3

initBricks:
	push	{r4-r6, lr}

	mov	r4, #0			@ x direction
	mov	r5, #0			@ y direction
	add	r6, r5, #3

	initBrickLoop:
		mov	r0, r4			@ r0 - x
		mov	r1, r5			@ r1 - y

		bl	codeToTile
		strb	r6, [r0]		@ Stores the brick's type

		@ Checks if there was an error for getting the brick's type
		cmp	r0, #0
		movne	r2, r6
		movne	r0, r4
		movne	r1, r5
		blne	drawBrick

		@ Checks X
		add	r4, r4, #1
		cmp	r4, #10
		blt	initBrickLoop

		@ Check Y
		add	r5, r5, #1
		sub	r6, r6, #1
		cmp	r5, #3
		movlt	r4, #0
		blt	initBrickLoop

	pop	{r4-r6, pc}


@ Draws the brick
@ r0 - Brick's x position
@ r1 - Brick's y position
@ r2 - Brick type
drawBrick:
	xPos		.req	r5
	yPos		.req	r6
	brickColor	.req	r7

	push	{r3-r8, lr}
	
	bl	CodeToXY

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
.global	hitBrick
hitBrick:
	push	{r4-r7, lr}

	@ store brick state on register
	bl	XYtoCode
	mov	r4, r0
	mov	r5, r1
	bl	codeToTile
        LDRB	r7, [r0]

	cmp	r7, #0

	moveq	r0, #0		@ Didn't hit brick
	popeq	{r4-r7, lr}
	moveq	pc, lr

	sub	r2, r7, #1	@ Degrade the brick
	mov	r0, r4
	mov	r1, r5
	bl	generateBricks
	@ r2 is the color

	mov	r0, #1		@ Brick is hit

	pop	{r4-r7, lr}
	mov	pc, lr

@ r0 r1 - xy code
@ returns r0 r1 - xy
CodeToXY:
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
.global XYtoCode
XYtoCode:
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
codeToTile:
	push	{lr}

	cmp	r0, #9
	ldrgt	r0, =destroyedBrick 
	popgt	{lr}
	movgt	pc, lr

	cmp	r1, #1
	blt	fromZero
	Beq	fromTen

	cmpgt	r1, #2
	Beq	fromTwenty
	ldr	r0, =destroyedBrick

	pop	{lr}
	mov	pc, lr

	fromZero:
		cmp	r0, #0
		ldreq	r0, =brick0
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #1
		ldreq	r0, =brick1
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #2
		ldreq	r0, =brick2
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #3
		ldreq	r0, =brick3
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #4
		ldreq	r0, =brick4
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #5
		ldreq	r0, =brick5
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #6
		ldreq	r0, =brick6
		popeq	{pc}

		cmp	r0, #7
		ldreq	r0, =brick7
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #8
		ldreq	r0, =brick8
		popeq	{lr}
		moveq	pc, lr

		ldr	r0, =brick9
		pop	{lr}
		mov	pc, lr

	fromTen:
		cmp	r0, #0
		ldreq	r0, =brick10
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #1
		ldreq	r0, =brick11
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #2
		ldreq	r0, =brick12
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #3
		ldreq	r0, =brick13
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #4
		ldreq	r0, =brick14
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #5
		ldreq	r0, =brick15
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #6
		ldreq	r0, =brick16
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #7
		ldreq	r0, =brick17
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #8
		ldreq	r0, =brick18
		popeq	{lr}
		moveq	pc, lr

		ldr	r0, =brick19
		pop	{lr}
		mov	pc, lr

	fromTwenty:
		cmp	r0, #0
		ldreq	r0, =brick20
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #1
		ldreq	r0, =brick21
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #2
		ldreq	r0, =brick22
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #3
		ldreq	r0, =brick23
		popeq	{lr}
		moveq	pc, lr


		cmp	r0, #4
		ldreq	r0, =brick24
		popeq	{lr}
		moveq	pc, lr


		cmp	r0, #5
		ldreq	r0, =brick25
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #6
		ldreq	r0, =brick26
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #7
		ldreq	r0, =brick27
		popeq	{lr}
		moveq	pc, lr

		cmp	r0, #8
		ldreq	r0, =brick28
		popeq	{lr}
		moveq	pc, lr

		ldr	r0, =brick29
		pop	{lr}
		mov	pc, lr

@ Re-draws all the bricks 
.global	updateBricks
updateBricks:
	push	{r4-r6, lr}
	
	mov	r4, #0
	mov	r5, #0

getBrickStateLoop:
	mov	r0, r4
	mov	r1, r5

	bl	codeToTile
	ldrb	r6, [r0]

	mov	r2, r6
	mov	r0, r4
	mov	r1, r5
	cmp	r2, #0
	blne	drawBrick

	@ Check X
	add	r4, r4, #1
	cmp	r4, #10
	blt	getBrickStateLoop

	@ Check Y
	add	r5, r5, #1
	cmp	r5, #3
	movlt	r4, #0
	blt	getBrickStateLoop

	pop	{r4-r6, lr}
	mov	pc, lr

@ Returns:
@ r0: Is Game Won
.global isGameWon
isGameWon:
	push	{r4, r5, lr}
	
	mov	r4, #0
        ldr	r5, =brick0

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

@ 0 - Destroyed Brick
@ 1 - Weak Brick
@ 2 - Medium Brick
@ 3 - Strong Brick

    .global brick20

	doBrick:	.byte	1
	destroyedBrick:	.byte	0
    
	brick0:	.byte 	1
	brick1:	.byte	1
	brick2:	.byte	1
	brick3:	.byte	1
	brick4:	.byte	1
	brick5:	.byte	1
	brick6:	.byte	1
	brick7:	.byte	1
	brick8:	.byte	1
	brick9:	.byte	1

	brick10:	.byte 	2
	brick11:	.byte	2
	brick12:	.byte	2
	brick13:	.byte	2
	brick14:	.byte	2
	brick15:	.byte	2
	brick16:	.byte	2
	brick17:	.byte	2
	brick18:	.byte	2
	brick19:	.byte	2

    brick20:	.byte 	3
	brick21:	.byte	3
	brick22:	.byte	3
	brick23:	.byte	3
	brick23:	.byte	3
	brick24:	.byte	3
	brick25:	.byte	3
	brick26:	.byte	3
	brick27:	.byte	3
	brick28:	.byte	3
	brick29:	.byte	3




