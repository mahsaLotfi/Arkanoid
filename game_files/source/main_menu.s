@ Main Menu: Drawing and Interaction with SNES controller

@ Is used by: main.s

@ Uses: SNES_controller.s, menu_start.s, menu_quit.s

SNES_controller	.req	r10
menu_start	.req	r11
menu_quit	.req	r12

.global
.aling 4

.int 8
.int 8
.int 1024
.int 768

@ Implementation:			Implemented?

mm:
	ldr r5, =framebufferinfo
	bl initFbinfo
@ Draw bkgd, title, authors		N

@ Switch between 2 images		N
@ when pressing up + down

@ Press 'A' selects option		N
	@ Start Game => game		N
	@ Quit Game => clear + exit	N


.global	draw_menu
draw_menu:	
