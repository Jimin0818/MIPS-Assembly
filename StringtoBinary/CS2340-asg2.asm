# Convert ASCII inputted by user into binary, compute the sum of that binary, number of valid inputs, 
#number of invalid inputs, then prints. Also detects invalid inputs
# This is assignment #2 from CS2340.005, commented and modified by Ji Min Yoon starting February 12, 2023
# Net ID: JXY210022

      	 .include "SysCalls.asm"
         .data 
buffer:  .space  12
prompt:  .asciiz "Enter a number: " 
error:	 .asciiz "Error. Please enter a valid character"
sum: 	 .asciiz "Sum: "
numError:.asciiz "Total number of errors: "
numValid:.asciiz "Count of valid numbers: "
newLine: .asciiz "\n" 
#Start of the code
         .text
main:	 
	 li	 $s0, 0		        #Initializing accumulator register(Sum) to zero
	 li	 $s1, 0		        #Initializing accumulator register(Valid input counter) to zero 	
	 li	 $s2, 0		        #Initializing accumulator register(Error input counter) to zero  
	 li	 $s3, 0		        #Initializing accumulator register(Temporary sum) to zero  

					#Asks the user prompt, and get user input
askPrompt:					
	 la	 $a0, prompt
	 li	 $v0, SysPrintString    #Prints the prompt:"Enter a number: "
	 syscall 
         la      $a0, buffer            #Loads address of input buffer into $a0
         li	 $a1, 12	        #Length of buffer
         li	 $v0, SysReadString     #Loads user input(String) into $v0 
         syscall

        				#Checks the first charcter of the buffer for '\n' or '-'         
checkNum:				
         li	 $t3, '\n'	        #Load new line character into $t3
         li	 $t4, '-'		#Load '-' character into $t4
         move	 $t0, $a0		#Move address of $a0 to $t0
         lbu     $t1 ,($t0)		#Loads the character at $t0 into $t1
         beq	 $t1, $t3, printResults #Branch to printResult if the first character of user input = new line charcter  
         beq	 $t1, $t4, subSum  	#Branch to subSum if the first character of user input = '-'

					#Converts the number to binary integer one at a time, check the validity of the input, and add to accumulator
addSum:					
         lbu     $t1 ,($t0)		#Loads the character at $t0 into $t1
         li	 $t3, '\n'	        #Load new line character into $t3
         beq	 $t1, $t3, addTotal	#If the character ='\n'(Otherthan the first character), branch to addTotal
         blt	 $t1, 48, errorMsg	#Branch to errorMsg, if character($t1) has ascii number less than 48 (ASCII 48 = 0)
	 bgt	 $t1, 57, errorMsg      #Branch to errorMsg, if character($t1) has ascii number greater than 57 (ASCII 57 = 9)
         sub	 $t1, $t1, 48		#Subtract 48 from $t1 to convert from ASCII to binary; same concept as subtracting '0'
         mul	 $s3, $s3, 10		#Multiply $s3 (Accumulator) by 10
         add	 $s3, $s3, $t1 		#Add $t1 into $s3
	 addi	 $t0, $t0, 1  		#Increase the address of $t0(User Input) by one to move on to the next character 
	 j	 addSum			#Loops the addSum again until charcter in $t0 = 'n' (Line 40)
	 
	 				#Converts the number to binary integer one at a time, check the validity of the input, and add to accumulator but as a negative integer
subSum:
 	 addi	 $t0, $t0, 1     	#Since the first character is '-', increaments the address of user input by 1 to move on to the next character(Valid number)
         lbu     $t1 ,($t0)		#Loads the character at $t0 into $t1
         li	 $t3, '\n'	        #Load new line character into $t3
         beq	 $t1, $t3, addTotal	#If the character ='\n'(Otherthan the first character), branch to addTotal
         blt	 $t1, 48, errorMsg	#Branch to errorMsg, if character($t1) has ascii number less than 48 (ASCII 48 = 0)
	 bgt	 $t1, 57, errorMsg      #Branch to errorMsg, if character($t1) has ascii number greater than 57 (ASCII 57 = 9)
         sub	 $t1, $t1, 48		#Subtract 48 from $t1 to convert from ASCII to binary 
         mul	 $s3, $s3, 10		#Multiply $s3 (Accumulator) by 10
         sub	 $s3, $s3, $t1 		#Subtracts $t1 into $s3
	 j	 subSum			#Loops the addSum again until charcter in $t0 = 'n' (Line 40)	 
	 
	 				#Adds the value from accumulator into sum, then refreshes the accumulator; increments number of valid input by one; loops back to the prompt
addTotal:
	 add	 $s0, $s3, $s0		#Transfers the value from the accumulator($s3) into $s0
	 li	 $s3,0			#Refreshes the value of the accumulator($3) by loading zero 
	 addi 	 $s1, $s1,1		#Increments the number of valid inputs 
	 j	 askPrompt 		#Loops back to the askPrompt until the user inputs a newLine character to break the loop
		
					#Prints sum, number of valid input, number of invalid input, then terminates program 
printResults: 
	 la	 $a0, sum		#Prints out the statement sum: "Sum: "
	 li	 $v0, SysPrintString
	 syscall
	 move	 $a0, $s0		#Prints out the sum of values inputted by user
	 li 	 $v0, SysPrintInt
	 syscall 
	 la	 $a0, newLine		#Prints an empty line 
	 li	 $v0, SysPrintString
	 syscall
	 la	 $a0, numValid		#Prints out the statement numValid: "Count of valid numbers: "
	 li	 $v0, SysPrintString
	 syscall
	 move	 $a0, $s1		#Prints out the number of valid inputs
	 li 	 $v0, SysPrintInt
	 syscall
	 la	 $a0, newLine		#Prints an empty line 
	 li	 $v0, SysPrintString
	 syscall
	 la	 $a0, numError		#Prints out statement numError: "Total number of errors: "
	 li	 $v0, SysPrintString
	 syscall
	 move	 $a0, $s2		#Prints out the number of invalid/erroneous input
	 li 	 $v0, SysPrintInt
	 syscall 
	 la	 $a0, newLine		#Prints an empty line 
	 li	 $v0, SysPrintString
	 syscall	 
         li      $v0, SysExit           #Successfully terminates the program	
	 syscall
	
					#Prints out the error message; increments number of error inputs; loops back to prompt for another integer
errorMsg:
	 la	 $a0, error		#Prints out the statement error: "Error. Please enter a valid character"
	 li	 $v0, SysPrintString
	 syscall
	 addi	 $s2, $s2, 1		#Increments the number of invalid inputs 
	 la	 $a0, newLine		#Prints an empty line 
	 li	 $v0, SysPrintString
	 syscall
	 j	 askPrompt		#Loops back to the askPrompt until the user inputs a newLine character to break the loop





