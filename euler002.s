#---------------------------------------------------------------------------
# Project Euler 002
# By considering the terms in the Fibonacci sequence whose values do not exceed four million, find the sum of the even-valued terms.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Load our max value
	call	EvenFibSum
	stw		r2, B(r0)		# Store result in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main program subroutine
# Approach: 
# Use the stack! Last two fib values will be placed on stack
# Then, sum them, retain the larger fib value, and push the sum
# To check if the new fib number is even, nor with 0xFFFFFFFE.
# If result is 0, num is odd
#---------------------------------------------------------------------------

EvenFibSum:
	subi	sp, sp, 20		# Reserve 5 words (20 bytes) on stack
	stw		r16, 16(sp)		# Store any val in r16 on stack
	stw		r3, 12(sp)		# Store any val in r3 on stack
	stw		r4, 8(sp)		# Store any val in r4 on stack
	mov		r16, r2			# r16 <- r2 (save our limit in r16 for convenience)
	movi	r3, 1			# Put 1 in r3
	mov		r2, r0			# Initialize sum at 0 (sum stored in r2)
	stw		r3, 4(sp)		# Store first fib value on stack
	stw		r3, 0(sp)		# Store second fib value on stack
_popsum:
	ldw		r3, 0(sp)		# Load one fib val from stack (fib n-1)
	ldw		r4, 4(sp)		# Load second fib val from stack (fib n-2)
	add		r4, r3, r4		# r4 <- r3 + r4	(fib n)
	bgt		r4, r16, _finish	# If new fib val exceeds r16, finish
	stw		r3, 4(sp)		# Put old fib val on stack (at higher index in memory) (fib n-1)
	stw		r4, 0(sp)		# Put new fib val on stack (at stack pointer) (fib n)
	movi	r3, 0xFFFFFFFE	# Prep for even check
	nor		r3, r3, r4		# r3 <- ~(r3|r4)
	beq		r3, r0, _popsum	# If number is odd, go to next
	add		r2, r2, r4		# Update sum
	br		_popsum			# Continue loop
_finish:
	ldw		r4, 8(sp)		# Restore value to r4
	ldw		r3, 12(sp)		# Restore value to r3
	ldw		r16, 16(sp)		# Restore value to r16
	addi	sp, sp, 20		# Free stack
	ret

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	4000000			# The limit Fibonacci value
B:	.skip	4				# Reserve for return value

	.end					# Indicates end of assembly language source
	