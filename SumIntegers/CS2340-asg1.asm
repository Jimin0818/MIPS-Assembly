# Computes the number and the sum of integers given by the user, then prints.
# This is assignment #1 from CS2340.005, commented and modified by Ji Min Yoon starting February 1st, 2023
# Net ID: JXY210022

      	 .include "SysCalls.asm"
         .data 
prompt:  .asciiz  "Enter an integer: " 
sum:     .asciiz  "The sum is: " 
numInt:	 .asciiz  "The number of integers entered was: " 
newLine: .asciiz  "\n"		       #Enters a new line

#Start of the code
         .text 
#Loop for entering Integers
enterInt:	
         li	 $v0, SysPrintString   #Prints out the prompt:"Enter an integer: "
         la	 $a0, prompt 
         syscall 
         li 	 $v0, SysReadInt       #Read user input(Integer) and loads immediate value into $v0 register
         syscall      
         beqz    $v0, printResult      #Terminates loop and jumps to printResult if $v0 (user input) equals zero
         add	 $t0, $t0, $v0         #Adds the user's input ($v0) into the register $t0	
         add     $t1, $t1, SysPrintInt #Initializes and increments the number of integers inputted by the user by one 	
         j       enterInt	       #loops; jumps back to the start of enterInt
printResult: 
	 li	 $v0, SysPrintString   #Prints an empty line 
	 la	 $a0, newLine 
	 syscall 	
	 li	 $v0, SysPrintString   #Prints out the statement:"The sum is: "
	 la	 $a0, sum 
	 syscall 
	 li	 $v0, SysPrintInt      #Prints out the sum of all input integers 
	 add	 $a0, $t0, $zero
	 syscall 	
	 li	 $v0, SysPrintString   #Prints an empty line 
	 la	 $a0, newLine 
	 syscall 
	 li	 $v0, SysPrintString   #Prints out the statement:"The number of integers entered was: "	 
	 la	 $a0, numInt 
	 syscall 
	 li	 $v0, SysPrintInt      #Prints out the number of integers inputted by the user            
	 add	 $a0, $t1, $zero
	 syscall 
	 li 	 $v0, SysPrintString   #Prints an empty line 
	 la	 $a0, newLine  
	 syscall 
         li      $v0, SysExit          #Successfully terminates the program	
	 syscall
	

	
	




