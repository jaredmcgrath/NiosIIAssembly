#---------------------------------------------------------------------------
# Project Euler 10
# Find the sum of all the primes below two million.
#---------------------------------------------------------------------------
	.equ	LAST_RAM_WORD, 0x007FFFFC

	.text					# Indicates start of a code segment
	.global _start			# Makes _start symbol visible to linker
	.org 0x00000000			# Declares starting memory location for following content

_start:
	movia 	sp, LAST_RAM_WORD	# Initializes stackpointer for subroutines
	ldw		r2, A(r0)		# Get input
	call Main
	stw		r2, B(r0)		# Store output
    
_end:
	br		_end			# Infinite loop once program execution completes

#---------------------------------------------------------------------------
# Main sieve subroutine
# See https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes
# Adapted from primes.s
#---------------------------------------------------------------------------

Main:
	subi	sp, sp, 8		# Reserve word for r3, r4
	stw		r3, 4(sp)
	stw		r4, 0(sp)
	mov		r4, sp			# Store sp
	addi	r4, r4, 4		# Increment stored sp
	muli	r3, r2, 4		# Get number of bytes to reserve
	sub		sp, sp, r3		# Reserve array
	mov		r3, r4			# Retrieve stored sp
	addi	

	subi	sp, sp, 24		# Reserve 6 words
	stw		r2, 20(sp)
	stw		ra, 16(sp)		# Store ra
	call	Init			# Initialize array
	call	Sqrt			# Get sqrt of list
	ldw		ra, 16(sp)		# Restore ra
	stw		r4, 16(sp)		# r4 to be used as counter for next test val/next prime
	stw		r5, 12(sp)		# r5 to be used as offset/temp
	stw		r6, 8(sp)		# r6 to be used as temp
	stw		r0, 4(sp)		# Push array size to stack
	stw		r3, 0(sp)		# Push array offset
	movi	r4, 2			# Set counter to 2
_checkNext:
	roli	r5, r4, 2		# Left rotate by 2  to get offset (= multiply by 4)
	add		r5, r5, r3		# Calculate true offset
	ldw		r6, 0(r5)		# Load word from array
	beq		r6, r0, _next	# If array is false, branch to next
	ldw		r5, 0(sp)		# Get current index off stack
	stw		r4, 0(r5)		# Put next prime in array
	addi	r5, r5, 4		# Increment offset by 4
	stw		r5, 0(sp)		# Push new offset to stack
	ldw		r5, 4(sp)		# Get array size
	addi	r5, r5, 1		# Increment size
	stw		r5, 4(sp)		# Store new array size
	mul		r5, r4, r4		# Square next prime
	muli	r5, r5, 4		# Multiply by 4
	add		r5, r5, r3		# Get true initial offset
	ldw		r6, 20(sp)		# Get original n
	muli	r6, r6, 4
	add		r6, r6, r3
	subi	sp, sp, 4		# Reserve new word on stack
	stw		r6, 0(sp)		# Store r6 on stack
_setFalse:
	stw		r0, 0(r5)		# Set val in memory to 0
	muli	r6, r4, 4
	add		r5, r5, r6		# Add prime to running sum
	ldw		r6, 0(sp)		# Get mem limit from stack
	blt		r5, r6, _setFalse	# If less than n, coninue setting multiples false
	addi	sp, sp, 4		# Free stack
_next:
	addi	r4, r4, 1		# Increment counter
	ble		r4, r2, _checkNext	# Continue loop while not exceeding sqrt of n
	ldw		r2, 20(sp)		# Put original n in r2
_remainingPrimes:
	muli	r5, r4, 4		# Multiply counter by 4 to get byte offset
	add		r5, r5, r3		# Calculate true offset
	ldw		r6, 0(r5)		# Load word from array
	beq		r6, r0, _next2	# If array is false, branch to next2
	ldw		r5, 0(sp)		# Get array offset
	stw		r4, (r5)		# Put next prime in array
	addi	r5, r5, 4		# Increment current offset
	stw		r5, 0(sp)		# Push new offset to stack
	ldw		r5, 4(sp)		# Get array size
	addi	r5, r5, 1		# Increment array size
	stw		r5, 4(sp)		# Store new size
_next2:
	addi	r4, r4, 1		# Increment counter
	ble		r4, r2, _remainingPrimes	# Continue loop while not exceeding n
	ldw		r2, 4(sp)		# Get final size
	ldw		r6, 8(sp)		# Restore registers
	ldw		r5, 12(sp)
	ldw		r4, 16(sp)
	ldw		r3, 24(sp)
	addi	sp, sp, 24		# Free stack
	ret


#---------------------------------------------------------------------------
# Init subroutine
# n = r2; l = r3
# Sets the first n words after l to 1 (true)
#---------------------------------------------------------------------------

Init:
	subi	sp, sp, 12
	stw		r4, 8(sp)		# r4 to be used as temp
	stw		r5, 4(sp)		# r5 to be used as counter
	stw		r6, 0(sp)		# r6 to be used as temp
	movi	r4, 1			# Put 1 in r4
	mov		r5, r0			# Set counter to 0
_setNext:
	muli	r6, r5, 4		# Multiply counter by 4 to get offset
	add		r6, r6, r3		# Calculate true offset
	stw		r4, (r6)		# Set the val in memory to 1
	addi	r5, r5, 1		# Increment counter
	blt		r5, r2, _setNext	# Continue loop while not all set
	ldw		r6, 0(sp)
	ldw		r5, 4(sp)
	ldw		r4, 8(sp)
	addi	sp, sp, 12
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
    
A:	.word	2000000			# Input param: 2,000,000 limit
B:	.skip	4				# Output reservation

	.end					# Indicates end of assembly language source
	