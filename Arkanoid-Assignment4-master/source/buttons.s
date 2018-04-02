.text

	gBase	.req	r9

// functions \\
.global	initSNES
	initSNES:
		PUSH	{lr}
		BL	getGpioPtr		// load base address
		LDR	r1, =gpioBaseAddress	// load to variable
		STR	r0, [r1]		// store
		LDR	r0, =gpioBaseAddress
		LDR	gBase, [r0]		// load address to register

		MOV	r0, #9			// GPIO9
		MOV	r1, #0b001		// as output
		BL	Init_GPIO		// set

		MOV	r0, #10			// GPIO10
		MOV	r1, #0b000		// as input
		BL	Init_GPIO		// set

		MOV	r0, #11			// GPIO11
		MOV	r1, #0b001		// as output
		BL	Init_GPIO		// set

		POP	{pc}

// params:
// r0 - delay
// returns:
// r0 - code for button pressed

.global readSNES
	readSNES:
		PUSH	{r6-r8, lr}
		btns	.req	r8
		MOV	r6, r0

		MOV	btns, #0		// reset pushed buttons to 0

		MOV	r0, #1
		BL	Write_Clock

		MOV	r0, #1			// set latch
		BL	Write_Latch

		// wait 12microSeconds to signal controller
		MOV	r0, #12
		BL	delayMicroseconds

		MOV	r0, #0			// clear latch
		BL	Write_Latch

		inc	.req	r7
		MOV	inc, #0			// increment

		pulseLoop:
			MOV	r0, r6
			BL	delayMicroseconds

			MOV	r0, #0		// rise edge
			BL	Write_Clock

			MOV	r0, r6
			BL	delayMicroseconds

			BL	Read_Data

			CMP	r0, #0		// is data returned 0?
			LSL	btns, #1	// make space for new bit
			ADDEQ	btns, #0b1	// if so, add 1 (pressed) to btns

			MOV	r0, #1		// fall edge
			BL	Write_Clock

			ADD	inc, #1		// increment
			CMP	inc, #16	// end when greater than/equal to 16
			BLT	pulseLoop

		MOV	r0, btns		// return buttons
		POP	{r6-r8, pc}

	.unreq	inc
	.unreq	btns

// converts to button code
// code is not used but is only for debugging purposes
.global	getButton
	getButton:
		PUSH	{r4,lr}
		notNull	.req	r4

		MOV	notNull, #0	// ensures that the buttons
					// pressed are valid

		// save button pressed to r1
		CMP	r0, #32768	// code for button B
		LDREQ	r1, =msgB1	// if code is b, load string for B
		MOVEQ	notNull, #1	// turn on not null flag

		CMP	r0, #16384	// same goes for the rest of the buttons
		LDREQ	r1, =msgB2
		MOVEQ	notNull, #1

		CMP	r0, #8192
		LDREQ	r1, =msgB3
		MOVEQ	notNull, #1

		CMP	r0, #4096	// code for start
		LDREQ	r1, =msgB4	// pop and go to terminate code
		MOVEQ	notNull, #1

		CMP	r0, #2048
		LDREQ	r1, =msgB5
		MOVEQ	notNull, #1

		CMP	r0, #1024
		LDREQ	r1, =msgB6
		MOVEQ	notNull, #1

		CMP	r0, #512
		LDREQ	r1, =msgB7
		MOVEQ	notNull, #1

		CMP	r0, #256
		LDREQ	r1, =msgB8
		MOVEQ	notNull, #1

		CMP	r0, #128
		LDREQ	r1, =msgB9
		MOVEQ	notNull, #1

		CMP	r0, #64
		LDREQ	r1, =msgB10
		MOVEQ	notNull, #1

		CMP	r0, #32
		LDREQ	r1, =msgB11
		MOVEQ	notNull, #1

		CMP	r0, #16
		LDREQ	r1, =msgB12
		MOVEQ	notNull, #1

		CMP	notNull, #1	// if null string, do not print
		BLEQ	printf

		MOVNE	r0, #59999	// delay to make button printing smoother
		BLNE	delayMicroseconds	// if not printing

		POP	{r4, pc}

		.unreq	notNull

	Init_GPIO:

		// r0: GPIO number
		// r1: function code

		PUSH	{r4, r5, lr}		// store vars in stack

		toAdd	.req	r3		// name r3 immediate scratch value
		fSel	.req	r4		// name r4 function select

		MOV	r2, #0

		initLoop:
			CMP	r0, #9		// r0 is GPIO number
			SUBHI	r0, #10		// loop divides r0 to get GPIOSELn
			ADDHI	r2, #1
			BHI	initLoop
		LSL	toAdd, r2, #2		// toAdd is the increment from gBase


		LDR	fSel, [gBase, toAdd]	// load GPIO to r1

		ADD	r0, r0, lsl #1		// r0 is multiplied to become the pin number
		LSL	r1, r0			// function code is left shifted to pin number

		MOV	r5, #0b111		// set bitmask
		LSL	r5, r0

		BIC	fSel, r5		// bit clear at desired pins
		ORR	fSel, r1		// apply function code
		STR	fSel, [gBase, toAdd]	// store back to gBase

		POP	{r4, r5, pc}
		.unreq	fSel			// unset register names
		.unreq	toAdd



	//GPIO9  - LAT (latch): OUTPUT
	//GPIO10 - DAT (data): INPUT
	//GPIO11 - CLK (clock): OUTPUT

	Write_Latch:
		TEQ	r0, #0			// Clear Register if true
		MOV	r0, #0x200		// latch address
		STREQ	r0, [gBase, #0x28]	// clear latch	// 0x200 = 1 LSL 0x9
		STRNE	r0, [gBase, #0x1C]	// or set latch
		MOV	pc, lr

	Write_Clock:
		TEQ	r0, #0			// Clear Register if true
		MOV	r0, #0x800		// clock address
		STREQ	r0, [gBase, #0x28]
		STRNE	r0, [gBase, #0x1C]	// set/clear clock	0x800 = 1 LSL 0x11
		MOV	pc, lr

	Read_Data:
		LDR	r0, [gBase, #0x34]	// get GPLEV0
		TST	r0, #0x400		// and with GPIO10 (data) bitmask

		MOVNE	r0, #1
		MOVEQ	r0, #0			// equal means bit is 0
		MOV	pc, lr

	.unreq	gBase


.data
	// Buttons
		msgB1:	.asciz		"B\n"
		msgB2:	.asciz		"Y\n"
		msgB3:	.asciz		"Select\n"
		msgB4:	.asciz 		"Start\n"
		msgB5:	.asciz		"Joy-pad UP\n"
		msgB6:	.asciz		"Joy-pad DOWN\n"
		msgB7:	.asciz		"Joy-pad LEFT\n"
		msgB8:	.asciz		"Joy-pad RIGHT\n"
		msgB9:	.asciz		"A\n"
		msgB10:	.asciz		"X\n"
		msgB11:	.asciz		"Left\n"
		msgB12:	.asciz		"Right\n"

