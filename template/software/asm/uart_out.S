	addi x10, zero, 0x48
	nop
	nop
Loop:	sb x10, -4(zero)
	j Loop
	nop
	nop
