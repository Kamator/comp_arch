		.text
		.align 2
		.globl _start

_start: 
		addi x19, x19, 23
		addi x10, x10, 12
Loop:		beq x19, x10, End
		add x18, x18, x10
		addi x19, x19, -1 
		j Loop   	  
End:		addi x5, x5, 1    
		nop		  
		nop		  
		
		.end End
		.size _start, 
		.-End
