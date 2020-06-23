	addi x5, x0, 0
	nop 
	nop
loop:	
	addi x5, x5, 1
	nop 
	nop
	sw x5, 16(x0)
	jal x0, loop
	nop
	nop
	nop
