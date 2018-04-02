@ Assignment 4: Arkanoid
@ Authors: Kevin Huynh, Heavenel Cerna, and Austin So

@ Code Section
.section    .text

.global main
main:

	@ Print Authors
	ldr	r0, =msgAuthor	
	bl	printf

	@ Get GPIO base address
	@ Store in memory for future use
	@ Store base in variable
	bl	initSNES
	bl	Init_Frame


	.global menusetup
	menusetup:
		mov	r4, #0 			@initial state is 0
		mov	r6, #8496		@ initial wait is longer

		mov	r0, r6			@ pause SNES before reading
		bl	readSNES

	    .global startMenuLoop
		startMenuLoop:

		    	cmp 	r4, #0 @check state

	    		mov 	r1, #720
	    		mov 	r2, #960
	    		ldreq	r0, =startselect		@ state determines the screen
	    		ldrne	r0, =quitselect

			bl	drawTile

			mov	r0, r6
			bl	readSNES @check button press
			mov	r6, #3750

				cmp	r0, #2048		@ U
				moveq 	r4, #0
				cmp	r0, #1024		@ D
				moveq	r4, #1
				cmp	r0, #128  		@A

			bne startMenuLoop

		@branch based on state
		cmp	r4, #0
		bne	terminate		@ clears the screen to quit
		beq	makeGame		@ starts the game



.global terminate
terminate:				@ infinite loop ending program
	ldr	r0, =msgTerminate
	bl	printf

	bl blackScreen
	haltLoop$:
		b	haltLoop$

@ loggers used for debugging purposes only
.global $
$:	push	{r0-r3, lr}
	ldr	r0, =msgAuthor
	bl	printf
	pop	{r0-r3, pc}

.global $1
$1:	push	{r0-r3, lr}
	ldr	r0, =loggerBrick
	bl	printf
	pop	{r0-r3, pc}


.global pauseMenu
pauseMenu:
		push	{r4-r5, lr}
		mov	r4, #0		@ state
		mov	r5, #16384	@ delay for SNES

		mov	r0, r5
		bl	readSNES		@ pause SNES reading

	pauseMenuLoop:
	   	cmp 	r4, #0 @check state

    		mov 	r1, #200
    		mov 	r2, #200

    		ldreq	r0, =pauserestart
    		ldrne	r0, =pausequit

		bl	drawCenterTile		@ draws the menu
		mov	r0, r5
		bl	readSNES @check button press
		mov	r5, #2048

			cmp	r0, #2048		@ U
			moveq 	r4, #0

			cmp	r0, #1024		@ D
			moveq	r4, #1

			cmp	r0, #4096		@ Start
			bleq	clearScreen
			moveq	r0, #16384
			bleq	readSNES
			popeq	{r4,r5, pc}

			cmp	r0, #128  		@A
		bne pauseMenuLoop

		@branch based on state
		cmp	r4, #0		@ restart if equal
		pop	{r4,r5, r0}
		bne	menusetup	@ returns to menu
		beq	makeGame	@ restarts the game

@ no arguments, void
clearScreen:
	push	{r4,r5, lr}

	mov r4, #260 @start x position of where menu is drawn
	mov r5, #380 @start y position of where meun is drawn

	clearScreenLoop:
	mov	r0, r4
    	mov	r1, r5
    	mov	r2, #0
    	bl	drawPx

   	add	r4, r4, #1
    	cmp	r4, #460
    	moveq	r4, #260

    	addeq   r5, r5, #1
   	cmp	r5, #580
        blt	clearScreenLoop

	pop	{r4, r5, pc}

@ Data Section
.section .data
.align 2

	@ GPIO Base Address
	.global gpioBaseAddress
	gpioBaseAddress:
		.int	0

	@ Frame Buffer Information
	frameBufferInfo:
		.int 0		@ Frame buffer pointer
		.int 0		@ Screen width
		.int 0		@ Screen height


	@ Color values
	.global cWhite, cIndigo, cGreen, cYellow,
	cWhite:	c1:
		.int	0xFFFFFF

	cGreen: c3:
		.int	0x00FF00

	cYellow:
		.int	0xFFFF00

	cIndigo: c2:
	.int 	0x4B0082

	msgAuthor:
		.asciz 			"Authors: Kevin Huynh, Heavenel Cerna, and Austin So\n"

	msgTerminate:
		.asciz	 		"Program is terminating...\n"

	loggerBrick:
		.asciz			"Brick logger initialized\n"

	.global logger
	logger:
		.asciz			"logger: %d\n"
