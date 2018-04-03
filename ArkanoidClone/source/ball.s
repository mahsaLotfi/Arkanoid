@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

.global drawBall
drawBall:
	push	{r4-r6, lr}
	ldr	r0, =curX
	ldr	r5, [r0]

	ldr	r1, =curY
	ldr	r6, [r1]


	@crosswise
	add	r0, r5, #0
	add	r1, r6, #4
	mov	r2, #0x0000FF
	mov	r3, #32
	mov	r4, #24
	bl	drawCell

	@lengthwise
	add	r0, r5, #4		@x
	add	r1, r6, #0		@y
	mov	r2, #0x000FF
	mov	r3, #23
	mov	r4, #32
	bl	drawCell

	pop	{r4-r6, pc}

@ no params or return values
.global initBall
initBall:
	push	{r4-r6,lr}
	add	r4, r0, #64

	bl	isLaunched
	cmp	r0, #0
	popne	{r4-r6, pc}

	ldr	r5, =curX
	str	r4, [r5]
	bl	drawBall
	bl	getRidOfBall

	pop	{r4-r6, pc}

@ removes ball
@ no params or return values
.global	getRidOfBall
getRidOfBall:
	push	{r4-r5, lr}

	mov	r3, #32
	mov	r4, r3

	ldr	r0, =prevX
	ldr	r0, [r0]
	ldr	r1, =prevY
	ldr	r1, [r1]

	mov	r2, #0x0
	bl	drawCell

	@ update ball location
		ldr	r4, =curX
		ldr	r4, [r4]
		ldr	r5, =prevX
		str	r4, [r5]

		ldr	r4, =curY
		ldr	r4, [r4]
		ldr	r5, =prevY
		str	r4, [r5]

	pop	{r4-r5, pc}

@ launches the ball
.global launchBall
launchBall:
	push	{r4-r7,lr}

	bl	isLaunched		@ if already launched, ignore
	cmp	r0, #1
	popeq	{r4-r7,pc}

	ldr	r0, =ballWillDie
	mov	r1, #0
	strB	r1, [r0]

	bl	getRidOfBall
	bl	launch

	pop	{r4-r7,pc}

@ inner function for launch ball
launch:
	push	{lr}

	ldr	r0, =slopeCode
	mov	r1, #87	@ 60 up right
	strB	r1, [r0]

	pop	{pc}

.global unlaunch
unlaunch:
	push	{lr}

	ldr	r0, =ballWillDie
	mov	r1, #1
	str	r1, [r0]

	ldr	r0, =slopeCode
	mov	r1, #0
	str	r1, [r0]

	bl	getRidOfBall

	@ decrement life
	ldr	r1, =lives
	ldr	r0, [r1]
	sub	r0, r0, #1
	str	r0, [r1]

	@ move ball location
	ldr	r0, =curY
	ldr	r1, =prevY
	mov	r2, #740

	str	r2, [r0]
	str	r2, [r1]

	ldr	r0, =paddlePosition
	ldr	r0, [r0]
	add	r0, #64

	ldr	r2, =prevX
	str	r0, [r1]
	sub	r0, #64

	bl	initBall
	pop	{pc}


@ return if ball is launched
.global	isLaunched
isLaunched:
	push	{lr}

	ldr	r0, =slopeCode
	ldr	r0, [r0]

	cmp	r0, #0
	moveq	r0, #0
	movne	r0, #1
	pop	{pc}

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

	.global	prevX
	prevX:	.int	326

	.global	prevY
	prevY:	.int	740

	.global curX
	curX:	.int	326

	.global curY
	curY:	.int	740


	@  0: unlaunched
	@  9: 45 up right
	@  7: 45 up left
	@ 89: 60 up right
	@ 87: 60 up left
	@  3: 45 down right
	@  1: 45 down left
	@ 23: 60 down right
	@ 21: 60 down left
	@ hint: these numbers mimic the numpad

	.global slopeCode
	slopeCode:	.int	0
