	addi x3, x0, 0xf0 ; 00
	addi x4, x0, 5 ; 04
	sw x4, 0(x3) ; 08
	lw x6, 0(x3) ; 0C
	add x7, x6, x4 ; 10
loop:   j loop ; 14
	nop ; 18
	nop ; 1C
