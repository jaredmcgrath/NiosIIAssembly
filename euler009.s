#---------------------------------------------------------------------------
# Project Euler 009
# There exists exactly one Pythagorean triplet for which a + b + c = 1000.
# Find the product abc, where a < b < c.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Get param from memory
	call	Main
	stw		r2, B(r0)		# Store result in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main subroutine
#---------------------------------------------------------------------------

Main:
	subi	sp, sp, 28		# Reserve 7 words
	stw		ra, 24(sp)		# Store return address on stack
	stw		r3, 20(sp)		# r3 to be used as temp
	stw		r4, 16(sp)		# r4 to be used as temp
	stw		r5, 12(sp)		# r5 to be used as temp
	movi	r3, 997			# Initialize expected c as 997 (1000 - 1 - 2)
	stw		r3, 8(sp)		# Push c to stack
	movi	r3, 2			# Initialize b as 2
	stw		r3, 4(sp)		# Push b to stack
	movi	r3, 1			# Initialize a as 1
	stw		r3, 0(sp)		# Push a to stack

_george:
	ldw		r3,	0(sp)		# Get current a off stack
	mul		r4, r3, r3		# Calculate a^2, put it in r4
	ldw		r3, 4(sp)		# Get current b off stack
	mul		r5, r3, r3		# Calculate b^2, put it in r5
	add		r3, r4, r5		# Calculate c^2
	ldw		r4, 8(sp)		# Get expected c off stack
	mul		r4, r4, r4		# Calculate expected c^2
	bne		r3, r4, _next	# If expected c^2 != c^2, go to next
	ldw		r2, 0(sp)		# Get a off stack
	ldw		r3, 4(sp)		# Get b off stack
	mul		r2, r2, r3		# r2 <= a*b
	ldw		r3, 8(sp)		# Get c off stack
	mul		r2, r2, r3		# r2 <= r2*c
	ldw		r5, 12(sp)		# Restore r5
	ldw		r4, 16(sp)		# Restore r4
	ldw		r3, 20(sp)		# Restore r3
	ldw		ra, 24(sp)		# Restore ra
	addi	sp, sp, 28		# Free stack
	ret

_next:
	ldw		r3, 0(sp)		# Get a off stack
	ldw		r4, 4(sp)		# Get b off stack
	addi	r3, r3, 1		# Increment a
	beq		r3, r4, _addB	# If b == a
	stw		r3, 0(sp)		# Store a on stack
	ldw		r3, 8(sp)		# Get c off stack
	subi	r3, r3, 1		# Decrement c
	stw		r3, 8(sp)		# Store c on stack
	br		_george			# Continue loop
_addB:
	addi	r4, r4, 1		# Increment b
	movi	r3, 1			# Reset a to 1
	stw		r4, 4(sp)		# Store b on stack
	stw		r3, 0(sp)		# Store a on stack
	add		r3, r3, r4		# Add a + b
	movi	r4, 1000		# Put 1000 in r4
	sub		r3, r4, r3		# Calculate new expected c
	stw		r3, 8(sp)		# Put new expected c on stack
	br		_george			# Continue loop

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	1000			# Max val
B:	.skip	4				# Reserve 4 bytes for return

	.end					# Indicates end of assembly language source
	