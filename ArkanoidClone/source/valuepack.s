@@@@@@@@@@@@@@@@@@@@@@@@@ Text Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

@ listens for drops
.global dropListener
dropListener:
	push	{r4-r6, lr}
		bl	tryCatchBall
		bl	tryPaddle
	pop	{r4-r6, pc}


@ checks whether paddle drop or catch ball drop is occuring

	tryPaddle:
		push	{lr}

		ldr	r0, =paddleDropState
		ldr	r0, [r0]

		cmp	r0, #1
			bleq	bigPaddleDrop
			blLT	paddleTileBroken
		pop	{pc}

	tryCatchBall:
		push	{lr}

		ldr	r0, =ballDropState
		ldr	r0, [r0]

		cmp	r0, #1
			bleq	catchBallDrop
			blLT	ballTileBroken
		pop	{pc}

@ checks whetehr the brick holding the approrpaite til has been broken

ballTileBroken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =tile26
	LDRB	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =ballDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}



paddleTileBroken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =tile20
	LDRB	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =paddleDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}

@ drops the value pack inrementally
bigPaddleDrop:
	push	{r4-r8, lr}

	mov	r0, #56

	ldr	r1, =paddleDropY
	ldr	r6, [r1]

	@ draws white tile
	mov	r1, r6
	mov	r2, #0xFFFFFF
	mov	r3, #28
	mov	r4, r3
	bl	makeTile

	add	r7, r6, #32
	ldr	r1, =paddleDropY
	str	r7, [r1]

	@ draws signifying value
	mov	r0, #'+'
	mov	r1, #64
	add	r2, r6, #4
	bl	drawChar

	mov	r0, #56
	sub	r1, r6, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	makeTile

	ldr	r0, =paddleDropY
	ldr	r0, [r0]
	mov	r1, #774


	@ if drop is near the bottom check if the paddle caught it
	cmp	r0, r1
	blGE	checkPaddleDrop


	pop	{r4-r8, pc}

@ check whether the paddle drop is caught
checkPaddleDrop:
	push	{lr}

	ldr	r0, =paddleDropState
	mov	r1, #2
	str	r1, [r0]

	@ load paddle position
	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	@ if paddle is 88 from the left
	cmp	r0, #88
	blLE	bigPaddle	@ change paddle to big paddle

	mov	r0, #56
	ldr	r1, =paddleDropY
	ldr	r1, [r1]
	sub	r1, r1, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	makeTile

	pop	{pc}

catchBallDrop:
	push	{r4-r8, lr}

	mov	r0, #428

	ldr	r1, =ballDropY
	ldr	r6, [r1]

	@ create the white tile
	mov	r1, r6
	mov	r2, #0xFFFFFF
	mov	r3, #28
	mov	r4, r3
	bl	makeTile

	add	r7, r6, #32
	ldr	r1, =ballDropY
	str	r7, [r1]

	@ create the signifyuing character
	mov	r0, #'-'
	mov	r1, #434
	add	r2, r6, #4
	bl	drawChar

	mov	r0, #428
	sub	r1, r6, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	makeTile

	ldr	r0, =ballDropY
	ldr	r0, [r0]
	mov	r1, #774


	@ if drop is near the bottom check if the paddle caught it
	cmp	r0, r1
	blGE	checkBallDrop

	pop	{r4-r8, pc}

@ cgecj whether ball drop is caught
checkBallDrop:
	push	{lr}

	ldr	r0, =ballDropState
	mov	r1, #2
	str	r1, [r0]

	@ load paddle position
	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	@ if paddle is 428 from the left
	cmp	r0, #428
	blLE	enableCatchBall	@ change to catch ball
	BGT	tryOtherSide

	checkBallDrop2:
		mov	r0, #428
		ldr	r1, =ballDropY
		ldr	r1, [r1]
		sub	r1, r1, #32
		mov	r2, #0x0
		mov	r3, #28
		mov	r4, r3
		bl	makeTile
		pop	{pc}

	tryOtherSide:
		ldr	r1, =paddleSize
		ldr	r1, [r1]

		add	r0, r0, r1
		cmp	r0, #428
		blGE	enableCatchBall

		B	checkBallDrop2


@ debuging purposes only
.global testPaddle
testPaddle:
	push	{lr}

	ldr	r0, =paddleDropState
	mov	r1, #1
	str	r1, [r0]

	pop	{pc}

.global	testBall
testBall:
	push	{lr}

	ldr	r0, =ballDropState
	mov	r1, #1
	str	r1,[r0]

	pop	{pc}

@ resets the state values for value packs for restarting
.global	resetValuePacks
resetValuePacks:
	ldr	r0, =paddleDropY
	mov	r1, #192
	str	r1, [r0]

	ldr	r0, =ballDropY
	mov	r1, #192
	str	r1, [r0]

	ldr	r0, =paddleDropState
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =ballDropState
	mov	r1, #192
	str	r1, [r0]

	mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

	paddleDropY:		.int    192
	ballDropY:		.int	192


	@ 0 - default
	@ 1 - dropping
	@ 2 - caught/finished
	paddleDropState:	.int	0
	ballDropState:		.int	0
