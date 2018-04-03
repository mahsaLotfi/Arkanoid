@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

.global	moveBall
@ no arguments or return values
moveBall:
	push	{r4-r5,lr}
	bl	changeSlope

	ldr	r0, =slopeCode
	ldr	r0, [r0]

	cmp	r0, #0		@ ignore if not launched
	popeq	{r4-r5,pc}

	@ slopes going up
	cmp	r0, #9
	moveq	r4, #16
	moveq	r5, #16

	cmp	r0, #7
	moveq	r4, #-16
	moveq	r5, #16

	cmp	r0, #89
	moveq	r4, #8
	moveq	r5, #16

	cmp	r0, #87
	moveq	r4, #-8
	moveq	r5, #16

	@ slopes going down
	cmp	r0, #3
	moveq	r4, #16
	moveq	r5, #-16

	cmp	r0, #1
	moveq	r4, #-16
	moveq	r5, #-16

	cmp	r0, #23
	moveq	r4, #8
	moveq	r5, #-16

	cmp	r0, #21
	moveq	r4, #-8
	moveq	r5, #-16

	@ move ball here
	ldr	r0, =curX
	ldr	r1, [r0]
	add	r1, r1, r4
	str	r1, [r0]

	ldr	r0, =curY
	ldr	r1, [r0]
	sub	r1, r1, r5
	str	r1, [r0]

	bl	getRidOfBall
	bl	drawBall
	pop	{r4-r5,pc}

@ key method. Changes the course of the ball
changeSlope:
	push	{r4-r9, lr}

	ldr	r0, =curX
	ldr	r1, [r0]
	mov	r4, r1

	ldr	r2, =curY
	ldr	r2, [r2]
	mov	r5, r2

	ldr	r3, =slopeCode
	ldr	r3, [r3]
	mov	r6, r3

	ldr	r0, =xandy	@for debugging purposes
@	bl	printf

	@ check if walls are hit
	cmp	r4,#644
	blGE	switch45

	cmp	r5, #36
	blLE	switch60

	cmp	r4, #36
	blLE	switch45

	cmp	r5, #740		@ check if paddle catches the ball
	blGE	checkIfCaught

	bl	checkCorners		@ check if other corners have hit something

	pop	{r4-r9, lr}
	mov      pc, LR

	topleft:
		push 	{lr}
		ldr	r0, =curX @top left corner
		ldr	r0, [r0]

		ldr	r1, =curY
		ldr	r1, [r1]

		bl	hitBrick @returns if hit
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0

		str	r2, [r1]
	pop	{pc}

	topright:
		push 	{lr}
		ldr	r0, =curX @top right corner
		ldr	r0, [r0]
	        add	r0, r0, #32

		ldr	r1, =curY
		ldr	r1, [r1]

		bl	hitBrick @returns if hit
        	ldr     r1, =score
		ldr	r2, [r1]

        	add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}

	bottomleft:
		push 	{lr}
		ldr	r0, =curX @bottom left corner
		ldr	r0, [r0]

		ldr	r1, =curY
		ldr	r1, [r1]
	  	add	r1, r1, #32

		bl	hitBrick
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}

	bottomright:
		push 	{lr}
		ldr	r0, =curX @bottom right corner
		ldr	r0, [r0]
		add	r0, r0, #32

		ldr	r1, =curY
		ldr	r1, [r1]
	  	add	r1, r1, #32

		bl	hitBrick
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}

@Does not take or return arguments
checkCorners: @makes function calls to avoid checking the same brick
	push	{r4-r9, lr}

	bl topleft @check this corner initally
	@r9 keeps track of if the ball should change direction
	mov 	r9, r0

	ldr	r4, =curX @r4 is x
	ldr	r4, [r4]

	ldr	r5, =curY @r5 is y
	ldr	r5, [r5]

	mov	r0, r4
	mov	r1, r5
	bl	XYtoCode
	mov	r6, r0 @r6 is top left x (till bottom right)
	mov	r7, r1 @r7 is top left y (till bottom right)

	mov	r0, r4
	add	r1,r5, #32 @bottom left
	bl	XYtoCode

	cmp	r1, r7
	blne	bottomleft @calls bottom left if different tile from top left
	orrne	r9, r9, r0

	add	r0, r4, #32
	mov	r1, r5
	bl	XYtoCode

	cmp 	r6, r0
	mov	r6, r0 @store thes values for next check
	mov	r7, r1
	blne	topright @if top right and top left are different check hits
	orrne	r9, r9, r0

	@this section deals with bottom right, top right and bottom left affect this
	add	r0, r4, #32
	add	r1, r5, #32 @bottom right
	bl	XYtoCode
	cmp 	r0, r6
	Beq	skip

	mov	r6, r0
	mov	r7, r1

        @check top right
	add	r0, r4, #32
	mov	r1, r5
	bl	XYtoCode

	cmp	r1, r7
	Beq	skip

	bl	bottomright
	orr	r9, r9, r0

	@label if bottom right doesn't need to be checked
skip:   cmp	r9, #0
	blne	switch60

	pop	{r4-r9, lr}
	mov      pc, LR


@ functions associated with the value pack \\

@ paddle catches ball as effect of value pack
ballIsCaught:
	push	{lr}
		ldr	r0, =lives
		ldr	r1, [r0]
		add	r1, r1, #1
		str	r1, [r0]

		ldr	r0, =willCatchBall
		mov	r1, #0
		str	r1, [r0]

		bl	unlaunch
	pop	{pc}


