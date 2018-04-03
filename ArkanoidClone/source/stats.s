@ Game stats

.section	.text


.global initScore, initLives, updateStats, toString

@ Initiates score
@ r0 - character
@ r1 - x
@ r2 - y
@ r3 - color

initScore:
	ldr	r0, =scoreChar
	mov	r1, #88
	mov	r2, #864
	ldr	r3, =cWhite
	bl	drawWord
	
	mov	pc, lr


@ Initiates lives
@ r0 - character
@ r1 - x
@ r2 - y
@ r3 - color

initLives:
	ldr	r0, =livesChar
	mov	r1, #468
	mov	r2, #864
	ldr	r3, =cWhite
	bl	drawWord
	
	mov	pc, lr


@ Update score and lives

updateStats:
	push	{r4, lr}

	@ Erases the current score
	mov	r0, #160
	mov	r1, #863
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	@ Erases the current lives
	mov	r0, #544
	mov	r1, #863
	mov	r2, #0x0
	mov	r3, #32
	mov	r4, r3
	bl	drawCell

	@ Draws updated score and lives
	@ r0 - First digit
	@ r1 - Second digit

	@ Score
	ldr	r0, =score
	bl	toString
	mov	r4, r1

	mov	r1, #165
	mov	r2, #864
	bl	drawChar

	mov	r0, r4
	mov	r1, #176
	mov	r2, #864
	bl	drawChar

	@ Lives
	ldr	r0, =lives
	bl	toString		
	mov	r4, r1			

	mov	r1, #545
	mov	r2, #864
	bl	drawChar

	mov	r0, r4
	mov	r1, #556
	mov	r2, #864
	bl	drawChar
		
	pop	{r4, pc}


@ Changes the score and lives number to string from integer
@ r0 - location of the integer
@ returns r0 (string code)

<<<<<<< HEAD
toString:
=======
toString:	
	push	{r4, r5, lr}
>>>>>>> 2b9ca46483da8d0dbaf32a836322059f5b13b958
	ldr	r0, [r0]
	mov	r2, #0
	
@ Calculates the number's first and second digit
calcDigits:
	cmp	r0, #10
	blt	convertASCII
	addge	r2, r2, #1
	subge	r0, #10
	
	b	calcDigits

@ Converts to ASCII
convertASCII:
	add	r1, r0, #48		@ r1 - Second digit
	add	r0, r2, #48		@ r0 - First digit

	pop	{r4, r5, pc}



@@@@@-----Data-----@@@@@

.section	.data

scoreChar:	.asciz		"SCORE: "
livesChar:	.asciz		"LIVES: "

.global	score, lives
	
score:	.int	0
lives:	.int	3
