.global	moveBall
// no arguments or return values
moveBall:
	PUSH	{r4-r5,lr}
	BL	changeSlope

	LDR	r0, =slopeCode
	LDR	r0, [r0]

	CMP	r0, #0		// ignore if not launched
	POPEQ	{r4-r5,pc}

	// slopes going up
	CMP	r0, #9
	MOVEQ	r4, #16
	MOVEQ	r5, #16

	CMP	r0, #7
	MOVEQ	r4, #-16
	MOVEQ	r5, #16

	CMP	r0, #89
	MOVEQ	r4, #8
	MOVEQ	r5, #16

	CMP	r0, #87
	MOVEQ	r4, #-8
	MOVEQ	r5, #16

	// slopes going down
	CMP	r0, #3
	MOVEQ	r4, #16
	MOVEQ	r5, #-16

	CMP	r0, #1
	MOVEQ	r4, #-16
	MOVEQ	r5, #-16

	CMP	r0, #23
	MOVEQ	r4, #8
	MOVEQ	r5, #-16

	CMP	r0, #21
	MOVEQ	r4, #-8
	MOVEQ	r5, #-16

	// move ball here
	LDR	r0, =curX
	LDR	r1, [r0]
	ADD	r1, r1, r4
	STR	r1, [r0]

	LDR	r0, =curY
	LDR	r1, [r0]
	SUB	r1, r1, r5
	STR	r1, [r0]

	BL	getRidOfBall
	BL	drawBall
	POP	{r4-r5,pc}

// key method. Changes the course of the ball
changeSlope:
	PUSH	{r4-r9, lr}

	LDR	r0, =curX
	LDR	r1, [r0]
	MOV	r4, r1

	LDR	r2, =curY
	LDR	r2, [r2]
	MOV	r5, r2

	LDR	r3, =slopeCode
	LDR	r3, [r3]
	MOV	r6, r3

	LDR	r0, =xandy	//for debugging purposes
//	BL	printf

	// check if walls are hit
	CMP	r4,#644
	BLGE	switch45

	CMP	r5, #36
	BLLE	switch60

	CMP	r4, #36
	BLLE	switch45

	CMP	r5, #740		// check if paddle catches the ball
	BLGE	checkIfCaught

	BL	checkCorners		// check if other corners have hit something

	POP	{r4-r9, lr}
	mov      pc, LR

	topleft:
		push 	{lr}
		LDR	r0, =curX //top left corner
		LDR	r0, [r0]

		LDR	r1, =curY
		LDR	r1, [r1]

		BL	hitBrick //returns if hit
	        LDR     r1, =scoreCount
		LDR	r2, [r1]
	        ADD	r2, r2, r0

		STR	r2, [r1]
	POP	{pc}

	topright:
		PUSH 	{lr}
		LDR	r0, =curX //top right corner
		LDR	r0, [r0]
	        ADD	r0, r0, #32

		LDR	r1, =curY
		LDR	r1, [r1]

		BL	hitBrick //returns if hit
        	LDR     r1, =scoreCount
		LDR	r2, [r1]

        	ADD	r2, r2, r0
		STR	r2, [r1]
	POP	{pc}

	bottomleft:
		PUSH 	{lr}
		LDR	r0, =curX //bottom left corner
		LDR	r0, [r0]

		LDR	r1, =curY
		LDR	r1, [r1]
	  	ADD	r1, r1, #32

		BL	hitBrick
	        LDR     r1, =scoreCount
		LDR	r2, [r1]
	        ADD	r2, r2, r0
		STR	r2, [r1]
	POP	{pc}

	bottomright:
		PUSH 	{lr}
		LDR	r0, =curX //bottom right corner
		LDR	r0, [r0]
		ADD	r0, r0, #32

		LDR	r1, =curY
		LDR	r1, [r1]
	  	ADD	r1, r1, #32

		BL	hitBrick
	        LDR     r1, =scoreCount
		LDR	r2, [r1]
	        ADD	r2, r2, r0
		STR	r2, [r1]
	POP	{pc}

