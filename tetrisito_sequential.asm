.include "macros.asm"

.text
main:	la $a0, start
		jal read_grid
		la $a0, start
		jal freeze_blocks

		la $a0, end
		jal read_grid
		la $a0, end
		jal freeze_blocks
		
		la $t0, n
		system_call(5)
		sw $v0, 0($t0)
		
		la $a0, n
		lw $a0, 0($a0)
		jal read_pieces
		
		la $a0, start
		la $a1, 0
		jal backtrack
		bne $v0, $zero, possible
		print_char(78)
		print_char(79)
		j exit	
		
possible:	print_char(89)
			print_char(69)
			print_char(83)				
exit:	system_call(10)

backtrack:		addi $sp, $sp, -120
				sw $ra, 116($sp)
				sw $s0, 112($sp)
				sw $s1, 108($sp)
				sw $s2, 104($sp)
				sw $s3, 100($sp)
				sw $s4, 96($sp)
				move $s0, $a0
				move $s1, $a1 #index
				move $a0, $s0
				la $a1,  8($sp)
				jal copy_grid
				li $s2, 0		#result
				la $a0, 8($sp)
				la $a1, end
				jal is_equal_grids
				bne $v0, $zero, is_true
				la $t0, n
				lw $t0, 0($t0)
				beq $s1, $t0, done_backtrack
				la $t0, conv_pieces
				sll $t1, $s1, 3
				add $a0, $t0, $t1
				jal max_x
				li $t0, 6
				li $s3, 0
				sub $s4, $t0, $v0
off_loop:		beq $s3, $s4, done_backtrack
				la $a0, 8($sp)
				la $t0, conv_pieces
				sll $t1, $s1, 3
				add $a1, $t0, $t1
				move $a2, $s3
				jal drop_piece
				move $s0, $v0
				beq $v1, $zero, skip_off_iter
				move $a0, $s0
				addi $a1, $s1, 1
				jal backtrack
				bne $v0, $zero, is_true
skip_off_iter:	add $s3, $s3, 1		
				j off_loop			
is_true:		li $s2, 1		
done_backtrack:	move $v0, $s2
				lw $ra, 116($sp)
				lw $s0, 112($sp)
				lw $s1, 108($sp)
				lw $s2, 104($sp)
				lw $s3, 100($sp)
				lw $s4, 96($sp)
				addi $sp, $sp, 120
				jr $ra
				
drop_piece:		addi $sp, $sp, -100
				sw $ra, 96($sp)
				sw $s0, 92($sp)
				sw $s1, 88($sp)
				sw $s2, 84($sp)
				sw $s3, 80($sp)
				move $s0, $a0
				move $s2, $a2
				move $s3, $a1
				move $a1, $sp
				jal copy_grid
				move $a0, $s0
				la $a1, copy
				jal copy_grid
				move $s1, $v0
				li $t0, 0
				li $t1, 4
				li $t2, 35
add_pc_loop:	beq $t0, $t1, down_loop
				lb $t3, 0($s3)
				lb $t4, 1($s3)
				sll $t3, $t3, 3
				add $t3, $t3, $t4
				add $t3, $t3, $s2
				add $t3, $t3, $s1
				sb $t2, 0($t3)
				addi $s3, $s3, 2
				addi $t0, $t0, 1
				j add_pc_loop
down_loop:		bne $zero, $zero, done_drop
				li $t0, 0
				li $t1, 10
				li $t3, 6
				li $t4, 1		#can still go down
				li $t6, 80
				li $t7, 35 					
down_o:			beq $t0, $t1, done_down_o
				li $t2, 0
				sll $t0, $t0 3
down_i:			beq $t2, $t3, done_down_i
				add $t5, $t0, $t2
				add $t5, $t5, $s1
				lb $t5, 0($t5)
				bne $t5, $t7, down_not_hash1
				addi $t5, $t0, 8
				beq $t5, $t6, cannot_go_down
				add $t5, $t5, $t2
				add $t5, $t5, $s1
				lb $t5, 0($t5)
				li $t8, 88
				beq $t5, $t8, cannot_go_down
