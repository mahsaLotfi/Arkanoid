.section .text

.global startGame
startGame:
	bl	resetScore

		@ drawing the border
		mov	r0, #0
		mov	r1, #0
		mov	r2, #0xFFFFFF
		mov	r3, #720
		mov	r4, #960
		bl	drawCell

		@ drawing the background
		mov	r0, #9
		mov	r1, #4
		mov	r2, #0x6699
		mov	r3, #702
		mov	r4, #944
		bl	drawCell


		@ creating the foreground
		mov	r0, #36
		mov	r1, #36
		mov	r2, #0x0
		mov	r3, #640
		mov	r4, #880
		bl	drawCell

		@ initialize the game stats and elements
		bl	Score
		bl	Lives
		bl	InitBrick

		ldr	r0, =paddlePos
			mov	r1, #300
			str	r1, [r0]

		bl	paddle										@ if exit paddle loop, it means the game is lost
		b	LOST


paddle:
	push	{r4-r9, lr}

	ldr	r8, =paddleStart								@ the starting x coordinate for paddle
		ldr	r8, [r8]
		mov	r0, r8

	mov	r4, #32											@ the size of paddle
	mov	r7, #1500										@ pause menu dimensions
	bl	initBall

	paddleLoop:

		@ branch link to other game functions
		bl	maybemoveBall
		bl	dropListener
		bl	allBricks
		bl	fixWalls
		bl	Update

		@check paddle drawn successfully
		ldr	r6, =paddleBound
		ldr	r0, [r6]

			@paddle
	 		add	r0, r8, #32
			mov	r1, #774
			mov	r2, #0x6699
			ldr	r3, =paddleSize
			ldr	r3, [r3]
			sub	r3, r3, #64
			bl	drawCell

			@ paddle left side
			mov	r0, r8
			mov	r1, #774
			mov	r2, #0xFFFFFF
			mov	r3, #32
			bl	drawCell

			@ paddle right side
			ldr	r0, =paddleSize
			ldr	r0, [r0]
			add	r0, r0, r8
			sub	r0, #32
			mov	r1, #774
			mov	r2, #0xFFFFFF
			mov	r3, #32
			bl	drawCell

		ldr	r8, =paddlePos
		ldr	r8, [r8]

		@ see if game is won
		bl	checkGameWon @check if game has been won
        	cmp	r0, #1
		popeq	{r4-r9, lr}
        	beq	WIN

		@ exit game loop if lose
        	ldr	r0, =lives
        	ldr 	r0, [r0]
        	cmp	r0, #0
		popeq	{r4-r9, pc}


		@read SNES input

		mov	r0, r7			@ delay
		bl	readSNES
		mov	r7, #1500

			cmp	r0, #4096		@ start
			bleq	pauseMenu

			cmp	r0, #32768		@ b
			bleq	launchBall

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
			@ retrieve paddle size
			ldr	r6, =paddleBound
			ldr	r0, [r6]
			cmp	r8, r0
			bge	paddleLoop

				@repaint black where the paddle isn't
				mov	r0, r8
				mov	r1, #774
				mov	r2, #0x0
				mov	r3, #32
				mov	r4, #32
				bl	drawCell

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
				bl	drawCell

				@ update paddle position
				sub	r8,r8, #32
				ldr	r6, =paddlePos
				str	r8, [r6]
				mov	r0, r8

			bl	initBall
			b	paddleLoop

@ check if ball move
maybemoveBall:
	push	{r4,r5, lr}

	ldr	r0, =willBallMove
	ldr	r1, [r0]
	mov	r4, r0

	cmp	r1, #0
	beq	moveBallLoop

	mov	r5, #1414		@ if A button is hold, then delay < 1414
	cmp	r7, r5			@ slow down ball movement
	bge	moveBallLoop

	mov	r1, #0			@ no ball move
	str	r1, [r0]
	pop	{r4,r5,pc}

	moveBallLoop:			@ ball moved
		bl	moveBall
		mov	r1, #1
		mov	r0, r4
		str	r1, [r0]
		pop	{r4,r5,pc}

.global anybutton			@ any button press after game lose
anybutton:
	mov	r0, #8192
        bl 	readSNES
	cmp     r0, #0
        bne	menusetup
	b	anybutton

.global bigPaddle
bigPaddle:					@ enlarge paddle size
	push	{lr}

	ldr	r0, =paddleSize
	mov	r1, #200
	str	r1, [r0]

	ldr	r0, =paddleStart
	mov	r1, #300
	str	r1, [r0]

	ldr	r0, =paddleBound
	mov	r1, #476
	str	r1, [r0]

	pop	{pc}

drawInitPaddle:
	push	{r4, lr}

	@ init Paddle
	mov	r0, #300	@ x
	mov	r1, #774	@ y
	mov	r2, #0x006699	@ color
	mov	r3, #120
	mov	r4, #32		@ height
	bl	drawCell

	mov	r0, #300
	mov	r1, #774
	mov	r2, #0xFFFFFF
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	pop	{r4, pc}


.global	clearPaddle
clearPaddle:
	push	{lr}
	mov	r0, #36
	mov	r1, #774
	mov	r2, #0x0
	mov	r3, #640
	mov	r4, #32
	bl	drawCell
	pop	{lr}
	mov	PC, LR


@ ensures walls are not written over
fixWalls:
	push	{r4,lr}

	mov	r0, #9
	mov	r1, #36
	mov	r2, #0x6699
	mov	r3, #26
	mov	r4, #816
	bl	drawCell

	mov	r0, #677
	mov	r1, #36
	mov	r2, #0x6699
	mov	r3, #31
	mov	r4, #816
	bl	drawCell

	pop	{r4,pc}

 
.section	.data


	.global paddleSize
	paddleSize:	.int	120

	.global paddleStart
	paddleStart:	.int	300

	.global	paddlePos
	paddlePos:	.int	0

	paddleBound:	.int	556

	willBallMove:	.int	1
