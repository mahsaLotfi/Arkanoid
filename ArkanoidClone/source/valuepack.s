@@@@@@@@@@@@@@@@@@@@@@@@@ Text Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section	.text

.global	check_drops, reset_value_packs

@ listens for drops
check_drops:
	push	{r4-r6, lr}

	bl	check_catch_ball_drop
	bl	check_paddle_drop

	pop	{r4-r6, pc}


@ checks whether paddle drop or catch ball drop is occuring
check_paddle_drop:
	push	{lr}

	ldr	r0, =paddleDropState
	ldr	r0, [r0]

	cmp	r0, #1
	bleq	paddle_drop_fall
	bllt	check_paddle_brick_broken

	pop	{pc}

check_catch_ball_drop:
	push	{lr}

	ldr	r0, =ballDropState
	ldr	r0, [r0]

	cmp	r0, #1
	bleq	catch_ball_drop_fall
	bllt	check_catch_ball_brick_broken

	pop	{pc}

@ checks whetehr the brick holding the approrpaite til has been broken

check_catch_ball_brick_broken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =brick25
	ldrb	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =ballDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}



check_paddle_brick_broken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =brick20
	ldrb	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =paddleDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}

@ drops the value pack inrementally
paddle_drop_fall:
	push	{r4-r8, lr}

	mov	r0, #56

	ldr	r1, =paddleDropY
	ldr	r6, [r1]

	@ draws white tile
	mov	r1, r6
	mov	r2, #0xFFFFFF
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

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
	bl	drawCell

	ldr	r0, =paddleDropY
	ldr	r0, [r0]
	mov	r1, #774


	@ if drop is near the bottom check if the paddle caught it
	cmp	r0, r1
	blge	paddle_drop_caught


	pop	{r4-r8, pc}

@ check whether the paddle drop is caught
paddle_drop_caught:
	push	{lr}

	ldr	r0, =paddleDropState
	mov	r1, #2
	str	r1, [r0]

	@ load paddle position
	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	@ if paddle is 88 from the left
	cmp	r0, #88
	blle	superPaddle	@ change paddle to big paddle

	mov	r0, #56
	ldr	r1, =paddleDropY
	ldr	r1, [r1]
	sub	r1, r1, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

	pop	{pc}

catch_ball_drop_fall:
	push	{r4-r8, lr}

	mov	r0, #428

	ldr	r1, =ballDropY
	ldr	r6, [r1]

	@ create the white tile
	mov	r1, r6
	mov	r2, #0xFFFFFF
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

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
	bl	drawCell

	ldr	r0, =ballDropY
	ldr	r0, [r0]
	mov	r1, #774


	@ if drop is near the bottom check if the paddle caught it
	cmp	r0, r1
	blge	catch_ball_drop_caught

	pop	{r4-r8, pc}

@ cgecj whether ball drop is caught
catch_ball_drop_caught:
	push	{lr}

	ldr	r0, =ballDropState
	mov	r1, #2
	str	r1, [r0]

	@ load paddle position
	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	@ if paddle is 428 from the left
	cmp	r0, #428
	blle	enableCatchBall	@ change to catch ball
	bgt	tryOtherSide

checkBallDrop2:
	mov	r0, #428
	ldr	r1, =ballDropY
	ldr	r1, [r1]
	sub	r1, r1, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	drawCell
	pop	{pc}

tryOtherSide:
	ldr	r1, =paddleSize
	ldr	r1, [r1]
	add	r0, r0, r1
	cmp	r0, #428
	blge	enableCatchBall

	b	checkBallDrop2

@ resets the state values for value packs for restarting
reset_value_packs:
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
