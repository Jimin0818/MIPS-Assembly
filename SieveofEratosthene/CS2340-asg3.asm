# Finds the prime number from 3 - n (User Input) through the 
#Sieve of Eratosthenese method using bit manipulation, then prints. 
#Also detects invalid inputs (Integer not between 3 and 160,000)
# This is assignment #3 from CS2340.005, commented and modified by Ji Min Yoon starting February 28, 2023
# Net ID: JXY210022


          .include  "Syscalls.asm"
          .data
          
askInt:   .asciiz   "Enter an Integer: "   
errorMsg: .asciiz   "Invalid Input...Please enter an integer between 3 and 160,000"
primeNum: .asciiz   "Prime Numbers are: "
newLine:  .asciiz   "\n"
comma:    .asciiz   ", "
          
          .text
	
askInteger:
          li       $v0, SysPrintString
          la       $a0, askInt
          syscall                                # Prints the prompt "Enter an integer: " 
          li       $v0, SysReadInt
          syscall                                #Stores integer(User Input) into $v0
          move     $s0, $v0                      #Moves user input from $v0 to $s0
          blt      $s0, 3, invalidInt            #Branch to errorMsg if the user input is not less than 3 
          bgt      $s0, 160000, invalidInt       #Branch to errorMsg if the user input is greater than 160,000 
	
roundAndAllocate:
          addi     $s0, $s0, 7                   #Adds 7 to the interger to round up non multiples of 8
                                                 #EX: 10/8 =1.25 = 1, (10 + 7)/8 = 2.125 = 2
          srl      $s1, $s0, 3                   #Shifts to the right logical by 3; equivalent to dividng by 8 or 2^3  
          move     $a0, $s1                      #Allocates $s1 bytes of memory and store address in $v0   
          li       $v0, SysAlloc
          syscall                              						
          move     $s2, $v0                      #Transfers the address of the memory to $s2
          move     $s3, $v0                      #Transfers the address of the memory to $s3
          li       $t0, 0				
fillArray:
          li       $t1, 0xff                     #Loads a register with 0xff (1111 1111)
          sb       $t1, ($s2)                    #Stores the value 0xff into memory $s2
          addi     $t0, $t0, 1                   #Increments the loop counter by 1
          addi     $s2, $s2, 1                   #Increments memory address by 1 
          bne      $t0, $s1, fillArray           #Branches if the loop counter does not equal number of bytes
          move     $s2, $s3                      #Transfer memory address from $s3 to $s2, resetting to starting value
          li       $s4, 2				
          li       $t0, 2
	
bitCounter:
          add      $t0, $t0, $s4                 #Increments bit counter
makeMask:
          li       $t2, 1  
          bgt      $t0, 7, XOR                   #Branch to XOR if bit counter($t7) is greater than 7
          lbu      $t1, ($s2)                    #Load byte from $s2 onto $t1                               
          sllv     $t2, $t2, $t0                 #Shift left by bit counter
          add      $t3, $t2, $t3                 #Add new mask to previous mask
          add      $t0, $t0, $s4                 #Increase bit counter by prime number
          j        makeMask                      #Keep looping makeMask until it braches out
XOR:
          lbu $t1, ($s2)                        #Load byte onto $t1 from memory $s2
          and $t2, $t1, $t3                      #Removes repeated prime
          xor $t1, $t1, $t2                      #Flip prime bit
          sb $t1, ($s2)                         #Store back into memory
          addi $t7, $t7, 1                      #Increase byte counter
          addi $s2, $s2, 1                      #Increase memory address by 1
          subi $t0, $t0, 8                      #reset bit counter
          li $t3, 0
          beq $t7, $s1, endLoop                 #Branch if byte counter = allocated bytes
          j makeMask                             #Loop back to makeMask until branch
resetVal:                                        #Resets the memory address and bit counter to its first position
          move $s2, $s3
          move $t0, $s4
nextPrime:
          bgt $t0, 7, nextByte                   #Branch if bit counter is > 7
          lbu $t1, ($s2)                         #Load byte onto $t1 from $s2
          addi $t0, $t0, 1                      #Increment bit counter 
          addi $s4, $s4, 1                      #Adds 1 until it finds the next prime
          srlv $t1, $t1, $t0                      #Shifts to bit after the prime number 
          and $t2, $t1, 1                      #determine prime
          beqz $t2, nextPrime           
          li $t7, 0
          j bitCounter                      #loops 
nextByte:                                            #Increments to the next byte after finding prim 
          srl $t6, $t0, 3
          add $s2, $s2, $t6
          and $t0, $t0, 7
          j nextPrime
endLoop:                                 #ends loop when it reaches n/2
          srl $t6, $s0, 1
          bgt $s4, $t6, resetByte
          j resetVal
resetByte:                                 #Prints starting case
          move $s2, $s3
          li $t0, 2
          move $t5, $t0
          li $v0, SysPrintString
          la $a0, primeNum
          syscall
printResult:                                 #Loops and prints every prime number until it reaches n
          beq $s0, $t5, terminate
          bgt $t0, 7, printNextByte
          lbu $t1, ($s2)
          addi $t0, $t0, 1
          addi $t5, $t5, 1
          srlv $t1, $t1, $t0
          and $t2, $t1, 1
          beqz $t2, printResult	
          li $v0, SysPrintInt
          move $a0, $t5
          syscall
          li $v0, SysPrintString
          la $a0, comma
          syscall
          j printResult
printNextByte:
          and $t0, $t0, 7                      #Put remainder of /8 without using division into bit counter
          addi $s2, $s2, 1	               #Increase memory address by 1
          j printResult			#Loops 
terminate: 
          li $v0, SysExit                        #Successifully terminates program
          syscall
invalidInt:
          li       $v0, SysPrintString           #Prints out the error message
          la       $a0, errorMsg
          syscall					
          j        askInteger                    #Jumps back to ask another valid integer