.global	enableCatchBall
enableCatchBall:
	push	{lr}

	ldr	r0, =willCatchBall
	mov	r1, #1
	str	r1, [r0]

	pop	{pc}


checkIfCaught:
	push	{r4-r8, lr}

	ldr	r0, =willCatchBall	@ check if ball will be caught
	ldr	r0, [r0]
	cmp	r0, #1
	bleq	ballIsCaught
	popeq	{r4-r8, pc}

	ldr	r0, =slopeCode		@ check if ball is launched
	ldr	r0, [r0]
	cmp	r0, #0
	popeq	{r4-r8, pc}

	ldr	r0, =curX	@ leftbound of ball
	ldr	r4, [r0]

	ldr	r0, =paddlePosition
	ldr	r5, [r0]	@ leftbound of paddle

	add	r6, r4, #32	@ rightbound of ball

	ldr	r0, =paddleSize
	ldr	r7, [r0]
	add	r7, r7, r5	@ rightbound of paddle

	cmp	r6, r5		@ R ball - L paddle
	blLT	ballDies	@ if ball too far right, ball will die
	popLT	{r4-r8, pc}

	cmp	r7, r4		@ R paddle - L ball
	blLT	ballDies	@ if paddle too far right, ball will die
	popLT	{r4-r8, pc}

	@checkRightBound
		sub	r7, r7, #48	@edge of paddle
		cmp	r7, r4		@ edge of paddle - L ball
		blLT	switch45Paddle	@ bounce 45
		popLT	{r4-r8, pc}

	@checkLeftBound
		add	r5, r5, #48	@ edge of paddle
		cmp	r6, r5		@ R ball - edge of paddle
		blLE	switch45Paddle	@ bounce 45
		blGT	switch60Paddle
	pop	{r4-r8, pc}

@ unlaunch ball once below the paddle
ballDies:
	push	{r4-r5,lr}

	ldr	r4, =slopeCode
	ldr	r4, [r4]

	cmp	r4, #0
	popeq	{r4-r5,pc}

	ldr	r4, =ballWillDie
	ldr	r5, [r4]

	cmp	r5, #5
		ADDLT	r5, r5, #1
		strLT	r5, [r4]
		bleq	unlaunch

	pop	{r4-r5,pc}

@ switch the ball's trajectory to 60 degrees
switch60:
	push	{lr}
	ldr	r0, =slopeCode
	ldr	r1, [r0]

	cmp	r1, #9
	moveq	r2, #23

	cmp	r1, #89
	moveq	r2, #23

	cmp	r1, #87
	moveq	r2, #21

	cmp	r1, #7
	moveq	r2, #21

	cmp	r1, #21
	moveq	r2, #87

	cmp	r1, #1
	moveq	r2, #87

	cmp	r1, #3
	moveq	r2, #89

	cmp	r1, #23
	moveq	r2, #89

	cmp	r1, #0
	moveq	r2, #0

	str	r2, [r0]

	pop	{pc}


@ switch the ball's trajectory to 45 degrees
switch45:
	push	{lr}
	ldr	r0, =slopeCode
	ldr	r1, [r0]

	cmp	r1, #9
	moveq	r2, #7

	cmp	r1, #89
	moveq	r2, #7

	cmp	r1, #87
	moveq	r2, #9

	cmp	r1, #7
	moveq	r2, #9

	cmp	r1, #21
	moveq	r2, #3

	cmp	r1, #1
	moveq	r2, #3

	cmp	r1, #3
	moveq	r2, #1

	cmp	r1, #23
	moveq	r2, #1

	str	r2, [r0]
	pop	{pc}

@ switch the ball's trajectory to 60 degrees
@ that the paddle causes
switch60Paddle:
	push	{lr}

	ldr	r0, =curY
	ldr	r0, [r0]

	cmp	r0, #748
		blGE	switch45
		popGE	{pc}

	ldr	r0, =slopeCode
	ldr	r1, [r0]
	mov	r2, r1

	cmp	r1, #1
	moveq	r2, #87

	cmp	r1, #21
	moveq	r2, #87

	cmp	r1, #3
	moveq	r2, #89

	cmp	r1, #23
	moveq	r2, #89

	str	r2, [r0]
	pop	{pc}

@ switch the ball's trajectory to 45 degrees
@ when caused by the paddle
switch45Paddle:
	push	{lr}

	ldr	r0, =curY
	ldr	r0, [r0]

	cmp	r0, #748
		blGE	switch45
		popGE	{pc}

	ldr	r0, =slopeCode
	ldr	r1, [r0]
	mov	r2, r1

	cmp	r1, #1
	moveq	r2, #7

	cmp	r1, #21
	moveq	r2, #7

	cmp	r1, #3
	moveq	r2, #9

	cmp	r1, #23
	moveq	r2, #9

	str	r2, [r0]
	pop	{pc}

 
.section	.data


	illegalslope:	.asciz	"here"
	xandy:		.asciz	"x: %d y: %d slope: %d\n"

	ballAndPaddle:	.asciz	"ball: %d, paddle: %d\n"

	.global	ballWillDie
	ballWillDie:	.byte	0

	willCatchBall:	.int	0
