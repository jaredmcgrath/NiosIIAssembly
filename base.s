#---------------------------------------------------------------------------
# Base program that includes all the overhead stuff
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
    
_end:
	br		_end			# Infinite loop once program execution completes


#---------------------------------------------------------------------------
# Section for variables and return values stored in memory
#---------------------------------------------------------------------------
	.org	0x00001000		# Declares starting memory location for following content
    
    

	.end					# Indicates end of assembly language source
	