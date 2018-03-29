@ Drawer

.text
.global Init_Frame
	Init_Frame:
		PUSH	{lr}

		LDR	r0, =frameBufferInfo
		BL	initFbInfo

		POP	{pc}


@ r0 - x_start
@ r1 - y_start
@ r2 - color
@ r3 - length
@ r4 - height

.global make_tile
make_tile:
	length	.req 	r3
	pxl_x_drawn	.req	r6
	offset	.req	r4
	frame	.req	r5
	width	.req	r6
	x_val	.req	r7
	y_val	.req	r8
	color	.req	r9

	PUSH	{r5-r6, lr}
	@ length r3
	height	.req	r4

	LDR	r5, =frameBufferInfo
	LDR	r5, [r5, #4]

	MOV	pxl_x_drawn, #0
	tileLoop:
		BL	draw_HL
		ADD	r0, r0, r5
		SUB	r0, r0, length
		SUB	r0, r0, #1
		ADD	pxl_x_drawn, pxl_x_drawn, #1
		CMP	pxl_x_drawn, height
		BLE	tileLoop

	POP	{r5-r6, pc}

.global draw_pxl

@ r0 - x_start
@ r1 - y_start
@ r2 - color

draw_pxl:
	PUSH	{r3-r9, lr}

	MOV	x_val, r0
	MOV	y_val, r1
	MOV	color, r2

	LDR	frame, =frameBufferInfo
	LDR	width, [frame, #4]

	@ making the offset
	MUL	y_val, width
	ADD	offset, x_val, y_val
	LSL	offset, #2	@ * 4

	LDR	r3, [frame]
	STR	color, [r3, offset]

	POP	{r3-r9, pc}


	.unreq	offset
	.unreq	frame
	.unreq	width
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ r0 - x_start
@ r1 - y_start
@ r2 - color
@ r3 - length

.global draw_HL
draw_HL:
	PUSH	{r6, lr}

	MOV	pxl_x_drawn, #0
	HL_pxl_x_loop:
		BL	draw_pxl
		ADD	r0, r0, #1
		ADD	pxl_x_drawn, pxl_x_drawn, #1
		CMP	pxl_x_drawn, length
		BLE	HL_pxl_x_loop

	POP	{r6, lr}
	MOV	pc, lr

	.unreq	length
	.unreq	height
	.unreq	pxl_x_drawn
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

@ r0 = Character to be drawn
@ r1 = x
@ r2 = y
@ r3 = colour

.global draw_char
draw_char:
	PUSH		{r4-r9, lr}

	char_address	.req	r4
	p_x		.req	r5
	p_y		.req	r6
	row		.req	r7
	mask	.req	r8
    colour	.req	r9

	LDR		char_address, =font		@ load the address of the font map
	ADD		char_address,	r0, lsl #4	@ char address = font base + (char * 16)

	MOV		p_y, r2			@ init the Y coordinate (pixel coordinate)

	LDR		r2 , =initX
	STR		r1, [r2]

	char_loop:
		LDR		p_x, =initX
		LDR		p_x, [p_x]		@ init the X coordinate
		MOV		mask, #0x01		@ set the bitmask to 1 in the LSB
		LDRB		row, [char_address], #1	@ load the row byte, post increment char_address

	row_loop:
		TST		row, mask		@ test row byte against the bitmask
		BEQ		no_pxl

		MOV		r0, p_x
		MOV		r1, p_y
		MOV		r2, colour
		BL		draw_pxl			@ draw pixel at (p_x, p_y)

	no_pxl:
		ADD		p_x, p_x, #1		@ increment x coordinate by 1
		LSL		mask, #1		@ shift bitmask left by 1

		TST		mask,	#0x100		@ test if the bitmask has shifted 8 times (test 9th bit)
		BEQ		row_loop

		ADD		p_y,p_y, #1		@ increment y coordinate by 1

		TST		char_address, #0xF
		BNE		char_loop		@ loop back to char_loop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	char_address
	.unreq	p_x
	.unreq	p_y
	.unreq	row
	.unreq	mask

	POP		{r4-r9, pc}

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    
    
@ r0 - char array address
@ r1 - x
@ r2 - y
@ r3 - color

.global draw_word
draw_word:
	PUSH	{r4-r7, lr}
	MOV	r5, r0
	MOV	r6, r1
	MOV	r7, r2
	MOV	r4, r3
	draw_word_loop:
		LDRB	r0, [r5], #1
		CMP	r0, #0
		POPEQ	{r4-r7, pc}

		MOV	r1, r6
		MOV	r2, r7
		MOV	r3, r4
		BL	draw_char
		ADD	r6, r6, #11
		B	draw_word_loop
        
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        
@ Draws black rectangle
.global draw_black_screen 
draw_black_screen:
	PUSH {r4, r5, lr}
	MOV r4, #0
	MOV r5, #0
draw_black:
    MOV r0, r4
    MOV r1, r5
    MOV r2, #0
    bl	draw_pxl
    
    add	r4, r4, #1
    CMP r4, #720
    MOVEQ	r4, #0
    
    ADDEQ r5, r5, #1
    
    CMP   r5, #960
    BLT draw_black
    
    pop {r4,r5, pc}
	



@ Data section
.section .data

.align 4
font:		.incbin	"font.bin"

initX:		.int 0

.global frameBufferInfo
frameBufferInfo:
	.int	0	@ frame buffer pointer
	.int	0	@ width
	.int	0	@ height
