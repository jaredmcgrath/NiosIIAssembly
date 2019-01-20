#---------------------------------------------------------------------------
# Project Euler 006
# Find the difference between the sum of the squares of the first one hundred natural numbers and the square of the sum.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Get input from memory
	call Main
	stw		r2, B(r0)		# Store result in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main subroutine
#---------------------------------------------------------------------------

Main:
	subi	sp, sp, 16		# Reserve 4 words (16 bytes) on stack
	stw		ra, 12(sp)		# Store return address on stack
	stw		r3, 8(sp)		# Store r3 on stack
	stw		r2, 4(sp)		# Store r2 on stack
	call	SumSquares
	stw		r2, 0(sp)		# Put the Sum of Squares on stack
	ldw		r2, 4(sp)		# Restore limit to r2
	call	SquareSum
	ldw		r3, 0(sp)		# Get Sum of Squares from stack
	sub		r2, r2, r3		# Find the difference
	ldw		r3, 8(sp)		# Restore r16
	ldw		ra, 12(sp)		# Restore ra
	addi	sp, sp, 16		# Free stack
	ret

SumSquares:					# Calculates sum of all squares of natural numbers less than r2
	subi	sp, sp, 12		# Reserve 3 words (12 bytes) on stack
	stw		r3, 8(sp)		# Store r3 on stack
	stw		r4, 4(sp)		# Store r4 on stack
	stw		r5, 0(sp)		# Store r5 on stack
	movi	r3, 1			# Start counter at 1
	mov		r5, r2			# Put our limit var in r5
	mov		r2, r0			# Set sum to 0
_squareAdd:
	mov		r4, r3			# Move current counter val to r4
	mul		r4, r4, r4		# Find square
	add		r2, r2, r4		# Add square to sum
	addi	r3, r3, 1		# Increment counter
	ble		r3, r5, _squareAdd	# If r3 <= r5, continue loop
	ldw		r5, 0(sp)		# Prep to return
	ldw		r4, 4(sp)
	ldw		r3, 8(sp)
	addi	sp, sp, 12
	ret

SquareSum:					# Calculates square of sum of all natural numbers less than r2
	subi	sp, sp, 8		# Reserve 2 words (8 bytes) on stack
	stw		r3, 4(sp)		# Store r3 on stack
	stw		r4, 0(sp)		# Store r4 on stack
	movi	r3, 1			# Start counter at 1
	mov		r4, r2			# Put our limit var in r4
	mov		r2, r0			# Set sum to 0
_sum:
	add		r2, r2, r3		# Add current counter val
	addi	r3, r3, 1		# Increment counter
	ble		r3, r4, _sum	# If r3 <= r4, continue loop
	mul		r2, r2, r2		# Square the sum
	ldw		r4, 0(sp)		# Prep to return
	ldw		r3, 4(sp)
	addi	sp, sp, 8
	ret

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	100				# Limit
B:	.skip	4				# Reserve 4 bytes for result

	.end					# Indicates end of assembly language source
	