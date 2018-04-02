.section .text

.global makeGame
makeGame:
	BL	resetScore

		// draw background
		MOV	r0, #4
		MOV	r1, #4
		MOV	r2, #0x007770
		MOV	r3, #704
		MOV	r4, #944
		BL	makeTile


		// foreground
		MOV	r0, #36
		MOV	r1, #36
		MOV	r2, #0x0
		MOV	r3, #640
		MOV	r4, #880
		BL	makeTile

		// initialize game mechanics
		BL	initScore
		BL	initLives
		BL	initBricks

		LDR	r0, =paddlePosition
			MOV	r1, #228
			STR	r1, [r0]

		BL	paddle	// when done from paddle loop, game is lsot
		B	LOST


paddle:
	PUSH	{r4-r9, lr}

	LDR	r8, =paddleStart // default xstart for paddle
		LDR	r8, [r8]
		MOV	r0, r8

	MOV	r4, #32		//default size of the paddle
	MOV	r7, #1500	// pause length
	BL	initBall

	paddleLoop:

		// branch to other game mechanics
		BL	maybeMoveBall
		BL	dropListener
		BL	makeAllBricks
		BL	fixWalls
		BL	updateScoreAndLives

		//ensure padde is fully drawn
		LDR	r6, =paddleBound
		LDR	r0, [r6]

			//paddle
	 		ADD	r0, r8, #32
			MOV	r1, #774
			MOV	r2, #0x8800000
			LDR	r3, =paddleSize
			LDR	r3, [r3]
			SUB	r3, r3, #64
			BL	makeTile

			//left edge of paddle
			MOV	r0, r8
			MOV	r1, #774
			MOV	r2, #0x330000
			MOV	r3, #32
			BL	makeTile

			// right edge of paddle
			LDR	r0, =paddleSize
			LDR	r0, [r0]
			ADD	r0, r0, r8
			SUB	r0, #32
			MOV	r1, #774
			MOV	r2, #0x330000
			MOV	r3, #32
			BL	makeTile

		LDR	r8, =paddlePosition
		LDR	r8, [r8]

		// check if game is won
		BL	checkGameWon //check if game has been won
        	CMP	r0, #1
		POPEQ	{r4-r9, lr}
        	BEQ	WIN

		// branch out of game for lose implementation
        	LDR	r0, =lifeCount
        	LDR 	r0, [r0]
        	CMP	r0, #0
		POPEQ	{r4-r9, pc}


		//Reading SNES buttons

		MOV	r0, r7			// delay
		BL	readSNES
		MOV	r7, #1500

			CMP	r0, #4096		// start
			BLEQ	pauseMenu

			CMP	r0, #32768		// B
			BLEQ	launchBall

			CMP	r0, #16384		// Y - testing purposes only
//			BLEQ	testBall

			CMP	r0, #512		// L
			BEQ	moveLeft

			CMP	r0, #256		// R
			BEQ	moveRight

			CMP	r0, #640		// L + A
			MOVEQ	r7, #750
			BEQ	moveLeft

			CMP	r0, #384		// R + A
			MOVEQ	r7, #750
			BNE	paddleLoop
			BEQ	moveRight

			CMP	r0, #128		//A
			MOVEQ	r7, #750

		moveRight:
			// get the size of the paddle
			LDR	r6, =paddleBound
			LDR	r0, [r6]
			CMP	r8, r0
			BGE	paddleLoop

				//repaint black where the paddle isn't
				MOV	r0, r8
				MOV	r1, #774
				MOV	r2, #0x0
				MOV	r3, #32
				MOV	r4, #32
				BL	makeTile

				// change the paddle position
				ADD	r8, r8, #32
				LDR	r6, =paddlePosition
				STR	r8, [r6]
				MOV	r0, r8

			BL	initBall
			B	paddleLoop

		moveLeft:
			CMP	r8, #36
			BLE	paddleLoop

				// repaint
				LDR	r0, =paddleSize
				LDR	r0, [r0]
				SUB	r0, r0, #32
				ADD	r0, r8

				//repaint black where the paddle isn't
				MOV	r1, #774
				MOV	r2, #0x0
				MOV	r3, #32
				BL	makeTile

				// change the paddle position
				SUB	r8,r8, #32
				LDR	r6, =paddlePosition
				STR	r8, [r6]
				MOV	r0, r8

			BL	initBall
			B	paddleLoop

// checks if ball will be moved
// no parameters or return value
maybeMoveBall:
	PUSH	{r4,r5, lr}

	LDR	r0, =willMoveBall
	LDR	r1, [r0]
	MOV	r4, r0

	CMP	r1, #0
	BEQ	moveBallLoop

	MOV	r5, #1414		// if A is held, the delay (r5) should be less than 1414
	CMP	r7, r5			// so move the ball slower
	BGE	moveBallLoop

	MOV	r1, #0			// ball not moved
	STR	r1, [r0]
	POP	{r4,r5,pc}

	moveBallLoop:			// ball moved
		BL	moveBall
		MOV	r1, #1
		MOV	r0, r4
		STR	r1, [r0]
		POP	{r4,r5,pc}

.global anybutton		// read any button (for the game over screen)
anybutton:
	MOV	r0, #8192
        BL 	readSNES
	CMP     r0, #0
        BNE	menusetup
	B	anybutton

.global bigPaddle
bigPaddle:			// change paddle size to big paddle
	PUSH	{lr}
	BL	drawInitialPaddle

	LDR	r0, =paddleSize
	MOV	r1, #384
	STR	r1, [r0]

	LDR	r0, =paddleStart
	MOV	r1, #0
	STR	r1, [r0]

	LDR	r0, =paddleBound
	MOV	r1, #292
	STR	r1, [r0]

	POP	{pc}

drawInitialPaddle:
	PUSH	{r4, lr}

	// init Paddle
	MOV	r0, #228	// x
	MOV	r1, #774	// y
	MOV	r2, #0x880000	// color
	MOV	r3, #192
	MOV	r4, #32		// height
	BL	makeTile

	MOV	r0, #228
	MOV	r1, #774
	MOV	r2, #0x330000
	MOV	r3, #32
	MOV	r4, r3
	BL	makeTile

	POP	{r4, pc}


.global	clearPaddle
clearPaddle:
	PUSH	{lr}
	MOV	r0, #36
	MOV	r1, #774
	MOV	r2, #0x0
	MOV	r3, #640
	MOV	r4, #32
	BL	makeTile
	POP	{lr}
	MOV	PC, LR


// ensures walls are not written over
fixWalls:
	PUSH	{r4,lr}

	MOV	r0, #4
	MOV	r1, #36
	MOV	r2, #0x007770
	MOV	r3, #31
	MOV	r4, #816
	BL	makeTile

	MOV	r0, #677
	MOV	r1, #36
	MOV	r2, #0x007770
	MOV	r3, #31
	MOV	r4, #816
	BL	makeTile

	POP	{r4,pc}

.section	.data


	.global paddleSize
	paddleSize:	.int	192

	.global paddleStart
	paddleStart:	.int	228

	.global	paddlePosition
	paddlePosition:	.int	228

	paddleBound:	.int	484

	willMoveBall:	.int	1
