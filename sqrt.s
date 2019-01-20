#---------------------------------------------------------------------------
# Base program that includes all the overhead stuff
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)
	call Sqrt
	stw		r2, B(r0)
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Sqrt subroutine
# Finds square root of supplied input in r2
#---------------------------------------------------------------------------

Sqrt:
	subi	sp, sp, 16		# Reserve 4 words
	stw		r16, 12(sp)		# r16 to be used for max loop var (i)
	stw		r3, 8(sp)		# r3 to be used for current sqrt (x)
	stw		r4, 4(sp)		# r4 as temp
	stw		r5, 0(sp)		# r5 as counter
	movi	r5, 0			# Set counter to 0
	movi	r3, 2			# Put 2 in r3 to prep for division
	div		r16, r2, r3		# Find the limit, store in r16
	mov		r3, r2			# Set r3 <- r2
_divCheck:
	div		r4, r2, r3		# r4 <- n / x
	add		r3, r4, r3		# r3 <- x + (n / x)
	movi	r4, 2			# r4 <- 2
	div		r3, r3, r4		# x <- r3 / 2
	addi	r5, r5, 1		# Increment counter
	blt		r5, r16, _divCheck	# Continue loop if not at limit
	mov		r2, r3			# Put r3 in r2
	ldw		r5, 0(sp)		# Restore r5
	ldw		r4, 4(sp)		# Restore r4
	ldw		r3, 8(sp)		# Restore r3
	ldw		r16, 12(sp)		# Restore r16
	addi	sp, sp, 16		# Free stack
	ret

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	120
B:	.skip	4

	.end					# Indicates end of assembly language source
	