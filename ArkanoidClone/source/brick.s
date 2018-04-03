@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section .text

@ r0 - x code
@ r1 - y code
@ r2 - colorCode
@ draws Brick and changes brick state
.global makeBrick
makeBrick:
	push	{r4-r6, lr}
	mov	r4, r0
	mov	r5, r1
	mov	r6, r2
	bl	codeToTile
	strB	r6, [r0]	@ store the brick state

	@ then draw brick
	mov	r0, r4
	mov	r1, r5
	mov	r2, r6
	bl	drawBrick

	pop	{r4-r6, lr}
	mov	pc, lr


@ sets the bricks for the initial state
@ no params or return values
.global	initBricks
initBricks:
	push	{r4-r6, lr}

	mov	r4, #0
	mov	r5, #0
	add	r6, r5, #3

	initBrickStateLoop:
		mov	r0, r4
		mov	r1, r5

		bl	codeToTile
		strB	r6, [r0]

		cmp	r0, #0

		movne	r2, r6
		movne	r0, r4
		movne	r1, r5
		blne	drawBrick

		@check X
		add	r4, r4, #1
		cmp	r4, #10
		blt	initBrickStateLoop

		@check Y
			add	r5, r5, #1
			sub	R6, R6, #1
			cmp	r5, #3
			movLT	r4, #0
			blt	initBrickStateLoop

	pop	{r4-r6, pc}


@ r0 - brick x position
@ r1 - brick y position
@ r2 - brick type (0, 1, 2, 3)
drawBrick:
	xpos		.req	r5
	ypos		.req	r6
	colorCode	.req	r7


	push	{r3-r8, lr}
	bl	CodeToXY

	mov	xpos, r0
	mov	ypos, r1
	mov	colorCode, r2

	mov	r3, #64
	mov	r4, #32

	mov	r2, #0x0
		@ make the outside brick

	add	xpos, xpos, #4
	add	ypos, ypos, #4

	mov	r3, #56
	mov	r4, #24

	cmp	colorCode, #0
	moveq	r2, #0

	cmp	colorCode, #1
	moveq	r2, #0x00FF00	@ 1 hit

	cmp	colorCode, #2
	moveq	r2, #0x007700	@ 2 hits

	cmp	colorCode, #3
	moveq	r2, #0x003300	@ 3 hits


	mov	r0, xpos
	mov	r1, ypos

	bl	drawCell

	pop	{r3-r8, pc}


@ params
@ r0 - x coordinate
@ r1 - y coordinate

@ returns 0 - didn't hit brick
@ 	   1 - hit brick
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

	moveq	r0, #0		@ didn't hit brick
	popeq	{r4-r7, lr}
	moveq	pc, lr

	sub	r2, r7, #1	@ degrade the brick
	mov	r0, r4
	mov	r1, r5
	bl	makeBrick
	@ r2 is the color

	mov	r0, #1		@ brick is hit
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

@ r0 r1 - xy position
@ returns r0 r1 - xy code
.global XYtoCode
XYtoCode:
	push	{r4,r5,lr}

	mov	r4, r0
	mov	r5, r1

	cmp	r5, #96
	movLT	r0, #44 @return a not real position
	movLT	r1, #44
        popLT 	{r4-r5, lr}
	movLT	PC, LR

	cmp	r5, #192
	movGT	r0, #44 @return a not real position
	movGT	r1, #44
        popGT 	{r4-r5, lr}
	movGT	PC, LR

	mov r5, #0 @default layer
	sub	r1, r1, #96
	yloop:
	cmp	r1, #32
	sub	r1, r1, #32
	movLT	r1, r5
	add	r5, r5, #1
	BGE	yloop

	mov	r4, #0 @default start
	sub	r0, r0, #36
	xloop:
	cmp	r0, #64
	sub	r0, r0, #64
	movLT	r0, r4
	add	r4,r4, #1
	BGE	xloop


	pop	{r4,r5, lr}
	mov	pc, lr

@ params
@r0 - xcode
@r1 - ycode

@ return
@ r0 - brickStateAddress
codeToTile:
	push	{lr}

	cmp	r0, #9
	LDRGT	r0, =emptyTile @error check first value
	popGT	{lr}
	movGT	pc, lr

	cmp	r1, #1
	blt	fromZero
	Beq	fromTen

	CMPGT	r1, #2
	Beq	fromTwenty
	@ invaild input, return 0
	ldr	r0, =emptyTile
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

@ redraws all the bricks without
@ modifying the states of the bricks
.global	makeAllBricks
makeAllBricks:
	push	{r4-r6, lr}
	mov	r4, #0
	mov	r5, #0

	getBrickStateLoop:
		mov	r0, r4
		mov	r1, r5

		bl	codeToTile
		LDRB	r6, [r0]

		mov	r2, r6
		mov	r0, r4
		mov	r1, r5
		cmp	r2, #0
		blne	drawBrick

		@check X
		add	r4, r4, #1
		cmp	r4, #10
		blt	getBrickStateLoop

		@check Y
			add	r5, r5, #1
			cmp	r5, #3
			movLT	r4, #0
			blt	getBrickStateLoop

	pop	{r4-r6, lr}
	mov	pc, lr

@returns 0 if not won or 1 if won
.global checkGameWon
checkGameWon:
	push {r4, r5, lr}
	mov r4, #0
        ldr r5, =tile0

checkallbricks:
	ldrb r0, [r5, r4]
	add  r4, r4, #1
        cmp  r0, #0
        movne r0, #0
        popne {r4,r5,lr}
	movne PC, lr

	cmp r4, #30
	blt checkallbricks

	mov r0, #1
        pop {r4, r5, lr}
	mov pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
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
	tile11:	.byte	2	@ special
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
	tile18:	.byte	2	@ special
	tile28:	.byte	3

	tile9:	.byte	1
	tile19:	.byte	2

	tile29:	.byte	3

	doTile:	.byte	1

	emptyTile:	.byte	0
	codeLog:	.asciz	"code: (%d, %d)\n"

	test:		.asciz  "array values: {%d}, %d"
