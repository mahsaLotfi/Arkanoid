@ Brick objects


.section .text

.global makeBrick, initBricks, hitBreak, XYtoCode, makeAllBricks

@ Updates and draws brick
@ r0 - x
@ r1 - y
@ r2 - color

makeBrick:
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

initBricks:
	push	{r4-r6, lr}

	mov	r4, #0			@ x direction
	mov	r5, #0			@ y direction
	add	r6, r5, #3

initBrickStateLoop:
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
	blt	initBrickStateLoop

	@ Check Y
	add	r5, r5, #1
	sub	r6, r6, #1
	cmp	r5, #3
	movlt	r4, #0
	blt	initBrickStateLoop

	pop	{r4-r6, pc}


@ Draws the brick
@ r0 - brick's x position
@ r1 - brick's y position
@ r2 - brick type (0-3)

drawBrick:
	xpos		.req	r5
	ypos		.req	r6
	colorCode	.req	r7

	push	{r3-r8, lr}
	
	bl	CodeToXY

	mov	xpos, r0		@ r0 - x
	mov	ypos, r1		@ r1 - y
	mov	colorCode, r2		@ r2 - Brick's type

	mov	r3, #64
	mov	r4, #32

	mov	r2, #0x0		@ Make the outside brick

	add	xpos, xpos, #4
	add	ypos, ypos, #4

	mov	r3, #56
	mov	r4, #24

	cmp	colorCode, #0
	moveq	r2, #0

	cmp	colorCode, #1
	moveq	r2, #0x99FF		@ 1 hit

	cmp	colorCode, #2
	moveq	r2, #0x66FF		@ 2 hits

	cmp	colorCode, #3
	moveq	r2, #0x6699		@ 3 hits


	mov	r0, xpos
	mov	r1, ypos

	bl	drawCell

	pop	{r3-r8, pc}


@ Arguments
@ r0 - x
@ r1 - y

@ returns 0 - didn't hit brick, 1 - hit brick

hitBrick:
	push	{r4-r7, lr}

	@ Store brick state on register
	bl	XYtoCode
	mov	r4, r0
	mov	r5, r1
	bl	codeToTile
        LDRB	r7, [r0]

	@ Checks to see if the brick has been hit
	cmp	r7, #0
	moveq	r0, #0			@ Did not hit brick
	popeq	{r4-r7, lr}
	moveq	pc, lr

	sub	r2, r7, #1		@ Brick becomes lower tier/disappears
	mov	r0, r4
	mov	r1, r5
	bl	makeBrick

	mov	r0, #1			@ Brick has been hit
	
	pop	{r4-r7, lr}
	
        mov	pc, lr


@ 
@ Arguments:
@ r0 - x
@ r1 - y

@ returns r0 - x, r1 - y

CodeToXY:
	lsl	r0, r0, #6
	add	r0, r0, #36

	lsl	r1, r1, #5
	add	r1, r1, #96
	
	mov	pc, lr


@ 
@ r0 r1 - xy position
@ returns r0 r1 - xy code

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


@ Get the Brick's type
@ Arguments
@ r0 - x
@ r1 - y

@ Return
@ r0 - Brick's type address

codeToTile:
	push	{lr}

	@ Error check for the first value
	cmp	r0, #9
	ldrgt	r0, =emptyTile
	
	popgt	{lr}
	
	movgt	pc, lr

	@ Checks for type of brick
	cmp	r1, #1
	blt	fromZero
	beq	fromTen

	cmpgt	r1, #2
	beq	fromTwenty
	
	@ Invalid input Error
	ldr	r0, =emptyTile		@ Returns 0

	pop	{lr}
	
	mov	pc, lr

fromTwenty:
	cmp	r0, #0
	ldreq	r0, =tile20
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #1
	ldreq	r0, =tile21
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #2
	ldreq	r0, =tile22
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #3
	ldreq	r0, =tile23
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #4
	ldreq	r0, =tile24
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #5
	ldreq	r0, =tile25
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #6
	ldreq	r0, =tile26
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #7
	ldreq	r0, =tile27
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #8
	ldreq	r0, =tile28
	popeq	{lr}
	moveq	pc, lr

	ldr	r0, =tile29
	pop	{lr}
	mov	pc, lr

fromZero:
	cmp	r0, #0
	ldreq	r0, =tile0
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #1
	ldreq	r0, =tile1
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #2
	ldreq	r0, =tile2
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #3
	ldreq	r0, =tile3
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #4
	ldreq	r0, =tile4
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #5
	ldreq	r0, =tile5
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #6
	ldreq	r0, =tile6
	popeq	{pc}

	cmp	r0, #7
	ldreq	r0, =tile7
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #8
	ldreq	r0, =tile8
	popeq	{lr}
	moveq	pc, lr

	ldr	r0, =tile9
	pop	{lr}
	mov	pc, lr

fromTen:
	cmp	r0, #0
	ldreq	r0, =tile10
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #1
	ldreq	r0, =tile11
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #2
	ldreq	r0, =tile12
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #3
	ldreq	r0, =tile13
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #4
	ldreq	r0, =tile14
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #5
	ldreq	r0, =tile15
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #6
	ldreq	r0, =tile16
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #7
	ldreq	r0, =tile17
	popeq	{lr}
	moveq	pc, lr

	cmp	r0, #8
	ldreq	r0, =tile18
	popeq	{lr}
	moveq	pc, lr

	ldr	r0, =tile19
	
	pop	{lr}
	
	mov	pc, lr


@ Redraws all the bricks without
@ Modifying the states of the bricks

makeAllBricks:
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


@ Returns 0 if not won or 1 if won

checkGameWon:
	push	{r4, r5, lr}
	
	mov	r4, #0
        ldr	r5, =tile0

checkallbricks:
	ldrb	r0, [r5, r4]
	add	r4, r4, #1
        cmp	r0, #0
        movne	r0, #0
        popne	{r4,r5,lr}
	movne	PC, lr

	cmp	r4, #30
	blt	checkallbricks

	mov	r0, #1
	
        pop	{r4, r5, lr}
	
	mov	pc, lr



.section	.data

@ 0 - broken
@ 1 - 1 hits to break
@ 2 - 2 hits to break
@ 3 - 3 hit to break

tile0:	.byte	1
tile10:	.byte 	2

.global	tile20
tile20:	.byte 	3

tile1:	.byte	1
tile11:	.byte	2		@ special
tile21:	.byte	3

tile2:	.byte	1
tile12:	.byte	2
tile22:	.byte	3

tile3:	.byte	1
tile13:	.byte	2
tile23:	.byte	3

tile4:	.byte	1
tile14:	.byte	2
tile24:	.byte	3

tile5:	.byte	1
tile15:	.byte	2
tile25:	.byte	3

tile6:	.byte	1
tile16:	.byte	2

.global	tile26

tile26:	.byte	3

tile7:	.byte	1
tile17:	.byte	2
tile27:	.byte	3

tile8:	.byte	1
tile18:	.byte	2		@ special
tile28:	.byte	3

tile9:	.byte	1
tile19:	.byte	2

tile29:	.byte	3

doTile:	.byte	1

emptyTile:	.byte	0
codeLog:	.asciz	"code: (%d, %d)\n"

test:		.asciz  "array values: {%d}, %d"
