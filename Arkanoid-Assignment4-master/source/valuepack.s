.section	.text

// listens for drops
.global dropListener
dropListener:
	PUSH	{r4-r6, lr}
		BL	tryCatchBall
		BL	tryPaddle
	POP	{r4-r6, pc}


// checks whether paddle drop or catch ball drop is occuring

	tryPaddle:
		PUSH	{lr}

		LDR	r0, =paddleDropState
		LDR	r0, [r0]

		CMP	r0, #1
			BLEQ	bigPaddleDrop
			BLLT	paddleTileBroken
		POP	{pc}

	tryCatchBall:
		PUSH	{lr}

		LDR	r0, =ballDropState
		LDR	r0, [r0]

		CMP	r0, #1
			BLEQ	catchBallDrop
			BLLT	ballTileBroken
		POP	{pc}

// checks whetehr the brick holding the approrpaite til has been broken

ballTileBroken:
	PUSH	{r4-r6,lr}

	MOV	r5, #1

	LDR	r0, =tile26
	LDRB	r6, [r0]

	CMP	r6, #0
		LDREQ	r0, =ballDropState
		STREQ	r5, [r0]

	POP	{r4-r6,pc}



paddleTileBroken:
	PUSH	{r4-r6,lr}

	MOV	r5, #1

	LDR	r0, =tile20
	LDRB	r6, [r0]

	CMP	r6, #0
		LDREQ	r0, =paddleDropState
		STREQ	r5, [r0]

	POP	{r4-r6,pc}

// drops the value pack inrementally
bigPaddleDrop:
	PUSH	{r4-r8, lr}

	MOV	r0, #56

	LDR	r1, =paddleDropY
	LDR	r6, [r1]

	// draws white tile
	MOV	r1, r6
	MOV	r2, #0xFFFFFF
	MOV	r3, #28
	MOV	r4, r3
	BL	makeTile

	ADD	r7, r6, #32
	LDR	r1, =paddleDropY
	STR	r7, [r1]

	// draws signifying value
	MOV	r0, #'+'
	MOV	r1, #64
	ADD	r2, r6, #4
	BL	drawChar

	MOV	r0, #56
	SUB	r1, r6, #32
	MOV	r2, #0x0
	MOV	r3, #28
	MOV	r4, r3
	BL	makeTile

	LDR	r0, =paddleDropY
	LDR	r0, [r0]
	MOV	r1, #774


	// if drop is near the bottom check if the paddle caught it
	CMP	r0, r1
	BLGE	checkPaddleDrop


	POP	{r4-r8, pc}

// check whether the paddle drop is caught
checkPaddleDrop:
	PUSH	{lr}

	LDR	r0, =paddleDropState
	MOV	r1, #2
	STR	r1, [r0]

	// load paddle position
	LDR	r0, =paddlePosition
	LDR	r0, [r0]

	// if paddle is 88 from the left
	CMP	r0, #88
	BLLE	bigPaddle	// change paddle to big paddle

	MOV	r0, #56
	LDR	r1, =paddleDropY
	LDR	r1, [r1]
	SUB	r1, r1, #32
	MOV	r2, #0x0
	MOV	r3, #28
	MOV	r4, r3
	BL	makeTile

	POP	{pc}

catchBallDrop:
	PUSH	{r4-r8, lr}

	MOV	r0, #428

	LDR	r1, =ballDropY
	LDR	r6, [r1]

	// create the white tile
	MOV	r1, r6
	MOV	r2, #0xFFFFFF
	MOV	r3, #28
	MOV	r4, r3
	BL	makeTile

	ADD	r7, r6, #32
	LDR	r1, =ballDropY
	STR	r7, [r1]

	// create the signifyuing character
	MOV	r0, #'-'
	MOV	r1, #434
	ADD	r2, r6, #4
	BL	drawChar

	MOV	r0, #428
	SUB	r1, r6, #32
	MOV	r2, #0x0
	MOV	r3, #28
	MOV	r4, r3
	BL	makeTile

	LDR	r0, =ballDropY
	LDR	r0, [r0]
	MOV	r1, #774


	// if drop is near the bottom check if the paddle caught it
	CMP	r0, r1
	BLGE	checkBallDrop

	POP	{r4-r8, pc}

// cgecj whether ball drop is caught
checkBallDrop:
	PUSH	{lr}

	LDR	r0, =ballDropState
	MOV	r1, #2
	STR	r1, [r0]

	// load paddle position
	LDR	r0, =paddlePosition
	LDR	r0, [r0]

	// if paddle is 428 from the left
	CMP	r0, #428
	BLLE	enableCatchBall	// change to catch ball
	BGT	tryOtherSide

	checkBallDrop2:
		MOV	r0, #428
		LDR	r1, =ballDropY
		LDR	r1, [r1]
		SUB	r1, r1, #32
		MOV	r2, #0x0
		MOV	r3, #28
		MOV	r4, r3
		BL	makeTile
		POP	{pc}

	tryOtherSide:
		LDR	r1, =paddleSize
		LDR	r1, [r1]

		ADD	r0, r0, r1
		CMP	r0, #428
		BLGE	enableCatchBall

		B	checkBallDrop2


// debuging purposes only
.global testPaddle
testPaddle:
	PUSH	{lr}

	LDR	r0, =paddleDropState
	MOV	r1, #1
	STR	r1, [r0]

	POP	{pc}

.global	testBall
testBall:
	PUSH	{lr}

	LDR	r0, =ballDropState
	MOV	r1, #1
	STR	r1,[r0]

	POP	{pc}

// resets the state values for value packs for restarting
.global	resetValuePacks
resetValuePacks:
	LDR	r0, =paddleDropY
	MOV	r1, #192
	STR	r1, [r0]

	LDR	r0, =ballDropY
	MOV	r1, #192
	STR	r1, [r0]

	LDR	r0, =paddleDropState
	MOV	r1, #0
	STR	r1, [r0]

	LDR	r0, =ballDropState
	MOV	r1, #192
	STR	r1, [r0]

	MOV	pc, lr

.section	.data

	paddleDropY:		.int    192
	ballDropY:		.int	192


	// 0 - default
	// 1 - dropping
	// 2 - caught/finished
	paddleDropState:	.int	0
	ballDropState:		.int	0
