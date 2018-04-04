
@@@@@@@@@@@@@@@@@@@@@@@@@ Text Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text
.global	check_drops, reset_value_packs

check_drops:
	push	{r4-r6, lr}

	bl	check_catch_ball_drop
	bl	check_paddle_drop

	pop	{r4-r6, pc}


@ Super paddle value pack drop checker
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

check_catch_ball_brick_broken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =brick28
	ldrb	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =ballDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}


check_paddle_brick_broken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =brick28
	ldrb	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =paddleDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}


@ Moves super paddle drop downward
paddle_drop_fall:
	push	{r4-r8, lr}

	mov	r0, #182

	ldr	r1, =paddleDropY
	ldr	r6, [r1]

	@ Draws super paddle drop tile
	mov	r1, r6
	mov	r2, #0x0000FF
	mov	r3, #64
	mov	r4, #16
	bl	drawCell

	add	r7, r6, #16
	ldr	r1, =paddleDropY
	str	r7, [r1]

	@ Erases tile trace
	mov	r0, #182
	sub	r1, r6, #32
	mov	r2, #0x0
	mov	r3, #64
	mov	r4, #32
	bl	drawCell

	ldr	r0, =paddleDropY
	ldr	r0, [r0]
	mov	r1, #774


	@ Check if tile is caught
	cmp	r0, r1
	blge	paddle_drop_caught

	pop	{r4-r8, pc}


paddle_drop_caught:
	push	{lr}

	ldr	r0, =paddleDropState
	mov	r1, #2
	str	r1, [r0]

	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	ldr	r1, =paddleSize
	ldr	r1, [r1]
	
	add	r1, r0

	cmp	r1, #182	
	bllt	paddle_destroy
	
	cmp	r0, #246
	blgt	paddle_destroy
	
	bl	superPaddle

paddle_destroy:
	mov	r0, #182
	ldr	r1, =paddleDropY
	ldr	r1, [r1]
	sub	r1, r1, #32
	mov	r2, #0x0
	mov	r3, #64
	mov	r4, #32
	bl	drawCell

	pop	{pc}

catch_ball_drop_fall:
	push	{r4-r8, lr}

	mov	r0, #578

	ldr	r1, =ballDropY
	ldr	r6, [r1]

	@ create the white tile
	mov	r1, r6
	mov	r2, #0xFFFFFF
	mov	r3, #28
	mov	r4, #28
	bl	drawCell

	add	r7, r6, #32
	ldr	r1, =ballDropY
	str	r7, [r1]

	mov	r0, #578
	sub	r1, r6, #32
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

	ldr	r0, =ballDropY
	ldr	r0, [r0]
	mov	r1, #774

	cmp	r0, r1
	blge	catch_ball_drop_caught

	pop	{r4-r8, pc}

catch_ball_drop_caught:
	push	{r6, lr}

	ldr	r0, =ballDropState
	mov	r1, #2
	str	r1, [r0]

	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	ldr	r1, =paddleSize
	ldr	r1, [r1]
	
	add	r1, r0

	mov	r6, #578
	cmp	r1, r6	
	bllt	ball_destroy
	
	mov	r6, #606
	cmp	r0, r6	
	blgt	ball_destroy
	
	bl	enableCatchBall

ball_destroy:
	mov	r0, #578
	ldr	r1, =ballDropY
	ldr	r1, [r1]
	sub	r1, r1, #32
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, #32
	bl	drawCell

	pop	{r6, pc}

@ resets the state values for value packs for restarting
reset_value_packs:
	ldr	r0, =paddleDropY
	mov	r1, #170
	str	r1, [r0]

	ldr	r0, =ballDropY
	mov	r1, #192
	str	r1, [r0]

	ldr	r0, =paddleDropState
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =ballDropState
	mov	r1, #0
	str	r1, [r0]

	mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

paddleDropY:		.int    170
ballDropY:		.int	192

@ 0 - default
@ 1 - dropping
@ 2 - caught/finished
paddleDropState:	.int	0
ballDropState:		.int	0

