	addi x3, x0, 0xf0
	addi x4, x0, 5
	sw x4, 0(x3)
	lw x6, 0(x3)
	add x7, x6, x4 
loop:   j loop 
