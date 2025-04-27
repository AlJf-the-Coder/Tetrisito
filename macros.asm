.macro system_call(%n)
	li $v0, %n
	syscall
.end_macro 

.macro print_char(%n)
	li $a0, %n
	system_call(11)
.end_macro 