down_not_hash1:	addi $t2, $t2, 1
				j down_i
done_down_i:	srl $t0, $t0, 3
				addi $t0, $t0, 1
				j down_o
cannot_go_down:	li $t4, 0	
done_down_o:	beq $t4, $zero, done_drop
				li $t0, 71
				li $t3, 35
				li $t4, 46
move_down:		beq $t0, -1, done_move_down
				add $t1, $t0, $s1
				lb $t2, 0($t1)
				bne $t2, $t3, down_not_hash2
				sb $t3, 8($t1)
				sb $t4, 0($t1)
down_not_hash2:	addi $t0, $t0, -1
				j move_down			
done_move_down: j down_loop						
done_drop:		li $t0, 0   
				li $t1, 10
				li $t3, 6
				li $t4, 100				
				li $t6, 35 					
max_yo:			beq $t0, $t1, done_max_yo
				li $t2, 0
				sll $t7, $t0 3
max_yi:			beq $t2, $t3, done_max_yi
				add $t5, $t7, $t2
				add $t5, $t5, $s1
				lb $t5, 0($t5)
				bne $t5, $t6, down_not_hash3
				slt $t5, $t0, $t4
				beq $t5, $zero, down_not_hash3
				move $t4, $t0
down_not_hash3:	addi $t2, $t2, 1
				j max_yi
done_max_yi:	addi $t0, $t0, 1
				j max_yo
done_max_yo:	li $t3, 4
				slt $t0, $t4, $t3
				bne $t0, $zero, invalid
				move $a0, $s1
				jal freeze_blocks
				move $a0, $s1
				jal clear_lines
				li $v1, 1
				j done_drop_pc
invalid:		move $a0, $sp
				la $a1, copy
				jal copy_grid
				li $v1, 0				
done_drop_pc:	lw $ra, 96($sp)
				lw $s0, 92($sp)
				lw $s1, 88($sp)
				lw $s2, 84($sp)
				lw $s3, 80($sp)	
				addi $sp, $sp, 100
				jr $ra	
					
max_x: 		addi $sp, $sp, -4
			sw $ra, 0($sp)
			li $t0, 0
			li $t1, 4
			li $t2, -1
max_x_loop:	beq $t0, $t1, done_max_x
			lb $t3, 1($a0)
			slt $t4, $t2, $t3
			beq $t4, $zero, bigger
			move $t2, $t3
bigger:		addi $a0, $a0, 2
			addi $t0, $t0, 1
			j max_x_loop
done_max_x: move, $v0, $t2
			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
		
piece_to_pairs:	addi $sp, $sp, -4
				sw $ra, 0($sp)
				la $t0, piece
				li $t1, 0
				li $t2, 4
				li $t5, 35
				la $t6, piece_coords
pairs_loop1:	beq $t1, $t2, done_conv
				li $t3, 0
pairs_loop2:	beq $t3, $t2, done_conv1
				add $t4, $t0, $t3
				lb  $t4, 0($t4)
				bne $t4, $t5, pair_not_hash
				sb $t1, 0($t6)
				sb $t3, 1($t6)
				addi $t6, $t6, 2
pair_not_hash:	addi $t3, $t3, 1
				j pairs_loop2
done_conv1:		addi $t0, $t0, 6
				addi $t1, $t1, 1
				j pairs_loop1
done_conv:		lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra
				
				
read_pieces: 	addi $sp, $sp, -28
				sw $ra, 24($sp)
				sw $s0, 20($sp)
				sw $s1, 16($sp)
				sw $s2, 12($sp)
				sw $s3, 8($sp)
				sw $s4, 4($sp)
				sw $s5, 0($sp)
				li $s0, 0
				move $s1, $a0
				li $s3, 4
				la $s4, conv_pieces
read_pc_loop1:	beq $s0, $s1, done_read_pcs
				la $t0, piece
				li $s2, 0
