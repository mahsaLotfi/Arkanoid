
@ Main Menu: Drawing and Interaction with SNES controller

@ Is used by: main.s

@ Uses: SNES_controller.s, menu_start.s

.global	start_menu

@ Implementation:			Implemented?
@ Draw bkgd, title, authors		N

@ Switch between 2 images		N
@ when pressing up + down

@ Press 'A' selects option		N
	@ Start Game => game		N
	@ Quit Game => clear + exit	N
	
start_menu:
	push	{r4-r10, lr}

	ldr	r0, =100000		@ Delay 0.1s
	bl	delayMicroseconds

	@ Draw 
	mov	r0, #100
	mov	r1, #100
	ldr	r2, =main_start		@ loadframe buffer with menu_start image
	bl	draw
	
	
	
	pop	{r4-r10, fp, pc}
	

.section .data

.align	4
.global	main_start
main_start:
	.word	mainmenu, 
