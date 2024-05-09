#Determines whether the user input is a palindrome by modifying the string into all uppercase and number 
#characters, and through the use of stack memory and recursion. Then prints whether the given 
#string is a palindrome or not a palindrome. 
#This is assignment #4 for CS2340, commented and written by Ji Min Yoon starting March 8th
#Net ID: JXY210022
         .include  "SysCalls.asm"
         .eqv      bufferSize 201
         .data
prompt:  .asciiz   "Enter a string: "
pan:     .asciiz   "Palindrome\n"
notPan:  .asciiz   "Not a Palindrome\n"
         .align    2
buffer:	 .space    bufferSize
         .text
         .globl    main
         .globl    printResults
main:

         li        $v0, SysPrintString           #Prints the statement: "Enter a string: "
         la        $a0, prompt 
         syscall                  
         li        $v0, SysReadString            #Reads user input string and load it into buffer
         la        $a0, buffer                   #Loads memory address of buffer into $a0
         li        $a1, bufferSize               #Allocates 201 bytes for the buffer
         syscall					
         move      $s0, $a0                      #Move memory address of string into $s0 
         jal       convertCase                   #Jumps to function convertCase to change all lowercase characters
                                                 #to uppercase characters
         jal       removeSymbol                  #Jumps to function removeSymbol to remove all non uppercase alphabets
                                                 #and numbers
         jal       getSize                       #Jumps to function getSize to count how many character is in the string
         lbu       $t0, ($a0)                    #Loads the first character of string into $t0
         beq       $t0, '\n', terminate          #Exits the program the first character equals '\n'
         jal       getStackSize                  #Jumps to function getStackSize to get the stack size for each input
         jal       setStack                      #Jumps to function setStack which fills the stack with values and
                                                 #determines whether the string is a palindrome through recursion 
printResults:       
         bne       $v0, $zero, printT            #Branches to printT if truth value is not 0
         li        $v0, SysPrintString           #Prints out the statement: "Not a Palindrome"
         la        $a0, notPan
         syscall				
         j         main                          #Loops for another input until user inputs '\n'	
printT:
         li        $v0, SysPrintString           #Prints out the statement: "Palindrome"
         la        $a0, pan
         syscall					
         j         main                          #Loops to for another input until user inputs '\n'
terminate: 
         li        $v0, SysExit                  #Successifully terminates the program
         syscall



