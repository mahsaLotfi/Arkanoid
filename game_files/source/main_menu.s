@ Main Menu: Drawing and Interaction with SNES controller

@ Is used by: main.s

@ Uses: SNES_controller.s, menu_start.s, menu_quit.s

@ Implementation:			Implemented?

@ Draw bkgd, title, authors		N

@ Switch between 2 images		N
@ when pressing up + down

@ Press 'A' selects option		N
	@ Start Game => game		N
	@ Quit Game => clear + exit	N


.global	draw_menu
draw_menu:	