# File: Homework.asm 
# Author: Nicolas Montero--Fraysse 
# Purpose: A program that solves quadratic equation (ax^2+bx+c=0) in real numbers domain.

.text
main:
	# Get input value, a
   	li $v0, 4
   	la $a0, prompta
   	syscall
   	li $v0, 6
   	syscall
   	mov.s $f1, $f0

   	# Get input value, b 
   	li $v0, 4
   	la $a0, promptb
   	syscall
   	li $v0, 6
   	syscall
   	mov.s $f2, $f0

   	# Get input value, c
   	li $v0, 4
   	la $a0, promptc
   	syscall
   	li $v0, 6
   	syscall
   	mov.s $f3, $f0

	# Compute delta
	jal DetCompute

	l.s $f7, zeroFloat

	# If determinant == 0 => OneRoot
	c.eq.s $f12, $f7
	bc1t OneRoot

	# If determinant < 0 => NoSolution
	c.lt.s $f12, $f7
	bc1t NoSolution

	# else (if determinant > 0 => TwoRoots)
	# (No need for an if statement because we exit the program inside the functions 
	# Babylonian method to compute the square root
	jal SquareRoot

	mov.s $f11, $f8 # $f11 = sqrt(b² - 4ac)
	neg.s $f5, $f2	# -b
	add.s $f4, $f1, $f1 # 2a

	# Solution 1
	add.s $f12, $f5, $f11
	div.s $f12, $f12, $f4

	la $a0, solution1
	li $v0, 4
	syscall

	li $v0, 2
	syscall

	# Solution 2
	sub.s $f12, $f5, $f11
	div.s $f12, $f12, $f4

	la $a0, solution2
	li $v0, 4
	syscall

	li $v0, 2
	syscall

	# Exit program
	jal Exit

.data
	prompta: 	.asciiz "Enter value for a: "
	promptb: 	.asciiz "Enter value for b: "
	promptc: 	.asciiz "Enter value for c: "

	zeroFloat:	.float 0.0
	halfFloat:	.float 0.5

	x0:	.float 999999999.0

	solution1:	.asciiz "The two solutions are x1~= "
	solution2:	.asciiz " and x2~= "


# subprogram: DetCompute
# author: Nicolas Montero--Fraysse
# purpose: to compute the determinant 
# input:  $f1 $f2 $f3 for a, b and c
# returns:  $f12 <- The determinant
# side effects: loads in $f12 the determinant 
.text
DetCompute:
	l.s $f7, four
	mul.s $f5, $f2, $f2 	# b²
	mul.s $f4, $f1, $f3		# ac
	mul.s $f4, $f4, $f7		# 4ac
	sub.s $f12, $f5, $f4	# b² -4ac

	jr $ra

.data 
	four: .float 4.0


# subprogram: OneRoot
# author: Nicolas Montero--Fraysse
# purpose: to compute the solution if only one root and print it to the console 
# input:  $f1 $f2 for a and b
# returns:  none
# side effects: prints to the console the only solution
.text
OneRoot:
	neg.s $f5, $f2			# -b
	add.s $f4, $f1, $f1 	# 2a
	div.s $f12, $f5, $f4	# -b/2a
	
	la $a0, solution
	li $v0, 4
	syscall

	li $v0, 2
	syscall
	
	# Exit program
	li $v0, 10
	syscall

.data
	solution:	.asciiz "The unique solution is: "


# subprogram: NoSolution
# author: Nicolas Montero--Fraysse
# purpose: to print to the console that there is no real solutions 
# input:  none
# returns:  none
# side effects: prints to the console "No real solutions."
.text
NoSolution:
	la $a0, nosolution
	li $v0, 4
	syscall
	
	# Exit program
	li $v0, 10
	syscall

.data
	nosolution:	.asciiz "No real solutions."

# Compute the square root of determinant
# I will use the Babylonian method 6x6 times
# because x0 is suposed to be barely equal to the square root 
# of S. So If we do it over and over again, we will be sure 
# to find the exact solution even with a huge number.
# (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
.text
SquareRoot:
	li $s2, 5

	l.s $f8, x0		# Give $f8 the random guess
	l.s $f10, halfFloat # Give $f10 the value 0.5

	start_loop:
		start_loop2:

			beq $s0, $s2, end_loop2

			div.s $f9, $f12, $f8	# $f9 = S/xn
			add.s $f8, $f8, $f9		# xn + S/xn
			mul.s $f8, $f10, $f8	# 1/2 (xn + S/xn)

			add $s0, $s0, 1
			b start_loop2
		end_loop2:

		li $s0, 0

		beq $s1, $s2, end_loop
		add $s1, $s1, 1
		b start_loop
	end_loop:

	jr $ra

# subprogram: Exit 
# author: Charles Kann 
# purpose: to use syscall service 10 to exit a program 
# input: None 
# output: None 
# side effects: The program is exited 
.text 
Exit: 
    li $v0, 10 
    syscall
