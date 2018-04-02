@ Assignment 4: Arkanoid
@ Authors by Kevin Huynh, Heavenel Cerna, and Austin So

@ ##### - Check function call
@ ***** - add values

@ Code Section 
.section	.text
.global	main

	game_state	.req	r9

main:
	BL	GPIO_init				@ Store base in variable
	
	ldr	r0, =frameBufferInfo	@ Initialize frame buffer
	bl	initFbInfo

	mov	game_state, #0			@ Initial state is 0

m_menu:
	ldr	r0, =10000		@ Delay 0.01s
	bl	delayMicroseconds

	bl	start_menu		@ Initialize main menu screen #####
	cmp	r0, #2			@ Returns: 1 = Start Game, 2 = Quit Game

	beq	quit					@ If 2, then quit game

@ Draw the background map
draw_map:
	bl				@ Draws the background image #####
	
	bl				@ Draws the edges of the background #####
	
init_objects:
	bl	init_paddle		@ Initialize paddle
	
	bl	init_ball		@ Initialize ball
	
	bl	init_bricks		@ Initialize the bricks
	
	@ Draw objects
	
	

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

@ The initialized map
@ 0 - Boundary blocks
@ 1 - Empty space
@ 2 - Brick
@ 3 - Brick
@ 4 - Brick
@ 5 - Brick
@ 6 - Brick
@ 7 - Paddle
@ 8 - Paddle edge
@ 9 - Ball

init_map:
	.int	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,2,2,2,2,2,2,2,2,1,2,2,2,2,2,2,2,2,1,1,0
	.int	0,1,1,3,3,3,3,3,3,3,3,1,3,3,3,3,3,3,3,3,1,1,0
	.int	0,1,1,4,4,4,4,4,4,4,4,1,4,4,4,4,4,4,4,4,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,9,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,8,7,8,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	.int	0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
	
	