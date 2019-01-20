#---------------------------------------------------------------------------
# Modulo program
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Load first param
	ldw		r3, B(r0)		# Load second param
	call Mod
	stw		r2, C(r0)		# Save result in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main subroutine
#---------------------------------------------------------------------------

Mod:						# Computes r2 <- r2 % r3. Assumes positive integers
	subi	sp, sp, 4		# Reserve word
	stw		r4, 0(sp)		# r4 to be used as temp
	div		r4, r2, r3		# Branch to subtraction if r2 >= r3
	mul		r4, r4, r3		# r4 <- (r2//r3) * r3
	sub		r2, r2, r4		# Get remainder
	ldw		r4, 0(sp)		# Restore r4
	addi	sp, sp, 4		# Free stack
	ret

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	381				# First input param
B:	.word	23				# Second input param
C:	.skip	4				# 4 byte return location

	.end					# Indicates end of assembly language source
	