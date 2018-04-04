@ Assignment 4: Arkanoid

@ Authors:  Kevin Huynh	    10162332
@	    Heavenel Cerna  
@	    Austin So	    


@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section    .text

.global main, start_menu, terminate, pause_menu


main:
	gBase	.req	r10
	prevbtn	.req	r9

	ldr	r0, =authors		@ Print authors
	bl	printf

	bl	initSNES

	ldr	r0, =frameBufferInfo
	bl	initFbInfo

start_menu:
	mov	r4, #0			@ Initial state is 0
	mov	r6, #8496		@ Initial wait is longer

	mov	r0, r6			@ Pause SNES before reading
	bl	readSNES

start_menu_wait:
    	cmp 	r4, #0			@ Check state

	mov 	r1, #720
	mov 	r2, #960
	ldreq	r0, =menuStart		@ State determines the screen
	ldrne	r0, =menuQuit	

	bl	drawTile

	mov	r0, r6
	bl	readSNES		@ Check button press
	mov	r6, #3750

	cmp	r0, #2048		@ U
	moveq 	r4, #0
	cmp	r0, #1024		@ D
	moveq	r4, #1
	cmp	r0, #128  		@ A

	bne start_menu_wait

	@ Branch based on state
	cmp	r4, #0
	bne	terminate		@ clears the screen to quit
	beq	makeGame		@ starts the game


terminate:				@ infinite loop ending program
	ldr	r0, =msgTerminate
	bl	printf

	bl blackScreen
haltLoop$:
	b	haltLoop$

	gBase	.req	r10
	prevbtn	.req	r9



pause_menu:
	push	{r4-r5, lr}
	mov	r4, #0		@ state
	mov	r5, #16384	@ delay for SneS

	mov	r0, r5
	bl	readSNES		@ pause SneS reading

pauseMenuLoop:
   	cmp 	r4, #0 @check state

	mov 	r1, #200
	mov 	r2, #200

	ldreq	r0, =pausedRestart	
	ldrne	r0, =pausedQuit

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
	bne	start_menu	@ returns to menu
	beq	makeGame	@ restarts the game

@ Clears the screen
@ 
@ 

clearScreen:
	push	{r4,r5, lr}

	mov	r4, #260 @start x position of where menu is drawn
	mov	r5, #380 @start y position of where meun is drawn

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

frameBufferInfo:
	.int 0		@ frame buffer pointer
	.int 0		@ screen width
	.int 0		@ screen height

	authors:	.asciz  "Authors: Kevin HuynH, Heavenel Cerna and Austin So\n"
	msgTerminate:	.asciz	"Program Terminated\n"


.global white, indigo, green, yellow

white:	c1:
	.int	0xFFFFFF

indigo:	c2:
	.int 	0x4B0082

green:	c3:
	.int	0x00FF00

yellow:
	.int	0xFFFF00


.global gpioBaseAddress

gpioBaseAddress:
	.int	0
