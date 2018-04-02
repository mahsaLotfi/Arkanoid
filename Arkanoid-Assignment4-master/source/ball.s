
.global drawBall
drawBall:
	PUSH	{r4-r6, lr}
	LDR	r0, =curX
	LDR	r5, [r0]

	LDR	r1, =curY
	LDR	r6, [r1]


	//crosswise
	ADD	r0, r5, #0
	ADD	r1, r6, #4
	MOV	r2, #0x0000FF
	MOV	r3, #32
	MOV	r4, #24
	BL	makeTile

	//lengthwise
	ADD	r0, r5, #4		//x
	ADD	r1, r6, #0		//y
	MOV	r2, #0x000FF
	MOV	r3, #23
	MOV	r4, #32
	BL	makeTile

	POP	{r4-r6, pc}

// no params or return values
.global initBall
initBall:
	PUSH	{r4-r6,lr}
	ADD	r4, r0, #64

	BL	isLaunched
	CMP	r0, #0
	POPNE	{r4-r6, pc}

	LDR	r5, =curX
	STR	r4, [r5]
	BL	drawBall
	BL	getRidOfBall

	POP	{r4-r6, pc}

// removes ball
// no params or return values
.global	getRidOfBall
getRidOfBall:
	PUSH	{r4-r5, lr}

	MOV	r3, #32
	MOV	r4, r3

	LDR	r0, =prevX
	LDR	r0, [r0]
	LDR	r1, =prevY
	LDR	r1, [r1]

	MOV	r2, #0x0
	BL	makeTile

	// update ball location
		LDR	r4, =curX
		LDR	r4, [r4]
		LDR	r5, =prevX
		STR	r4, [r5]

		LDR	r4, =curY
		LDR	r4, [r4]
		LDR	r5, =prevY
		STR	r4, [r5]

	POP	{r4-r5, pc}

// launches the ball
.global launchBall
launchBall:
	PUSH	{r4-r7,lr}

	BL	isLaunched		// if already launched, ignore
	CMP	r0, #1
	POPEQ	{r4-r7,pc}

	LDR	r0, =ballWillDie
	MOV	r1, #0
	STRB	r1, [r0]

	BL	getRidOfBall
	BL	launch

	POP	{r4-r7,pc}

// inner function for launch ball
launch:
	PUSH	{lr}

	LDR	r0, =slopeCode
	MOV	r1, #87	// 60 up right
	STRB	r1, [r0]

	POP	{pc}

.global unlaunch
unlaunch:
	PUSH	{lr}

	LDR	r0, =ballWillDie
	MOV	r1, #1
	STR	r1, [r0]

	LDR	r0, =slopeCode
	MOV	r1, #0
	STR	r1, [r0]

	BL	getRidOfBall

	// decrement life
	LDR	r1, =lifeCount
	LDR	r0, [r1]
	SUB	r0, r0, #1
	STR	r0, [r1]

	// move ball location
	LDR	r0, =curY
	LDR	r1, =prevY
	MOV	r2, #740

	STR	r2, [r0]
	STR	r2, [r1]

	LDR	r0, =paddlePosition
	LDR	r0, [r0]
	ADD	r0, #64

	LDR	r2, =prevX
	STR	r0, [r1]
	SUB	r0, #64

	BL	initBall
	POP	{pc}


// return if ball is launched
.global	isLaunched
isLaunched:
	PUSH	{lr}

	LDR	r0, =slopeCode
	LDR	r0, [r0]

	CMP	r0, #0
	MOVEQ	r0, #0
	MOVNE	r0, #1
	POP	{pc}

.section	.data

	.global	prevX
	prevX:	.int	326

	.global	prevY
	prevY:	.int	740

	.global curX
	curX:	.int	326

	.global curY
	curY:	.int	740


	//  0: unlaunched
	//  9: 45 up right
	//  7: 45 up left
	// 89: 60 up right
	// 87: 60 up left
	//  3: 45 down right
	//  1: 45 down left
	// 23: 60 down right
	// 21: 60 down left
	// hint: these numbers mimic the numpad

	.global slopeCode
	slopeCode:	.int	0