//Does not take or return arguments
checkCorners: //makes function calls to avoid checking the same brick
	PUSH	{r4-r9, lr}

	BL topleft //check this corner initally
	//r9 keeps track of if the ball should change direction
	MOV 	r9, r0

	LDR	r4, =curX //r4 is x
	LDR	r4, [r4]

	LDR	r5, =curY //r5 is y
	LDR	r5, [r5]

	MOV	r0, r4
	MOV	r1, r5
	BL	XYtoCode
	MOV	r6, r0 //r6 is top left x (till bottom right)
	MOV	r7, r1 //r7 is top left y (till bottom right)

	MOV	r0, r4
	ADD	r1,r5, #32 //bottom left
	BL	XYtoCode

	CMP	r1, r7
	BLNE	bottomleft //calls bottom left if different tile from top left
	ORRNE	r9, r9, r0

	ADD	r0, r4, #32
	MOV	r1, r5
	BL	XYtoCode

	CMP 	r6, r0
	MOV	r6, r0 //store thes values for next check
	MOV	r7, r1
	BLNE	topright //if top right and top left are different check hits
	ORRNE	r9, r9, r0

	//this section deals with bottom right, top right and bottom left affect this
	ADD	r0, r4, #32
	ADD	r1, r5, #32 //bottom right
	BL	XYtoCode
	CMP 	r0, r6
	BEQ	skip

	MOV	r6, r0
	MOV	r7, r1

        //check top right
	ADD	r0, r4, #32
	MOV	r1, r5
	BL	XYtoCode

	CMP	r1, r7
	BEQ	skip

	BL	bottomright
	ORR	r9, r9, r0

	//label if bottom right doesn't need to be checked
skip:   CMP	r9, #0
	BLNE	switch60

	POP	{r4-r9, lr}
	mov      pc, LR


// functions associated with the value pack \\

// paddle catches ball as effect of value pack
ballIsCaught:
	PUSH	{lr}
		LDR	r0, =lifeCount
		LDR	r1, [r0]
		ADD	r1, r1, #1
		STR	r1, [r0]

		LDR	r0, =willCatchBall
		MOV	r1, #0
		STR	r1, [r0]

		BL	unlaunch
	POP	{pc}


.global	enableCatchBall
enableCatchBall:
	PUSH	{lr}

	LDR	r0, =willCatchBall
	MOV	r1, #1
	STR	r1, [r0]

	POP	{pc}

//////////////////////////////////////////////////


checkIfCaught:
	PUSH	{r4-r8, lr}

	LDR	r0, =willCatchBall	// check if ball will be caught
	LDR	r0, [r0]
	CMP	r0, #1
	BLEQ	ballIsCaught
	POPEQ	{r4-r8, pc}

	LDR	r0, =slopeCode		// check if ball is launched
	LDR	r0, [r0]
	CMP	r0, #0
	POPEQ	{r4-r8, pc}

	LDR	r0, =curX	// leftbound of ball
	LDR	r4, [r0]

	LDR	r0, =paddlePosition
	LDR	r5, [r0]	// leftbound of paddle

	ADD	r6, r4, #32	// rightbound of ball

	LDR	r0, =paddleSize
	LDR	r7, [r0]
	ADD	r7, r7, r5	// rightbound of paddle

	CMP	r6, r5		// R ball - L paddle
	BLLT	ballDies	// if ball too far right, ball will die
	POPLT	{r4-r8, pc}

	CMP	r7, r4		// R paddle - L ball
	BLLT	ballDies	// if paddle too far right, ball will die
	POPLT	{r4-r8, pc}

	//checkRightBound
		SUB	r7, r7, #48	//edge of paddle
		CMP	r7, r4		// edge of paddle - L ball
		BLLT	switch45Paddle	// bounce 45
		POPLT	{r4-r8, pc}

	//checkLeftBound
		ADD	r5, r5, #48	// edge of paddle
		CMP	r6, r5		// R ball - edge of paddle
		BLLE	switch45Paddle	// bounce 45
		BLGT	switch60Paddle
	POP	{r4-r8, pc}

