@@@@@@@@@@@@@@@@@@@@@@@@@ Text Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text
.global	check_drops, reset_value_packs

check_drops:
	push	{r4-r6, lr}
	
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

check_paddle_brick_broken:
	push	{r4-r6,lr}

	mov	r5, #1

	ldr	r0, =brick20
	ldrb	r6, [r0]

	cmp	r6, #0
		ldreq	r0, =paddleDropState
		streq	r5, [r0]

	pop	{r4-r6,pc}

@ Moves super paddle drop downward
paddle_drop_fall:
	push	{r4-r8, lr}

	mov	r0, #438

	ldr	r1, =paddleDropY
	ldr	r6, [r1]

	@ Draws super paddle drop tile
	mov	r1, r6
	mov	r2, #0xFF00	
	mov	r3, #16
	mov	r4, #32
	bl	drawCell

	add	r7, r6, #16
	ldr	r1, =paddleDropY
	str	r7, [r1]

	@ Erases tile trace
	mov	r0, #438
	sub	r1, r6, #16
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

	ldr	r0, =paddleDropY
	ldr	r0, [r0]
	mov	r1, #775

	@ Check if tile is caught
	cmp	r0, r1
	blge	paddle_drop_caught

	pop	{r4-r8, pc}

@ check whether the paddle drop is caught
paddle_drop_caught:
	push	{lr}

	ldr	r0, =paddleDropState
	mov	r1, #2
	str	r1, [r0]
	
	ldr	r0, =paddlePosition
	ldr	r0, [r0]

	@ Upgrade paddle into super paddle
	cmp	r0, #470 	
	blle	superPaddle	

	@ Draw super paddle blackout 
	mov	r0, #438
	ldr	r1, =paddleDropY
	ldr	r1, [r1]
	sub	r1, r1, #16
	mov	r2, #0x0
	mov	r3, #28
	mov	r4, r3
	bl	drawCell

	pop	{pc}

@ resets the state values for value packs for restarting
reset_value_packs:
	ldr	r0, =paddleDropY
	mov	r1, #224
	str	r1, [r0]
	
	ldr	r0, =paddleDropState
	mov	r1, #0
	str	r1, [r0]

	mov	pc, lr

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

paddleDropY:		.int    225

@ 0 - default
@ 1 - dropping
@ 2 - caught/finished
paddleDropState:	.int	0
