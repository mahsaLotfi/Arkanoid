


.section    .text

//constants

.global main
main:
	gBase	.req	r10
	prevbtn	.req	r9

	// Creator Credits
	LDR	r0, =msgCreator		// get the creator
	BL	printf

	// Get GPIO base address
	// Store in memory for future use
	// Store base in variable
	BL	initSNES
	BL	Init_Frame


	.global menusetup
	menusetup:
		MOV	r4, #0 			//initial state is 0
		MOV	r6, #8496		// initial wait is longer

		MOV	r0, r6			// pause SNES before reading
		BL	readSNES

	    .global startMenuLoop
		startMenuLoop:

		    	CMP 	r4, #0 //check state

	    		MOV 	r1, #720
	    		MOV 	r2, #960
	    		LDREQ	r0, =menu_start		// state determines the screen
	    		LDRNE	r0, =menu_quit	

			BL	drawTile

			MOV	r0, r6
			BL	readSNES //check button press
			MOV	r6, #3750

				CMP	r0, #2048		// U
				MOVEQ 	r4, #0
				CMP	r0, #1024		// D
				MOVEQ	r4, #1
				CMP	r0, #128  		//A

			BNE startMenuLoop

		//branch based on state
		CMP	r4, #0
		BNE	terminate		// clears the screen to quit
		BEQ	makeGame		// starts the game



.global terminate
terminate:				// infinite loop ending program
	LDR	r0, =msgTerminate
	BL	printf

	BL blackScreen
	haltLoop$:
		B	haltLoop$

	gBase	.req	r10
	prevbtn	.req	r9

// loggers used for debugging purposes only
.global $
$:	PUSH	{r0-r3, lr}
	LDR	r0, =log$
	BL	printf
	POP	{r0-r3, pc}

.global $1
$1:	PUSH	{r0-r3, lr}
	LDR	r0, =log$1
	BL	printf
	POP	{r0-r3, pc}


.global pauseMenu
pauseMenu:
		PUSH	{r4-r5, lr}
		MOV	r4, #0		// state
		MOV	r5, #16384	// delay for SNES

		MOV	r0, r5
		BL	readSNES		// pause SNES reading

	pauseMenuLoop:
	   	CMP 	r4, #0 //check state

    		MOV 	r1, #200
    		MOV 	r2, #200

    		LDREQ	r0, =paused_restart	
    		LDRNE	r0, =paused_quit

		BL	drawCenterTile		// draws the menu
		MOV	r0, r5
		BL	readSNES //check button press
		MOV	r5, #2048

			CMP	r0, #2048		// U
			MOVEQ 	r4, #0

			CMP	r0, #1024		// D
			MOVEQ	r4, #1

			CMP	r0, #4096		// Start
			BLEQ	clearScreen
			MOVEQ	r0, #16384
			BLEQ	readSNES
			POPEQ	{r4,r5, pc}

			CMP	r0, #128  		//A
		BNE pauseMenuLoop

		//branch based on state
		CMP	r4, #0		// restart if equal
		POP	{r4,r5, r0}
		BNE	menusetup	// returns to menu
		BEQ	makeGame	// restarts the game

// no arguments, void
clearScreen:
	PUSH	{r4,r5, lr}

	MOV r4, #260 //start x position of where menu is drawn
	MOV r5, #380 //start y position of where meun is drawn

	clearScreenLoop:
	MOV	r0, r4
    	MOV	r1, r5
    	MOV	r2, #0
    	BL	drawPx

   	ADD	r4, r4, #1
    	CMP	r4, #460
    	MOVEQ	r4, #260

    	ADDEQ   r5, r5, #1
   	CMP	r5, #580
        BLT	clearScreenLoop

	POP	{r4, r5, pc}

.section .data

.align 2

	msgCreator:
		.asciz 			"Created by: Elvin Limpin and Jocelyn Donnelly\n"

	msgTerminate:
		.asciz	 		"Program is terminating...\n"

	log$:
		.asciz			"logger invoked\n"

	log$1:
		.asciz			"brick logger invoked\n"

	.global log
	log:
		.asciz			"log: %d\n"

	frameBufferInfo:
		.int 0		// frame buffer pointer
		.int 0		// screen width
		.int 0		// screen height


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
