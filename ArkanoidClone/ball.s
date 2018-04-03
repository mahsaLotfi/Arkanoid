@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text
.global drawBall, initBall, clearBall, launchBall, unLaunchBall, isBallLaunched

@ Draws the ball
drawBall:
	push	{r4-r6, lr}
	ldr	r0, =curX
	ldr	r5, [r0]

	ldr	r1, =curY
	ldr	r6, [r1]

	add	r0, r5, #0
	add	r1, r6, #4
	mov	r2, #0xFFFF
	mov	r3, #32
	mov	r4, #24
	bl	drawCell

	add	r0, r5, #4	
	add	r1, r6, #0	
	mov	r2, #0xFFFF
	mov	r3, #23
	mov	r4, #32
	bl	drawCell

	pop	{r4-r6, pc}


@ Initializes ball
initBall:
	push	{r4-r6,lr}

	ldr	r6, =paddleSize
	ldr	r6, [r6]

	cmp	r6, #200

	addlt	r4, r0, #46
	addge	r4, r0, #90
	
	bl	isBallLaunched
	cmp	r0, #0
	popne	{r4-r6, pc}

	ldr	r5, =curX
	str	r4, [r5]

	bl	clearBall
	bl	drawBall

	pop	{r4-r6, pc}


@ Argument: None
@ Return: None
clearBall:
	push	{r4-r5, lr}

	ldr	r0, =preX
	ldr	r0, [r0]
	ldr	r1, =preY
	ldr	r1, [r1]

	mov	r2, #0x0

	mov	r3, #32
	mov	r4, r3

	bl	drawCell

	@ update ball location
		ldr	r4, =curX
		ldr	r4, [r4]
		ldr	r5, =preX
		str	r4, [r5]

		ldr	r4, =curY
		ldr	r4, [r4]
		ldr	r5, =preY
		str	r4, [r5]

	pop	{r4-r5, pc}


@ Argument: None
@ Return: None
launchBall:
	push	{r4-r7,lr}

	bl	isBallLaunched	
	cmp	r0, #1
	popeq	{r4-r7,pc}

	ldr	r0, =deadBall
	mov	r1, #0
	strB	r1, [r0]

	bl	clearBall
	bl	launch

	pop	{r4-r7,pc}

	launch:
		push	{lr}

		ldr	r0, =ballSlope
		mov	r1, #87
		strB	r1, [r0]

		pop	{pc}


unLaunchBall:
	push	{lr}

	ldr	r0, =deadBall
	mov	r1, #1
	str	r1, [r0]

	ldr	r0, =ballSlope
	mov	r1, #0
	str	r1, [r0]

	bl	clearBall

	@ decrement life
	ldr	r1, =lives
	ldr	r0, [r1]
	sub	r0, r0, #1
	str	r0, [r1]

	@ move ball location
	ldr	r0, =curY
	ldr	r1, =preY
	mov	r2, #740

	str	r2, [r0]
	str	r2, [r1]

	ldr	r0, =paddlePosition
	ldr	r0, [r0]
	add	r0, #64

	ldr	r2, =preX
	str	r0, [r1]
	sub	r0, #64

	bl	initBall
	pop	{pc}


@ Argument: None
@ Return: Ball Launch state
isBallLaunched:
	push	{lr}

	ldr	r0, =ballSlope
	ldr	r0, [r0]

	cmp	r0, #0
	moveq	r0, #0
	movne	r0, #1
	pop	{pc}


@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

.global	preX, preY, curX, curY

preX:	.int	326
preY:	.int	740
curX:	.int	326
curY:	.int	740

@@@@@@@@ SLOPE CODE @@@@@@@
@  0: unLaunched
@  9: 45 degrees up-right
@ 89: 60 degrees up-right
@  7: 45 degrees up-left
@ 87: 60 degrees up-left
@  3: 45 degrees down-right
@  1: 45 degrees down-left
@ 23: 60 degrees down-right
@ 21: 60 degrees down-left
@@@@@@@@@@@@@@@@@@@@@@@@@@@
.global ballSlope
ballSlope:	.int	0