// unlaunch ball once below the paddle
ballDies:
	PUSH	{r4-r5,lr}

	LDR	r4, =slopeCode
	LDR	r4, [r4]

	CMP	r4, #0
	POPEQ	{r4-r5,pc}

	LDR	r4, =ballWillDie
	LDR	r5, [r4]

	CMP	r5, #5
		ADDLT	r5, r5, #1
		STRLT	r5, [r4]
		BLEQ	unlaunch

	POP	{r4-r5,pc}

// switch the ball's trajectory to 60 degrees
switch60:
	PUSH	{lr}
	LDR	r0, =slopeCode
	LDR	r1, [r0]

	CMP	r1, #9
	MOVEQ	r2, #23

	CMP	r1, #89
	MOVEQ	r2, #23

	CMP	r1, #87
	MOVEQ	r2, #21

	CMP	r1, #7
	MOVEQ	r2, #21

	CMP	r1, #21
	MOVEQ	r2, #87

	CMP	r1, #1
	MOVEQ	r2, #87

	CMP	r1, #3
	MOVEQ	r2, #89

	CMP	r1, #23
	MOVEQ	r2, #89

	CMP	r1, #0
	MOVEQ	r2, #0

	STR	r2, [r0]

	POP	{pc}


// switch the ball's trajectory to 45 degrees
switch45:
	PUSH	{lr}
	LDR	r0, =slopeCode
	LDR	r1, [r0]

	CMP	r1, #9
	MOVEQ	r2, #7

	CMP	r1, #89
	MOVEQ	r2, #7

	CMP	r1, #87
	MOVEQ	r2, #9

	CMP	r1, #7
	MOVEQ	r2, #9

	CMP	r1, #21
	MOVEQ	r2, #3

	CMP	r1, #1
	MOVEQ	r2, #3

	CMP	r1, #3
	MOVEQ	r2, #1

	CMP	r1, #23
	MOVEQ	r2, #1

	STR	r2, [r0]
	POP	{pc}

// switch the ball's trajectory to 60 degrees
// that the paddle causes
switch60Paddle:
	PUSH	{lr}

	LDR	r0, =curY
	LDR	r0, [r0]

	CMP	r0, #748
		BLGE	switch45
		POPGE	{pc}

	LDR	r0, =slopeCode
	LDR	r1, [r0]
	MOV	r2, r1

	CMP	r1, #1
	MOVEQ	r2, #87

	CMP	r1, #21
	MOVEQ	r2, #87

	CMP	r1, #3
	MOVEQ	r2, #89

	CMP	r1, #23
	MOVEQ	r2, #89

	STR	r2, [r0]
	POP	{pc}

// switch the ball's trajectory to 45 degrees
// when caused by the paddle
switch45Paddle:
	PUSH	{lr}

	LDR	r0, =curY
	LDR	r0, [r0]

	CMP	r0, #748
		BLGE	switch45
		POPGE	{pc}

	LDR	r0, =slopeCode
	LDR	r1, [r0]
	MOV	r2, r1

	CMP	r1, #1
	MOVEQ	r2, #7

	CMP	r1, #21
	MOVEQ	r2, #7

	CMP	r1, #3
	MOVEQ	r2, #9

	CMP	r1, #23
	MOVEQ	r2, #9

	STR	r2, [r0]
	POP	{pc}


.section	.data


	illegalSlope:	.asciz	"here"
	xandy:		.asciz	"x: %d y: %d slope: %d\n"

	ballAndPaddle:	.asciz	"ball: %d, paddle: %d\n"

	.global	ballWillDie
	ballWillDie:	.byte	0

	willCatchBall:	.int	0
