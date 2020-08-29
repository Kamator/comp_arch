#include "util.h"

int main() {
	int i,k;

	puts("Hello, MiRiscV");
	
	//C-Strings (char *) end with '\0'
	
	/*
 *		Put-String, calls function putstring(const char *s) and  
 *		puts the character '\n' afterwards
 * 	*/

	/*
 *	putstring(const char *s)
 *	
 *
 * 	*/

	for (k = 0; k < 10; k++) {
		//delay loop 
		for (i = 0; i < 3000000; i++) {
			__asm__("");
		}
		//sign of life 
		putchar('0'+k);
	} 
	putchar('\n');

	return 0;
}
