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
.int 720
.int 960

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
	mov r0, #100
	mov r1, #100
	
	ldr r2, =menu_start		@loadframe buffer with menu_start image
	bl draw_menu
	
halt:
	b halt


.global	draw_menu
draw_menu:	
	push	{r4, r5)
	
	offset	.req	r4
	ldr	r5, =frameBufferInfo
	
	ldr	r3, [r5,#4]
	mul	r1, r3
	add	offset, r0, r1
	
	lsl 	offset, #2
	
	ldr	r0,[r5]
	str	r2,[r0, offset]
	
	pop	{r4, r5}
	bx	lr	

.section .data

.align
.global frameBufferInfo

framebufferInfo:
 .int	0
 .int	720
 .int	960
	
	
	
	
	
	
	
