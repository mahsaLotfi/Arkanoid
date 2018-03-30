@ Assignment 4: Arkanoid
@ Authors by Kevin Huynh, Heavenel Cerna, and Austin So

.text

.global main
main:
		ldr	r0, =frameBufferInfo
		bl	initFbInfo

start_menu:	bl	main_menu
		cmp	r0, #1

		