read_pc_loop2:	beq $s2, $s3, done_read_pc
				move $a0, $t0
				li $a1, 6
				system_call(8)
				addi $t0, $t0, 6
				addi $s2, $s2, 1
				j read_pc_loop2	 
done_read_pc:	jal piece_to_pairs
				la $t0, piece_coords
				la $t2, conv_pieces
				sll $t1, $s0, 3
				add $t2, $t2, $t1
				li $s5, 0
pairs_to_list:	beq $s5 , $s3, done_add_pairs
				lb $t1, 0($t0)
				sb $t1, 0($t2)
				lb $t1, 1($t0)
				sb $t1, 1($t2)
				addi $t0, $t0, 2
				addi $t2, $t2, 2
				addi $s5, $s5, 1
				j pairs_to_list 
done_add_pairs: addi $s0, $s0, 1
				j read_pc_loop1			
done_read_pcs:	lw $ra, 24($sp)
				lw $s0, 20($sp)
				lw $s1, 16($sp)
				lw $s2, 12($sp)
				lw $s3, 8($sp)
				lw $s4, 4($sp)
				lw $s5, 0($sp)			
				addi $sp, $sp, 28
				jr $ra
				
				
is_equal_grids: 	addi $sp, $sp, -4
					sw   $ra, 0($sp)
					addi $t0, $zero, 80
					add $t1, $zero, $zero
					li $t4, 1
is_equal_loop:		beq $t1, $t0, end_is_equal
					lb $t2, 0($a0)
					lb $t3, 0($a1)
					beq $t2, $t3, is_equal
					li $t4, 0
					j end_is_equal
is_equal:			addi $a0, $a0, 1
					addi $a1, $a1, 1
					addi $t1, $t1, 1
					j is_equal_loop
end_is_equal:		lw   $ra, 0($sp)
					addi $sp, $sp, 4
					move $v0, $t4
   					jr $ra		
   							
copy_grid: 	addi $sp, $sp, -4
			sw   $ra, 0($sp)
			addi $t0, $zero, 80
			add $t1, $zero, $zero
copy_loop:	beq $t1, $t0, end_copy
			lb $t2, 0($a0)
			sb $t2, 0($a1)
			addi $a0, $a0, 1
			addi $a1, $a1, 1
			addi $t1, $t1, 1
			j copy_loop
end_copy:	addi $v0, $a1, -80
			lw   $ra, 0($sp)
			addi $sp, $sp, 4
   			jr $ra

read_grid:  	addi $sp, $sp, -8
				sw   $ra, 4($sp)
				sw   $s0, 0($sp)
				li $t0, 0
				li $t1, 4
				li, $t3, 6
				li $t4, 0
				li $t5, 46
				li $t6, 10
first_half:	 	beq $t0, $t1, prep_next_half
				li $t2, 0
empty_row:		beq $t2, $t3, add_end
				add $s0, $a0, $t4
				sb  $t5, 0($s0)
				addi $t4, $t4, 1
				addi $t2, $t2, 1
				j empty_row
add_end:  	 	add $s0, $a0, $t4
				sb  $t6, 0($s0)
				addi $t4, $t4, 1
				add $s0, $a0, $t4
				sb  $zero, 0($s0)
				addi $t4, $t4, 1
				addi $t0, $t0, 1
				j first_half
prep_next_half:	li $t0, 0
				add $a0, $a0, $t4
				li $a1, 8
				li $v0, 8
next_half:		beq $t0, $t3, done_read_grid
				syscall
				add $a0, $a0, $a1
				addi $t0, $t0, 1
				j next_half			
done_read_grid: lw   $ra, 4($sp)
				lw   $s0, 0($sp)
				addi $sp, $sp, 8
				jr $ra


print_grid:		addi $sp, $sp, -12
				sw   $ra, 8($sp)
				sw   $t1, 4($sp)
				sw   $t2, 0($sp)
				li $t1, 0
				li $t2, 10
				li $v0, 4
