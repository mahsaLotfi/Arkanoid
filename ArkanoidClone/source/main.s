@ Assignment 4: Arkanoid

@ Authors:  Kevin Huynh	    10162332
@	    Heavenel Cerna  30019914
@	    Austin So	    30021027


@@@@@@@@@@@@@@@@@@@@@@@@@ Code Section @@@@@@@@@@@@@@@@@@@@@@@@@

.section    .text

.global main, start_menu, end_game, pause_menu


main:
	ldr	r0, =authors		@ Print authors
	bl	printf

	bl	init_SNES

	ldr	r0, =frameBufferInfo
	bl	initFbInfo

start_menu:
	mov	r4, #0			@ Initial state is 0
	mov	r6, #8496		@ Initial wait is longer

	mov	r0, r6			@ Pause SNES before reading
	bl	read_SNES

start_menu_wait:
    	cmp 	r4, #0			@ Check state

	mov 	r1, #720
	mov 	r2, #960
	ldreq	r0, =menuStart		@ State determines the screen
	ldrne	r0, =menuQuit	

	bl	draw_cell

	mov	r0, r6
	bl	read_SNES		@ Check button press
	mov	r6, #3750

	cmp	r0, #2048		@ U
	moveq 	r4, #0
	cmp	r0, #1024		@ D
	moveq	r4, #1
	cmp	r0, #128  		@ A

	bne start_menu_wait

	@ Branch based on state
	cmp	r4, #0
	bne	end_game		@ clears the screen to quit
	beq	draw_game		@ starts the game


end_game:				@ infinite loop ending program
	bl blackScreen

haltLoop$:
	b	haltLoop$



pause_menu:
	push	{r4-r5, lr}
	mov	r4, #0			@ state
	mov	r5, #16384		@ delay for SNES

	mov	r0, r5
	bl	read_SNES		@ pause SNES reading

pm_loop:
   	cmp 	r4, #0			@check state

	mov 	r1, #200
	mov 	r2, #200

	ldreq	r0, =pausedRestart	
	ldrne	r0, =pausedQuit

	bl	draw_center_image		@ draws the menu
	mov	r0, r5
	bl	read_SNES		@check button press
	mov	r5, #2048

	cmp	r0, #2048		@ Up
	moveq 	r4, #0

	cmp	r0, #1024		@ Down
	moveq	r4, #1

	cmp	r0, #4096		@ Start button
	bleq	clear_screen
	moveq	r0, #16384
	bleq	read_SNES
	popeq	{r4,r5, pc}

	cmp	r0, #128  		@ A button
	bne	pm_loop

	@branch based on state
	cmp	r4, #0			@ Restart if equal
	pop	{r4,r5, r0}
	bne	start_menu		@ Returns to menu
	beq	draw_game		@ Restarts the game


@ Clears the screen
@ Inputs: None
@ Outputs: None

clear_screen:
	push	{r4,r5, lr}

	mov	r4, #260		@ Start x position of where menu is drawn
	mov	r5, #380		@ Start y position of where meun is drawn

cs_loop:
	mov	r0, r4
    	mov	r1, r5
    	mov	r2, #0
    	bl	drawPx

   	add	r4, r4, #1
    	cmp	r4, #460
    	moveq	r4, #260

    	addeq   r5, r5, #1
   	cmp	r5, #580
        blt	cs_loop

	pop	{r4, r5, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@ Data Section @@@@@@@@@@@@@@@@@@@@@@@@@
.section	.data
.align 2

.global	frameBufferInfo
frameBufferInfo:
	.int 0		@ frame buffer pointer
	.int 0		@ screen width
	.int 0		@ screen height

authors:	.asciz  "Authors: Kevin HuynH, Heavenel Cerna and Austin So\n"

.global gpioBaseAddress
gpioBaseAddress:
	.int	0
