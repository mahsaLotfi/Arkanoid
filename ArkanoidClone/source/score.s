@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.text

.global initScore, initLives, updateStats, GAME_OVER, GAME_WIN, resetScore


initScore:
	push	{lr}

	@ r0 - character
	@ r1 - x
	@ r2 - y
	@ r3 - color

	ldr	r0, =scoreChar
	mov	r1, #60
	mov	r2, #55
	ldr	r3, =0xFFFFFF
	bl	drawWord
	pop	{pc}


initLives:
	push	{lr}

	@ r0 - character
	@ r1 - x
	@ r2 - y
	@ r3 - color

	ldr	r0, =livesChar
	mov	r1, #550
	mov	r2, #55
	ldr	r3, =0xFFFFFF
	bl	drawWord
	pop	{pc}


updateStats:
	push	{r4, lr}

	@ black out positions
	mov	r0, #135
	mov	r1, #54
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	mov	r0, #625
	mov	r1, #54
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	@ write digits

	ldr	r0, =score
	bl	toString	@ r0 - first digit
	mov	r4, r1		@ r1 - second digit

		mov	r1, #140
		mov	r2, #55
		bl	drawChar

		mov	r0, r4
		mov	r1, #151
		mov	r2, #55
		bl	drawChar

	ldr	r0, =lives
	bl	toString	@ r0 - first digit
	mov	r4, r1		@ r1 - second digit

		mov	r1, #630
		mov	r2, #55
		bl	drawChar

		mov	r0, r4
		mov	r1, #641
		mov	r2, #55
		bl	drawChar

		bl	initLives
		bl	initScore

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
		bge	divideLoop

	add	r1, r0, #48	@ r1 - second digit, r0 is first
	add	r0, r4, #48	@converts to ascii version

	pop	{r4, r5, pc}

@ behavior for when score is 0
GAME_OVER:
	bl	updateStats
        bl	clearPaddle
	bl	clearBall

	ldr	r0,=gameOver
        mov	r1, #720
	mov	r2, #960
	bl      drawCenterTile
	b	anybutton

@ behavior for win condition
GAME_WIN:
	bl	updateStats

	ldr	r0,=gameWonImage
    mov	r1, #720
	mov	r2, #960
	bl      drawCenterTile
	b	anybutton


@ reinitializes game vairables
resetScore:
	push	{lr}

	ldr	r0, =score
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =lives
	mov	r1, #3
	str	r1, [r0]

	ldr	r0, =ballSlope
	mov	r1, #0
	str	r1, [r0]

	ldr	r0, =preX
	mov	r1, #354
	str	r1, [r0]

	ldr	r0, =curX
	str	r1, [r0]

	ldr	r0, =preY
	mov	r1, #740
	str	r1, [r0]

	ldr	r0, =curY
	str	r1, [r0]


	bl	reset_value_packs
	pop	{pc}


@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data

scoreChar:	.asciz		"SCORE: "
livesChar:	.asciz		"LIVES: "

.global score, lives
score:	.int	0
lives:	.int	3
