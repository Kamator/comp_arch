		.text
		.align 2
		.globl _start

_start: 
		addi x19, x19, 23 ;0
		addi x10, x10, 12 ;4
Loop:		beq x19, x10, End ;8
		add x18, x18, x10 ;C
		addi x19, x19, -1 ;10
		j Loop   	  ;14
End:		addi x5, x5, 1    ;18
		nop		  ;1C
		nop		  ;20
		
		.end End
		.size _start, .-End
