#---------------------------------------------------------------------------
# Lab 1 Part 2:
# Implement VolumeCylinder(r,h)
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Get r
	ldw		r3, B(r0)		# Get h
	call	VolumeCylinder	# Call subroutine
	stw		r2, C(r0)		# Store return value in memory
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main Subroutine:
#---------------------------------------------------------------------------

VolumeCylinder:
	subi	sp, sp, 8
	stw		r16, 4(sp)
	stw		r17, 0(sp)
	mul		r16, r2, r2		# r2 <- r2 * r2 (rsquared = r * r)
	muli	r17, r16, 314	# r2 <- 314 * r2 (acircle = 314 * rsquared)
	mul		r2, r17, r3		# r2 <- r2 * r3	(result = acircle * h)
	ldw		r17, 0(sp)
	ldw		r16, 4(sp)
	addi	sp, sp, 8
	ret						# (return result)

#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
A:	.word	3				# Input for radius, r
B:	.word	4				# Input for height, h
C:	.skip	4				# Reserve 1 word for return value

	.end					# Indicates end of assembly language source
	