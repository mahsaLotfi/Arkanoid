@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Code section @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.section .text

.global makeGame
makeGame:
		bl	resetScore
		bl	initMap

		bl	initScore
		bl	initLives
		bl	initBricks

		bl	paddle
		b	gameOver

initMap:
	push	{lr}

	@  Create background
		mov	r0, #4
		mov	r1, #4
		mov	r2, #0x007770
		mov	r3, #704
		mov	r4, #944
		bl	makeTile


		@ Create foreground
		mov	r0, #36
		mov	r1, #36
		mov	r2, #0x0
		mov	r3, #640
		mov	r4, #880
		bl	makeTile

	pop	{pc}

paddle:
	push	{r4-r9, lr}

	ldr	r0, =paddlePos
	mov	r1, #228
	str	r1, [r0]

	ldr	r8, =paddleInit @ default xstart for paddle
		ldr	r8, [r8]
		mov	r0, r8

	mov	r4, #32		@default size of the paddle
	mov	r7, #1500	@ pause length
	bl	initBall

	paddleLoop:

		@ branch to other game mechanics
		bl	checkMoveBall
		bl	dropListener
		bl	makeAllBricks
		bl	fixWalls
		bl	updateScoreAndLives

		@ensure padde is fully drawn
		ldr	r6, =paddleBoundary
		ldr	r0, [r6]

			@paddle
	 		add	r0, r8, #32
			mov	r1, #774
			mov	r2, #0x8800000
			ldr	r3, =paddleSize
			ldr	r3, [r3]
			sub	r3, r3, #64
			bl	makeTile

			@left edge of paddle
			mov	r0, r8
			mov	r1, #774
			mov	r2, #0x330000
			mov	r3, #32
			bl	makeTile

			@ right edge of paddle
			ldr	r0, =paddleSize
			ldr	r0, [r0]
			add	r0, r0, r8
			sub	r0, #32
			mov	r1, #774
			mov	r2, #0x330000
			mov	r3, #32
			bl	makeTile

		ldr	r8, =paddlePos
		ldr	r8, [r8]

		@ check if game is won
		bl	checkGameWon @check if game has been won
        	cmp	r0, #1
		popeq	{r4-r9, lr}
        	beq	gameWon

		@ branch out of game for lose implementation
        	ldr	r0, =lifeCount
        	ldr 	r0, [r0]
        	cmp	r0, #0
		popeq	{r4-r9, pc}


		@Reading SNES buttons

		mov	r0, r7			@ delay
		bl	readSNES
		mov	r7, #1500

			cmp	r0, #4096		@ start
			bleq	pauseMenu

			cmp	r0, #32768		@ b
			bleq	launchBall

			cmp	r0, #16384		@ Y - testing purposes only
@			bleq	testBall

			cmp	r0, #512		@ L
			beq	moveLeft

			cmp	r0, #256		@ R
			beq	moveRight

			cmp	r0, #640		@ L + A
			moveq	r7, #750
			beq	moveLeft

			cmp	r0, #384		@ R + A
			moveq	r7, #750
			bne	paddleLoop
			beq	moveRight

			cmp	r0, #128		@A
			moveq	r7, #750

		moveRight:
			@ get the size of the paddle
			ldr	r6, =paddleBoundary
			ldr	r0, [r6]
			cmp	r8, r0
			bge	paddleLoop

				@repaint black where the paddle isn't
				mov	r0, r8
				mov	r1, #774
				mov	r2, #0x0
				mov	r3, #32
				mov	r4, #32
				bl	makeTile

				@ change the paddle position
				add	r8, r8, #32
				ldr	r6, =paddlePos
				str	r8, [r6]
				mov	r0, r8

			bl	initBall
			b	paddleLoop

		moveLeft:
			cmp	r8, #36
			ble	paddleLoop

				@ repaint
				ldr	r0, =paddleSize
				ldr	r0, [r0]
				sub	r0, r0, #32
				add	r0, r8

				@repaint black where the paddle isn't
				mov	r1, #774
				mov	r2, #0x0
				mov	r3, #32
				bl	makeTile

				@ change the paddle position
				sub	r8,r8, #32
				ldr	r6, =paddlePos
				str	r8, [r6]
				mov	r0, r8

			bl	initBall
			b	paddleLoop

@ checks if ball will be moved
@ no parameters or return value
checkMoveBall:
	push	{r4,r5, lr}

	ldr	r0, =isBallMovable
	ldr	r1, [r0]
	mov	r4, r0

	cmp	r1, #0
	beq	moveBallLoop

	mov	r5, #1414		@ if A is held, the delay (r5) should be less than 1414
	cmp	r7, r5			@ so move the ball slower
	bge	moveBallLoop

	mov	r1, #0			@ ball not moved
	str	r1, [r0]
	pop	{r4,r5,pc}

	moveBallLoop:			@ bakl moved
		bl	moveBall
		mov	r1, #1
		mov	r0, r4
		str	r1, [r0]
		pop	{r4,r5,pc}

.global anybutton		@ read any button (for the game over screen)
anybutton:
	mov	r0, #8192
        bl 	readSNES
	cmp     r0, #0
        bne	menusetup
	b	anybutton

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Paddle section @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

drawInitialPaddle:
	push	{r4, lr}

	mov	r0, #228	@ x
	mov	r1, #774	@ y
	mov	r2, #0x880000	@ color
	mov	r3, #192
	mov	r4, #32		@ height
	bl	makeTile

	mov	r0, #228
	mov	r1, #774
	mov	r2, #0x330000
	mov	r3, #32
	mov	r4, r3
	bl	makeTile

	pop	{r4, pc}

.global	clearPaddle
clearPaddle:
	push	{lr}
	mov	r0, #36
	mov	r1, #774
	mov	r2, #0x0
	mov	r3, #640
	mov	r4, #32
	bl	makeTile
	pop	{lr}
	mov	pc, lr

@ Paddle for value pack
.global superPaddle
superPaddle:		
	push	{lr}
	bl	drawInitialPaddle

	ldr	r0, =paddleSize
	mov	r1, #384
	str	r1, [r0]

	ldr	r0, =paddleInit
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =paddleBoundary
	mov	r1, #292
	str	r1, [r0]

	pop	{pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Wall section @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

fixWalls:
	push	{r4,lr}

	mov	r0, #4
	mov	r1, #36
	mov	r2, #0x007770
	mov	r3, #31
	mov	r4, #816
	bl	makeTile

	mov	r0, #677
	mov	r1, #36
	mov	r2, #0x007770
	mov	r3, #31
	mov	r4, #816
	bl	makeTile

	pop	{r4,pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ Data section @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data
.global paddleInit, paddleSize, paddlePos

	isBallMovable:	.int	1

	paddleInit:		.int	228

	paddleSize:		.int	192

	paddlePos:	.int	228

	paddleBoundary:	.int	484