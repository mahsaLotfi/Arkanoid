@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section	.text

.global makeGame, anybutton, superPaddle, clearPaddle


makeGame:
	bl	resetScore

		@ Draw white border
		mov	r0, #0
		mov	r1, #0
		mov	r2, #0xFFFFFF
		mov	r3, #720
		mov	r4, #960
		bl	drawCell

		@ Draw darkBlue background
		mov	r0, #9
		mov	r1, #4
		mov	r2, #0x6699
		mov	r3, #702
		mov	r4, #944
		bl	drawCell


		@ Draw black foreground
		mov	r0, #36
		mov	r1, #36
		mov	r2, #0x0
		mov	r3, #640
		mov	r4, #880
		bl	drawCell

		@ Initialize game mechanics
		bl	initScore
		bl	initLives
		bl	initBricks

		ldr	r0, =paddlePosition
			mov	r1, #300
			str	r1, [r0]

		bl	paddle	
		b	GAME_OVER


paddle:
	push	{r4-r9, lr}

		ldr	r8, =paddleStart		@ Starting position
		ldr	r8, [r8]
		mov	r0, r8

	mov	r4, #32						@ Paddle size
	mov	r7, #1500					
	bl	initBall

	paddleLoop:
		bl	isBallMovable
		bl	check_drops
		bl	updateBricks
		bl	updateStats
		bl	fixBorder

		ldr	r6, =paddleBound
		ldr	r0, [r6]

			@ Draw paddle
	 		add	r0, r8, #32
			mov	r1, #774
			mov	r2, #0x6699
			ldr	r3, =paddleSize
			ldr	r3, [r3]
			sub	r3, r3, #64
			bl	drawCell

			mov	r0, r8
			mov	r1, #774
			mov	r2, #0xFFFFFF
			mov	r3, #32
			bl	drawCell

			ldr	r0, =paddleSize
			ldr	r0, [r0]
			add	r0, r0, r8
			sub	r0, #32
			mov	r1, #774
			mov	r2, #0xFFFFFF
			mov	r3, #32
			bl	drawCell

		ldr	r8, =paddlePosition
		ldr	r8, [r8]

		bl	isGameWon 
        cmp	r0, #1
		popeq	{r4-r9, lr}
        beq	GAME_WIN

    	ldr	r0, =lives
        ldr 	r0, [r0]
        cmp	r0, #0
		popeq	{r4-r9, pc}


		@ Read SNES Button
		mov	r0, r7
		bl	readSNES
		mov	r7, #1500

		cmp	r0, #409
		bleq	pause_menu

		cmp	r0, #32768
		bleq	launchBall

		cmp	r0, #512
		beq	moveLeft

		cmp	r0, #256
		beq	moveRight

		cmp	r0, #640
		moveq	r7, #750
		beq	moveLeft

		cmp	r0, #384
		moveq	r7, #750
		bne	paddleLoop
		beq	moveRight

		cmp	r0, #128
		moveq	r7, #750

		moveRight:
			@ Paddle bounds
			ldr	r6, =paddleBound
			ldr	r0, [r6]
			cmp	r8, r0
			bge	paddleLoop

				@ Remove paddle draw trace
				mov	r0, r8
				mov	r1, #774
				mov	r2, #0x0
				mov	r3, #32
				mov	r4, #32
				bl	drawCell

				@ Update Paddle Position
				add	r8, r8, #32
				ldr	r6, =paddlePosition
				str	r8, [r6]
				mov	r0, r8

			bl	initBall
			b	paddleLoop

		moveLeft:
			cmp	r8, #36
			ble	paddleLoop

			ldr	r0, =paddleSize
			ldr	r0, [r0]
			sub	r0, r0, #32
			add	r0, r8

			@ Remove paddle draw trace
			mov	r1, #774
			mov	r2, #0x0
			mov	r3, #32
			bl	drawCell

			@ Update Paddle Position
			sub	r8,r8, #32
			ldr	r6, =paddlePosition
			str	r8, [r6]
			mov	r0, r8

			bl	initBall
			b	paddleLoop

@ Arguments: None
@ Return: None
isBallMovable:
	push	{r4,r5, lr}

	ldr	r0, =ballMovable
	ldr	r1, [r0]
	mov	r4, r0

	cmp	r1, #0
	beq	moveBallLoop

	mov	r5, #1500		
	cmp	r7, r5	
	bge	moveBallLoop

	@ Stationary ball
	mov	r1, #0		
	str	r1, [r0]
	pop	{r4,r5,pc}

	@ Dynamic ball
	moveBallLoop:		
		bl	moveBall
		mov	r1, #1
		mov	r0, r4
		str	r1, [r0]
		pop	{r4,r5,pc}

anybutton:
	mov	r0, #8192
        bl 	readSNES
	cmp     r0, #0
        bne	start_menu
	b	anybutton

@ PowerUp Element
@ Changes paddle size to superPadde size
superPaddle:		
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

drawInitialPaddle:
	push	{r4, lr}

	@ init Paddle
	mov	r0, #300
	mov	r1, #774
	mov	r2, #0x006699
	mov	r3, #120
	mov	r4, #32		
	bl	drawCell

	mov	r0, #300
	mov	r1, #774
	mov	r2, #0xFFFFFF
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	pop	{r4, pc}


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
fixBorder:
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

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

	.global paddleSize
	paddleSize:	.int	120

	.global paddleStart
	paddleStart:	.int	300

	.global	paddlePosition
	paddlePosition:	.int	0

	paddleBound:	.int	556

	ballMovable:	.int	1
