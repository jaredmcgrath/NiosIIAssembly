#---------------------------------------------------------------------------
# Factorial Program:
# Input value goes in A, output value will be stored in C
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)			# Read value at offset of A into r2
	call 	Factorial			# Call the Factorial subroutine now that r2 has the value
	stw		r2, B(r0)			# Store the factorial value in memory at offset B

_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Factorial subroutine
#---------------------------------------------------------------------------
Factorial:
	subi	sp, sp, 4
	stw		r16, 0(sp)		# Store value in r16 on stack to use r16 as temp reg
	movi	r16, 1			# Move a value of 1 into r16
	subi	sp, sp, 4		# Reserve one extra word on stack for use as storage
	stw		r2, 0(sp)		# Set reserved word on stack to initial parameter in r2
	bgt		r2, r16, _recurse	# Branch if r2 > 1
	# At this point, just return the initial value after restoring stack
	addi	sp, sp, 4		# Move sp up 4 bytes
	ldw		r16, 0(sp)		# Restore the value to r16 from stack
    addi	sp, sp, 4		# Restore stack to initial position
	ret


_recurse:
	subi	r2, r2, 1		# Subtract 1 from the value
	ldw 	r16, 0(sp)		# Get concurrent value off of the stack
	mul 	r16, r2, r16	# Multiply, store in r16
	stw		r16, 0(sp)		# Overwrite value on stack
	movi	r16, 1			# Move a value of 1 into r16
	bgt		r2, r16, _recurse	# Branch if r2 > 1
	# At this point, r2 has value of 1. Prepare to return
	ldw 	r2, 0(sp)		# Get return value off of the stack
	addi	sp, sp, 4		# Move sp up 4 bytes
	ldw		r16, 0(sp)		# Restore the value to r16 from stack
    addi	sp, sp, 4		# Restore stack to initial position
	ret

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	8				# A is the input for the factorial function
B:	.skip	4				# Reserve 4 bytes in B for the result

	.end					# Indicates end of assembly language source
	