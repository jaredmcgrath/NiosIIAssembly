#---------------------------------------------------------------------------
# Project Euler 001
# Find the sum of all the multiples of 3 or 5 below 1000.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2,	A(r0)		# Get the limit val
	call FindSum
	stw		r2, B(r0)		# Store final result in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main program subroutine
# Approach: 
# First, sum all multiples of 3
# Then, add all multiples of 5 that are not multiples of 3
# Then return that result in r2
#---------------------------------------------------------------------------

FindSum:					# Finds sum of all multiples of 3 OR 5 less than 1000, store result in r2
	subi	sp, sp, 12		# Reserve 3 words (12 bytes) on stack
	stw		ra, 8(sp)		# Save return address to stack
	stw		r3, 4(sp)		# Store r3 on stack (To be used as counter/modulo operand)
	stw		r16, 0(sp)		# Store r16 on stack (To be used as max val, the initial param)
	movi	r3, 1			# Initialize counter at 1
	mov		r16, r2			# Move the max from r2 to r16
	mov		r2, r0			# Initialize sum at 0
	br		_sum3			# Start with summing multiples of 3

_prepfornext3:
	ldw		r3, 0(sp)		# Restore r3 from stack
	ldw		r2, 4(sp)		# Restore r2 from stack
	addi	sp, sp, 8		# Free stack
	addi	r3, r3, 1		# Increment counter
	bge		r3, r16, _moveto5	# If we've reached 1000, go to prep for sum5

_sum3:
	subi	sp, sp, 8		# Reserve 2 words (8 bytes) on stack
	stw		r2, 4(sp)		# Store r2 on stack
	stw		r3, 0(sp)		# Store r3 on stack
	mov		r2, r3			# Move r3 to r2
	movi	r3, 3			# Move value 3 to r3
	call Mod				# Do r2 % r3
	bne		r2, r0, _prepfornext3	# If not a multiple of 3, prep for next
	ldw		r3, 0(sp)		# Put current counter val back in r3
	ldw		r2, 4(sp)		# Put running sum back in r2
	addi	sp, sp, 8		# Free stack
	add		r2, r2, r3		# Update running sum
	addi	r3, r3, 1		# Increment counter
	blt		r3, r16, _sum3	# Loop while r3 < r16

_moveto5:
	movi	r3, 1			# Reset counter to 1
	br		_sum5			# Start summing multiples of 5

_prepfornext5:
	ldw		r3, 0(sp)		# Restore r3 from stack
	ldw		r2, 4(sp)		# Restore r2 from stack
	addi	sp, sp, 8		# Free stack
	addi	r3, r3, 1		# Increment counter
	bge		r3, r16, _finish	# If we've reached 1000, finish

_sum5:
	subi	sp, sp, 8		# Reserve 2 words (8 bytes) on stack
	stw		r2, 4(sp)		# Store r2 on stack
	stw		r3, 0(sp)		# Store r3 on stack
	mov		r2, r3			# Move r3 to r2
	movi	r3, 5			# Move value 5 to r3
	call Mod				# Do r2 % r3
	bne		r2, r0, _prepfornext5	# If not a multiple of 5, prep for next
	ldw		r2, 0(sp)		# Put current counter val back in r2
	movi	r3, 3			# Put 3 in r3
	call Mod				# Do r2 % r3
	beq		r2, r0, _prepfornext5	# If it is a multiple of 3, prep for next
	ldw		r3, 0(sp)		# Restore r3 from stack
	ldw		r2, 4(sp)		# Restore r2 from stack
	addi	sp, sp, 8		# Free stack
	add		r2, r2, r3		# Update running sum
	addi	r3, r3, 1		# Increment counter
	blt		r3, r16, _sum5	# Loop while r3 < r16

_finish:
	ldw		r16, 0(sp)		# Restore r16
	ldw		r3, 4(sp)		# Restore r3
	ldw		ra, 8(sp)		# Restore ra
	addi	sp, sp, 12		# Free stack
	ret

#---------------------------------------------------------------------------
# Modulo subroutine
#---------------------------------------------------------------------------

Mod:						# Computes r2 <- r2 % r3, assumes positive integers
	bge		r2, r3, _sub	# If r2 >= r3, continue subtraction
	ret

_sub:
	sub		r2, r2, r3
	br 		Mod

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	1000			# 1000 is the limit
B:	.skip	4				# Skip 4 bytes to reserve a return location

	.end					# Indicates end of assembly language source
	