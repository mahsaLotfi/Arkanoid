@ Assignment 4: Arkanoid
@ Authors by Kevin Huynh, Heavenel Cerna, and Austin So

@ ##### - Check function call
@ ***** - add values

@ Code Section 
.section	.text
.global	main

	game_state	.req	r9

main:
	BL	init_SNES				@ Store base in variable
	
	ldr	r0, =frameBufferInfo	@ Initialize frame buffer
	bl	initFbInfo

	mov	game_state, #0			@ Initial state is 0

start_menu:	
	bl	mm						@ Print out main menu screen and wait for input (1, 2)
	cmp	r0, #2					@ 1 = Start Game, 2 = Quit Game

	beq	quit					@ If 2, then quit game

@ Draw the background map
draw_map:
	bl				@ Draws the background image #####
	
	bl				@ Draws the edges of the background #####
	
init_objects:
	@ Initialize paddle
	ldr	r0, =paddle_coords
	mov	r1, #			@ Paddle: x coord *****
	str	r1, [r0]		@ Store paddle x coord
	mov	r2, #			@ Paddle: y coord *****
	str	r2, [r0, #4]		@ Store paddle y coord
	
	@ Initialize ball
	ldr	r0, =ball_coords
	mov	r1, #			@ Ball: x coord *****
	str	r1, [r0]		@ Store ball x coord
	mov	r2, #			@ Ball: y coord *****
	str	r2, [r0, #4]		@ Store ball y coord
	
	ldr	r0, =ball_momentum
	mov	r1, #0			@ 0 = right/up/45, 1 = left/down/60
	str	r1, [r0]		@ Store ball x direction
	str	r1, [r0, #4]		@ Store ball y direction
	str	r1, [r0, #8]		@ Store ball angle
	
	@ Initialize the bricks
	ldr	r0, =brick_coords	@ 
	
	@ Draw objects
	bl	brick01			@ ???
	

quit:
	bl	close_game		@ Close current game screen and prints black screen #####
	
	haltLoop$:
		b	haltLoop$
	
@ Data Section 	
.section	.data
.align 2

.global GPIO_base_address
GPIO_base_address:
	.int	0

paddle_coords:	
	.int	0, 0		@ x, y
ball_coords:	
	.int	0, 0		@ x, y
ball_momentum:	
	.int	0, 0, 0		@ x_dir, y_dir, angle(45/60)

@ 0 - , 1 - , 2 - , 3 - , 4 - 
brick_coords:	
	.int	0,0,0,0,0,0,1,1,1,1,1,1,2,2,2,2,2,2,3,3,3,3,3,3,4,4,4,4,4,4