print_loop:		beq $t1, $t2, done_print
				syscall 
				add $a0, $a0, 8
				addi $t1, $t1, 1
				j print_loop
done_print:		print_char(10)
				lw   $ra, 8($sp)
				lw   $t1, 4($sp)
				lw   $t2, 0($sp)
				addi $sp, $sp, 12
				jr $ra
				
freeze_blocks:	addi $sp, $sp, -4
				sw   $ra, 0($sp)
				addi $t0, $zero, 80
				add $t1, $zero, $zero
				li $t3, 35 
				li $t4, 88
freeze_loop:	beq $t1, $t0, end_freeze
				lb $t2, 0($a0)
				bne $t2, $t3, not_hash
				sb $t4, 0($a0)
not_hash:		addi $a0, $a0, 1
				addi $t1, $t1, 1
				j freeze_loop
end_freeze:		lw   $ra, 0($sp)
				addi $sp, $sp, 4
				addi $v0, $a0, -80
   				jr $ra	

clear_line: 	addi $sp, $sp, -4
				sw 	 $ra, 0($sp)
				add $t0, $a1, -1
				addi $t2, $zero, 3
				addi $t3, $zero, 6
shift_rows:		beq $t0, $t2, done_shift
			 	li $t1, 0
			 	sll $t0, $t0, 3
shift_row:	 	beq $t1, $t3, done_row
			 	add $t4, $t0, $t1
			 	add $t4, $t4, $a0
			 	lb $t5, 0($t4)
			 	addi $t4, $t4, 8
			 	sb $t5, 0($t4)
			 	addi $t1, $t1, 1
			 	j shift_row
done_row:		srl $t0, $t0, 3
				addi $t0, $t0, -1
				j shift_rows
done_shift: 	li $t1, 0
				li $t0, 4
			 	sll $t0, $t0, 3
			 	li $t5, 46
add_top:	 	beq $t1, $t3, done_top  #empty row 4
			 	add $t4, $t0, $t1
			 	add $t4, $t4, $a0
			 	sb $t5, 0($t4)
			 	addi $t1, $t1, 1
			 	j add_top
done_top:		lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra
				
clear_lines: 		addi $sp, $sp, -32
					sw $ra, 28($sp)
					sw $s0, 24($sp)
					sw $s1, 20($sp)
					sw $s2, 16($sp)
					sw $s3, 12($sp)
					sw $s4, 8($sp)
					sw $s5, 4($sp)
					move $s0, $a0
					addi $s1, $zero, 9
					addi $s2, $zero, 3
					addi $s4, $zero, 6
					addi $s5, $zero, 88
loop_i_clear:		beq $s1, $s2, done_clear	
					addi $s3, $zero, 0
					sll $s1, $s1, 3
					addi $t0, $zero, 1	
loop_j_clear:  	 	beq $s3, $s4, done_check	#checks if row is full
					add $t1, $s3, $s1
					add $t1, $t1, $s0
					lb  $t1, 0($t1)
					bne $t1, $s5, not_full
					addi $s3, $s3, 1
					j loop_j_clear
not_full: 			add $t0, $zero, $zero
done_check:			beq $t0, $zero, done_shift_rows
					move $a0, $s0
					srl $s1, $s1, 3
					move $a1, $s1
					jal clear_line
					j loop_i_clear
done_shift_rows:	srl $s1, $s1, 3
					addi $s1, $s1, -1
					j loop_i_clear
done_clear: 		move $v0, $s0
					lw $ra, 28($sp)
					lw $s0, 24($sp)
					lw $s1, 20($sp)
					lw $s2, 16($sp)
					lw $s3, 12($sp)
					lw $s4, 8($sp)
					lw $s5, 4($sp)
					addi $sp, $sp, 32
					jr $ra
					
.data
start: .space 80
end: .space 80
copy: .space 80
piece: .space 24
piece_coords: .space 8
n: .space 4
conv_pieces: .space 40


