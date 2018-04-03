@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section    .text

.global main
main:
	gBase	.req	r10
	prevbtn	.req	r9

	@ Creator Credits
	ldr	r0, =msgCreator		@ get the creator
	bl	printf

	@ Get GPIO base address
	@ Store in memory for future use
	@ Store base in variable
	bl	initSneS
	bl	Init_Frame


	.global menusetup
	menusetup:
		mov	r4, #0 			@initial state is 0
		mov	r6, #8496		@ initial wait is longer

		mov	r0, r6			@ pause SneS before reading
		bl	readSneS

	    .global startMenuLoop
		startMenuLoop:

		    	cmp 	r4, #0 @check state

	    		mov 	r1, #720
	    		mov 	r2, #960
	    		ldreq	r0, =menuStart		@ state determines the screen
	    		ldrne	r0, =menuQuit	

			bl	drawTile

			mov	r0, r6
			bl	readSneS @check button press
			mov	r6, #3750

				cmp	r0, #2048		@ U
				moveq 	r4, #0
				cmp	r0, #1024		@ D
				moveq	r4, #1
				cmp	r0, #128  		@A

			Bne startMenuLoop

		@branch based on state
		cmp	r4, #0
		Bne	terminate		@ clears the screen to quit
		Beq	makeGame		@ starts the game



.global terminate
terminate:				@ infinite loop ending program
	ldr	r0, =msgTerminate
	bl	printf

	bl blackScreen
	haltLoop$:
		B	haltLoop$

	gBase	.req	r10
	prevbtn	.req	r9

.global pauseMenu
pauseMenu:
		push	{r4-r5, lr}
		mov	r4, #0		@ state
		mov	r5, #16384	@ delay for SneS

		mov	r0, r5
		bl	readSneS		@ pause SneS reading

	pauseMenuLoop:
	   	cmp 	r4, #0 @check state

    		mov 	r1, #200
    		mov 	r2, #200

    		ldreq	r0, =pausedRestart	
    		ldrne	r0, =pausedQuit

		bl	drawCenterTile		@ draws the menu
		mov	r0, r5
		bl	readSneS @check button press
		mov	r5, #2048

			cmp	r0, #2048		@ U
			moveq 	r4, #0

			cmp	r0, #1024		@ D
			moveq	r4, #1

			cmp	r0, #4096		@ Start
			bleq	clearScreen
			moveq	r0, #16384
			bleq	readSneS
			popeq	{r4,r5, pc}

			cmp	r0, #128  		@A
		Bne pauseMenuLoop

		@branch based on state
		cmp	r4, #0		@ restart if equal
		pop	{r4,r5, r0}
		Bne	menusetup	@ returns to menu
		Beq	makeGame	@ restarts the game

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

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data
.align 2

	msgCreator:
		.asciz 			"Authors: Kevin HuynH, Heavenel Cerna and Austin So\n"

	msgTerminate:
		.asciz	 		"Program Terminated\n"

	frameBufferInfo:
		.int 0		@ frame buffer pointer
		.int 0		@ screen width
		.int 0		@ screen height

	.global cWhite
	cWhite:	c1:
		.int	0xFFFFFF

	.global cIndigo
	cIndigo: c2:
		.int 	0x4B0082

	.global cGreen
	cGreen: c3:
		.int	0x00FF00

	.global cYellow
	cYellow:
		.int	0xFFFF00

.global gpioBaseAddress
gpioBaseAddress:
	.int	0
