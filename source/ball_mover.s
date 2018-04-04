@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section	.text

.global	moveBall, enableCatchBall


@ no arguments or return values
moveBall:
	push	{r4-r5,lr}
	bl	changeSlope

	ldr	r0, =ballSlope
	ldr	r0, [r0]

	cmp	r0, #0
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

	bl	clearBall
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

	ldr	r3, =ballSlope
	ldr	r3, [r3]
	mov	r6, r3

	@ check if walls are hit
	cmp	r4,#644
	blge	switch45

	cmp	r5, #36
	blle	switch60

	cmp	r4, #36
	blle	switch45

	cmp	r5, #740
	blge	checkIfCaught

	bl	checkCorners

	pop	{r4-r9, lr}
	mov      pc, LR

	topleft:
		push 	{lr}
		ldr	r0, =curX
		ldr	r0, [r0]

		ldr	r1, =curY
		ldr	r1, [r1]

		bl	hit_brick
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0

		str	r2, [r1]
	pop	{pc}

	topright:
		push 	{lr}
		ldr	r0, =curX
		ldr	r0, [r0]
	        add	r0, r0, #32

		ldr	r1, =curY
		ldr	r1, [r1]

		bl	hit_brick
        	ldr     r1, =score
		ldr	r2, [r1]

        	add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}

	bottomleft:
		push 	{lr}
		ldr	r0, =curX
		ldr	r0, [r0]

		ldr	r1, =curY
		ldr	r1, [r1]
	  	add	r1, r1, #32

		bl	hit_brick
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}

	bottomright:
		push 	{lr}
		ldr	r0, =curX
		ldr	r0, [r0]
		add	r0, r0, #32

		ldr	r1, =curY
		ldr	r1, [r1]
	  	add	r1, r1, #32

		bl	hit_brick
	        ldr     r1, =score
		ldr	r2, [r1]
	        add	r2, r2, r0
		str	r2, [r1]
	pop	{pc}


checkCorners:
	push	{r4-r9, lr}

	bl	topleft
	mov 	r9, r0

	ldr	r4, =curX @r4 is x
	ldr	r4, [r4]

	ldr	r5, =curY @r5 is y
	ldr	r5, [r5]

	mov	r0, r4
	mov	r1, r5
	bl	brick_pos
	mov	r6, r0 
	mov	r7, r1

	mov	r0, r4
	add	r1,r5, #32
	bl	brick_pos

	cmp	r1, r7
	blne	bottomleft
	orrne	r9, r9, r0

	add	r0, r4, #32
	mov	r1, r5
	bl	brick_pos

	cmp 	r6, r0
	mov	r6, r0
	mov	r7, r1
	blne	topright
	orrne	r9, r9, r0

	add	r0, r4, #32
	add	r1, r5, #32
	bl	brick_pos
	cmp 	r0, r6
	beq	skip

	mov	r6, r0
	mov	r7, r1

	add	r0, r4, #32
	mov	r1, r5
	bl	brick_pos

	cmp	r1, r7
	beq	skip

	bl	bottomright
	orr	r9, r9, r0

skip:   cmp	r9, #0
	blne	switch60

	pop	{r4-r9, lr}
	mov      pc, LR


ballIsCaught:
	push	{lr}
		ldr	r0, =lives
		ldr	r1, [r0]
		add	r1, r1, #1
		str	r1, [r0]

		ldr	r0, =isBallCatchable
		mov	r1, #0
		str	r1, [r0]

		bl	unLaunchBall
	pop	{pc}


enableCatchBall:
	push	{lr}

	ldr	r0, =isBallCatchable
	mov	r1, #1
	str	r1, [r0]

	pop	{pc}


checkIfCaught:
	push	{r4-r8, lr}

	ldr	r0, =isBallCatchable
	ldr	r0, [r0]
	cmp	r0, #1
	bleq	ballIsCaught
	popeq	{r4-r8, pc}

	ldr	r0, =ballSlope
	ldr	r0, [r0]
	cmp	r0, #0
	popeq	{r4-r8, pc}

	ldr	r0, =curX
	ldr	r4, [r0]

	ldr	r0, =paddlePosition
	ldr	r5, [r0]

	add	r6, r4, #32

	ldr	r0, =paddleSize
	ldr	r7, [r0]
	add	r7, r7, r5

	cmp	r6, r5
	bllt	ballDies
	popLT	{r4-r8, pc}

	cmp	r7, r4
	bllt	ballDies
	popLT	{r4-r8, pc}

	@checkRightBound
		sub	r7, r7, #48	
		cmp	r7, r4		
		bllt	switch45Paddle	
		popLT	{r4-r8, pc}

	@checkLeftBound
		add	r5, r5, #48	
		cmp	r6, r5		
		blle	switch45Paddle	
		blGT	switch60Paddle
	pop	{r4-r8, pc}


ballDies:
	push	{r4-r5,lr}

	ldr	r4, =ballSlope
	ldr	r4, [r4]

	cmp	r4, #0
	popeq	{r4-r5,pc}

	ldr	r4, =deadBall
	ldr	r5, [r4]

	cmp	r5, #5
		ADDLT	r5, r5, #1
		strLT	r5, [r4]
		bleq	unLaunchBall

	pop	{r4-r5,pc}


switch60:
	push	{lr}
	ldr	r0, =ballSlope
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



switch45:
	push	{lr}
	ldr	r0, =ballSlope
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


switch60Paddle:
	push	{lr}

	ldr	r0, =curY
	ldr	r0, [r0]

	cmp	r0, #748
		blge	switch45
		popGE	{pc}

	ldr	r0, =ballSlope
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


switch45Paddle:
	push	{lr}

	ldr	r0, =curY
	ldr	r0, [r0]

	cmp	r0, #748
		blge	switch45
		popGE	{pc}

	ldr	r0, =ballSlope
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

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

.global	deadBall

deadBall:		.byte	0

isBallCatchable:	.int	0
