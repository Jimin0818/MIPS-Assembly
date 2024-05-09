#This file contains the subroutines that are called in the main file
#This is assignment #4 for CS2340, commented and written by Ji Min Yoon starting March 8th
#Net ID: JXY210022   
         .eqv      return 0
         .eqv      stringLength 4
         .eqv      stringStart 8
         .eqv      lowerToUpper 32
         .data
         .text
         .globl    getSize
         .globl    convertCase
         .globl	   removeSymbol
         .globl    getStackSize
         .globl    setStack

#Gets the size of the modified string
getSize:
         lbu       $t0, ($a0)                    #Loads the first character of the string into $t0
         beq       $t0, $zero, sizeEnd           #Branches to SizeEnd if the character equals '\n'
         addi      $a0, $a0, 1                   #Else increment the memory address by 1 to move on to the
                                                 #next character
         b         getSize                       #Loops until the chacter equals '\n'
sizeEnd:
         sub       $t1, $a0, $s0                 #Subtract the incremented memory address by original memory 
                                                 #address to determine the number of characters in the string
         subi      $t1, $t1, 2                   
         move      $a0, $s0                      #Resets the memory address($a0) to it's original value before jumping
         jr        $ra                           #Jumps back to the return address

#Converts character between 'a' through 'z' to an uppercase character
convertCase:
         lbu       $t0, ($a0)                    #Load the character of $a0 to $t0
         beq       $t0, $zero, convertEnd        #Branch to convertEnd if the character equals '\n'
         blt       $t0, 'a', increment           #Branches to increment if the character is less than 'a'
         bgt       $t0, 'z', increment           #Branches to increment if the character is greater than 'z'
         sub       $t0, $t0, lowerToUpper        #Subtract the character by 32 to convert from lower to upper
         sb        $t0, ($a0)                    #Store the modified byte back into the memory address
# Increments to the next byte
increment:
         addi      $a0, $a0, 1
         j         convertCase                   #Jumps back to the loop convertCase after increment to next byte
	
#Restores the modified memory address($a0) to its original value
convertEnd:
         move      $a0, $s0                      
         jr        $ra                           #Jumps back to the return address
	
#Goes through the characters and remove non alphabet and numbers from the string
removeSymbol:
         lbu       $t0, ($a0)                    #Load the character of $a0 to $t0
         beq       $t0, '\n', removeEnd	         #Branch to removeEnd if $t0 character equals '\n'
         slti      $t1, $t0, '0'                 #If the $t0 is less than '0'
         bne       $t1, $zero, tempAddr          #Branch to tempAddr if $t1 does not equal zero
         slti      $t1, $t0, ':'                 #If $t0 is greater than ':' 
         slti      $t2, $t0, 'A'                 #AND less than 'A'
         slt       $t3, $t1, $t2                 #Compares the two truth values
         bne       $t3, $zero, tempAddr          #Branch to tempAddr if $t3 does not equal 0 
         slti      $t1, $t0, '['                 # If $t1 is greater  than '['
         beq       $t1, $zero, tempAddr          #Branch to tempAddr if $t1 equals zero 
         addi      $a0, $a0, 1                   #Increment to next byte
         b         removeSymbol                  #Loops until character equals '\n'

tempAddr:
         move      $t1, $a0                      #Stores the memory address into temporary address for n+1 characters
         move      $t2, $a0                      #Stores the memory address into temporary address for n characters     
	
#Shifts over n+1 character into n position. Terminates loop when n+1 character equals '\n'
removeLoop:
         addi      $t1, $t1, 1                  #Set to memory address to n+1
         lbu       $t0, ($t1)			#Load the character of $t1(n+1) to $t0
         sb        $t0, ($t2)			#Stores the next character in the current character spot
         beq       $t0, $zero , removeSymbol	#Branch to removeSymbol if the next character equals null terminator
         addi      $t2, $t2, 1			#Else increment $t2
         j         removeLoop
	
#Restores the modified memory address($a0) to its original value
removeEnd:
         move      $a0, $s0                      
         jr        $ra                           #Jumps back to the return address

	
#Moditfies the stack size based on the length of string + 8 for return address and length of string
getStackSize: 
         addi      $s1, $t1, 8                   #Stack size of length of the string + 8 bytes for length of string and $ra
         addi      $s1, $s1, 3                   #Adds 3 to the stackSize so no value is lost during shifting
         srl       $s1, $s1, 2                   #Shift right by 2; samething as dividing by 4
         mul       $s1, $s1, 4                   #Multiple the value by 4, so the stack size is always a multiple of 4
         jr        $ra                           #Jumps back to return address
setStack:
         sub       $sp, $sp, $s1                 #Allocates stack by $s1(stack size)
         move      $s4, $sp                      #Move the beginning of stack memory into $s4
         sw        $ra, return ($sp)              #Store return address into 0($sp)
         sw        $t1, stringLength($sp)        #Store length of the string into 4($sp)
         addi      $sp, $sp, stringStart         #Adds 8 to the $sp so the base $sp will be after $ra and string length
fillStack:
         lbu       $t0, ($a0)                    #Load the character of $a0 to $t0
         beq       $t0, '\n', isPalindrome       #Branches to isPalindrome if $t0 equals '\n'
         sb        $t0, ($sp)                    #Stores the byte into the 8th position of the stack
         addi      $sp, $sp, 1                   #Increments $sp to next byte
         addi      $a0, $a0, 1                   #Increments $a0 memory address of user input string to next byte
         j         fillStack                     #Loops until $t0 character equals '\n'
isPalindrome:		
         move      $sp, $s4                      #Move the original stack pointer address back into $sp
         addi      $sp, $sp, stringStart         #Adds 8 to the $sp, so stack pointer can start at the string characters
         lbu       $t2, ($sp)                    #Load the character of $sp to $t2
         move      $t6, $sp                      #Moves the stack pointer address to a temporary address
         add       $t6, $t1, $t6                 #Adds the length of the string to the temporary address to get the
                                                 #memory address of the last byte of the string
         lbu       $t4, ($t6)                    #Loads the last character of $sp to $t4
         addi      $s0, $s0, 1                   #Adds one to the original memory address to slice the first character off
         move      $a0, $s0                      #Move the new original memory address to $a0
         addi      $t1, $t1, -2                  #Decreases the string length by 2; essenctially slicing off the last character 
         add       $sp, $sp, $s1                 #Add the stack size back to the $sp to deallocate the stack pointer
         sub       $sp, $sp, stringStart         #Subtract 8 from the $sp to deallocate the stack pointer; undoing line 101
         bne       $t2, $t4, printF              #Branches to printF if the two bytees are not equal 
         blt       $t1, 1 , printT               #Braches to printT if the length of the string is less than 1; reached base case
         jal       setStack
printT:
         li        $v0, 1                        #Loads in the boolean value 1 into $v0
         j         printResults	
printF:
         li        $v0, 0                        #Loads in the boolean value 0 into $v0
         j         printResults
