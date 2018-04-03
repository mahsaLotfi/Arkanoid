@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

.global initScore
initScore:
	push	{lr}

	@ r0 - character
	@ r1 - intial x
	@ r2 - y
	@ r3 - color

	ldr	r0, =scoreChar
	mov	r1, #88
	mov	r2, #864
	ldr	r3, =cWhite
	bl	drawWord
	pop	{pc}

.global	initLives
initLives:
	push	{lr}

	@ r0 - character
	@ r1 - intial x
	@ r2 - y
	@ r3 - color

	ldr	r0, =livesChar
	mov	r1, #468
	mov	r2, #864
	ldr	r3, =cWhite
	bl	drawWord
	pop	{pc}


.global	updateStats
updateStats:
	push	{r4, lr}

	@ black out positions
	mov	r0, #160
	mov	r1, #863
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	mov	r0, #544
	mov	r1, #863
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	@ write digits

	ldr	r0, =score
	bl	toString	@ r0 - first digit
	mov	r4, r1		@ r1 - second digit

		mov	r1, #165
		mov	r2, #864
		bl	drawChar

		mov	r0, r4
		mov	r1, #176
		mov	r2, #864
		bl	drawChar

	ldr	r0, =lives
	bl	toString	@ r0 - first digit
	mov	r4, r1		@ r1 - second digit

		mov	r1, #545
		mov	r2, #864
		bl	drawChar

		mov	r0, r4
		mov	r1, #556
		mov	r2, #864
		bl	drawChar
	pop	{r4, pc}

@ changes intger to string for printing
@ params: r0 - location of the integer
@ returns: r0 - string code
toString:
	push	{r4, r5, lr}
	ldr	r0, [r0]

	mov	r4, #0
	divideLoop:
		cmp	r0, #10
		ADDGE	r4, r4, #1
		SUBGE	r0, #10
		BGE	divideLoop

	add	r1, r0, #48	@ r1 - second digit, r0 is first
	add	r0, r4, #48	@converts to ascii version

	pop	{r4, r5, pc}

@ behavior for when score is 0
.global LOST
LOST:
	bl	updateStats
        bl	clearPaddle
	bl	getRidOfBall

	ldr	r0,=gameOver
        mov	r1, #200
	mov	r2, #200
	bl      drawCenterTile
	B	anybutton

@ behavior for win condition
.global WIN
WIN:
	bl	updateStats

	ldr	r0,=gameWonImage
        mov	r1, #200
	mov	r2, #200
	bl      drawCenterTile
	B	anybutton


@ reiniitializes game vairables
.global	resetScore
resetScore:
	push	{lr}

	ldr	r0, =score
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =lives
	mov	r1, #3
	str	r1, [r0]

	ldr	r0, =slopeCode
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =prevX
	mov	r1, #326
	str	r1, [r0]

	ldr	r0, =curX
	str	r1, [r0]

	ldr	r0, =prevY
	mov	r1, #740
	str	r1, [r0]

	ldr	r0, =curY
	str	r1, [r0]


	bl	resetValuePacks
	pop	{pc}

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data
	scoreChar:	.asciz		"SCORE: "
	livesChar:	.asciz		"LIVES: "

	.global score
	score:	.int	12

	.global	lives
	lives:	.int	3
