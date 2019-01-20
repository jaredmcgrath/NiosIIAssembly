#---------------------------------------------------------------------------
# This program demonstrates arithmetic, memory access, and subroutines.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
    ldw		r2, A(r0)		# Read value of A from memory into r2
    ldw		r3, B(r0)		# Read value of B from memory into r3
    call 	AddValues		# Call subroutine with parameters in r2 and r3
    stw		r2, C(r0)		# Write return value in r2 to C in memory
    
_end:
	br		_end			# Infinite loop once program execution completes
    

AddValues:
	subi	sp, sp, 4		# Adjust stack pointer down to reserve space
    stw		r16, 0(sp)		# Save value of r16 on stack to use as a temp
    add		r16, r2, r3		# Add r2 and r3, store in r16
    mov		r2, r16			# Move result in r16 to r2, the return register
    ldw		r16, 0(sp)		# Restore the value to r16 from stack
    addi	sp, sp, 4		# Restore stack to initial position
    ret						# Return to calling routine, result is stored in r2


	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	7				# Specify initial value of 7 in A
B:	.word	6				# Specify initial value of 6 in B
C:	.skip	4				# Reserve 4 bytes (1 32-bit word) for the result
							# To be stored in C

	.end					# Indicates end of assembly language source
	