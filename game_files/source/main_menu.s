@ Main Menu: Drawing and Interaction with SNES controller

@ Is used by: main.s

@ Uses: SNES_controller.s, menu_start.s, menu_quit.s

SNES_controller	.req	r10
menu_start	.req	r11
menu_quit	.req	r12


.global
.align 4

.int 8
.int 8
.int 1024
.int 768

@ Implementation:			Implemented?
@A tile might be rectangle/square with variable colour values.
@Use Image-to-ASCII Java application on D2L:
@Convert a tile to a colour bitmap.
@Generated ascii values are colour values in row-major order.
@Load colour values and store in the framebuffer.
@You need to know width/height of your tile.

@ Draw bkgd, title, authors		N

@ Switch between 2 images		N
@ when pressing up + down

@ Press 'A' selects option		N
	@ Start Game => game		N
	@ Quit Game => clear + exit	N
	
mm:
	ldr r5, =framebufferinfo
	bl initFbinfo
	
	ldr r5, =menu_start		@loadframe buffer with meu_start image
	bl menu_start
	



.global	draw_menu
draw_menu:	



