#---------------------------------------------------------------------------
# Find all primes less than or equal to a given number
# Implements the Sieve of Eratosthenes
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, N(r0)		# Get input n
	movi	r3, L			# Put address of list in r3
	call	Sieve
	stw		r2, X(r0)		# Store output at X
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main subroutine
# See https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
# Params:	r2 is (inclusive) maximum value to look for primes
#			r3 is a pointer to the first address in a block of (r2//32) + 1 bytes to serve as an array
#			r4 is a pointer to a safe area where primes can be stored, as there will be an unknown number of them
#	1)	Init subroutine sets all values in supplied array to 1 (true)
#	2)	_checkNext fetches next true/false value from memory
#		If true, counter holds new prime. Add to array, then sieve all composite
#		multiples starting at the square of the new prime
#		If false (0), increment and loop
#	3)	After populating array with all primes less than sqrt(n), and sieveing them,
#		add all remaining primes between sqrt(n) and n (they will be marked true in the array)
#	4)	Throughout this whole process, new primes are overwriting the t/f array to conserve memory
#		Additionally, primes are counted, and the final number is returned in r2
#		This means that, upon ret, the address supplied in r3 is the first element in an array
#		of r2 prime numbers
#---------------------------------------------------------------------------

Sieve:
	stw		ra, (sp)
	call	Init
	ldw		ra, (sp)


#---------------------------------------------------------------------------
# Init subroutine
# n = r2; l = r3
# Sets the first n bits after l to 1 (true)
#---------------------------------------------------------------------------

Init:
	subi	sp, sp, 8		# Reserve 2 words
	stw		r16, 4(sp)		# r16 to hold number of full words we'll use
	stw		r17, 0(sp)		# r17 to be used as temp
	stw		r18, 0(sp)		# r18 to be used as counter
	movi	r17, 32
	div		r16, r2, r17	# Calculate # of full words required
	movi	r17, 0xFFFFFFFF	# All bits true word
	movi	r18, 0			# r2 will be used as counter
_initNextWord:
	stw		r17, 0(r3)		# Store r17 at address
	addi	r3, r3, 4		# Find next effective address
	addi	r18, r2, 1		# Increment counter
	ble		r18, r16, _initNextWord	# Continue branching while still have words to set
	ldw		r18, 0(sp)
	ldw		r17, 0(sp)		# Restore registers
	ldw		r16, 4(sp)
	addi	sp, sp, 8
	ret

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
    
N:	.word	1000			# Input param: max value to check, inclusively
X:	.skip	4				# Output var: # of primes less than N
L:	.skip	4000			# Array in memory: should be 4*N

	.end					# Indicates end of assembly language source
	