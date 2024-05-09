#Sorts and determines the number of input, sum, and the average of given double precision numbers
#by the user through the use of a function, then prints.  
#This is assignment #5 for CS2340, commented and written by Ji Min Yoon starting March 22th
#Net ID: JXY210022

         .include  "Syscalls.asm"
         .eqv      buffSize 800
         .eqv      stackSize 8
         .eqv      nextWord 8
         .eqv      return 0
         .eqv      numOfInput 4
         .data
buffer:  .space    buffSize
         .align    2
zero:    .double   0.0
prompt:  .asciiz   "Enter Double-Precision Numbers(0 to exit)\n"  
sortL:   .asciiz   "Sorted List:\n"  
count:   .asciiz   "Count: "  
avg:     .asciiz   "Average: "
sum:     .asciiz   "Sum: "
newLine: .asciiz   "\n"	
         .globl    main
         .text

#Asks user for a double-precision number. If the input is zero, then exit loop else store the inout into
#memory. Also counts how many numbers were inputed. (Excluding the zero)
main:
         li        $v0, SysPrintString           #Prints out the statement: "Enter Double-Precision Numbers(0 to exit)\n"   
         la        $a0, prompt
         syscall 
         la        $a0, buffer                   #Loads buffer memory address into $a0
         li        $a1, buffSize                 #Allocates buffSize(800) bytes of memory for buffer 
         move      $s0, $a0                      #Moves the memeory address of the buffer into $s0
         move      $t0, $a0                      #Moves the memory address of the buffer into $t0
         li        $s1, 0                        #Initizalizing the counter for number of inputs
         l.d       $f6, zero                     #Loads zero(double 0.0) into $f6
         
#Asks the user for input, exits loop when the user input is zero. Counts the number of user input.
askInput:
         li        $v0, SysReadDouble            #Reads user input (double), and stores in $f0
         syscall 
         c.eq.d    $f0, $f6                      #Compares if the inputed float ($f0) is equal to zero ($t6)
         bc1t      DONE                          #Branches to DONE, if the comparison results in TRUE
         s.d       $f0, 0($t0)                   #Stores double into the buffer 
         addi      $t0, $t0, nextWord            #Increments the memory address by nextWord(8)
         addi      $s1, $s1, 1                   #Increments the counter (number of inputs) by 1
         j         askInput                      #Loops until the user inputs zero

#Calls the sort and print function through jump and link (jal)
DONE:	
         move      $a0, $s1                      #Moves the number of input ($s1) into $a0
         move      $a1, $s0                      #Moves the memory address of buffer($s0) into $a1
         jal       sort                          #Calls the sort function 
         move      $a0, $s1                      #Moves the number of input ($s1) into $a0
         move      $a1, $s0                      #Moves the memory address of buffer($s0) into $a1
         jal       print                         #Calls the print function

#Successifully terminates the program	
terminate: 	
         li        $v0, SysExit
         syscall	
    
#The print function
#Allocates stack, store return address and number of input into the stack. Prints out string. 
print:
         add       $sp, $sp, -stackSize          #Allocates stackSize (8) bytes of memeory for the stack
         sw        $ra, return($sp)              #Stores the return address into return (0) position of the stack
         sw        $a0, numOfInput($sp)          #Stores the number of input into the numOfInput (4) position of the stack       
         move      $t0, $a0                      #Moves number of inputs into $t0 register
         move      $t1, $a1                      #Moves memory address of buffer into $t1 register
         li        $v0, SysPrintString           #Prints out the statement: "Sorted List:\n"     	
         la        $a0,sortL     	  
         syscall 
         
#Prints out the contents of the sorted list. Calculate the sum.        	
printSort:
         beq       $t0, 0 , printCount           #Branches to printCount if $t0 = 0; 	  			
         l.d       $f12, 0($t1)                  #Loads to double from buffer into $f12
         li        $v0, SysPrintDouble           #Print double precision number in $f12
         syscall
         li        $v0, SysPrintString           #Prints out newLine	   
         la        $a0, newLine     	
         syscall      	
         add.d     $f20, $f20, $f12              #Adds double in $f12 into $f20
         addi      $t1, $t1, nextWord            #Adds nextWord (8) into the memory address of buffer
         addi      $t0, $t0, -1                  #Decrements the loop counter by 1
         j         printSort                     #Loops until the $t0 register reaches zero

#Prints the number of input
printCount:
         lw        $t0, numOfInput($sp)          #Loads the number of input into $t0 
         li        $v0, SysPrintString           #Prints out the statement: "Count: "      	
         la        $a0, count     	
         syscall         	 
         li        $v0, SysPrintInt              #Prints out the number of inputs entered
         move      $a0, $t0
         syscall
         li        $v0, SysPrintString           #Prints out newLine	   
         la        $a0, newLine     	
         syscall   

#Prints the sum of entered values
printSum: 
         li        $v0, SysPrintString           #Prints out the statement: "Sum: "       	   
         la        $a0, sum     	
         syscall         	
         mov.d     $f12, $f20                    #Prints out the sum calculated in the printSort function above
         li        $v0, SysPrintDouble
         syscall
         li        $v0, SysPrintString           #Prints out newLine	   
         la        $a0, newLine     	
         syscall   

#Prints the average of entered values
printAvg:
         li        $v0, SysPrintString           #Prints out the statement: "Average: "     	 
         la        $a0, avg     	
         syscall         	
         mtc1      $t0, $f26                     #Moves the number of input ($t0) into $f26
         cvt.d.w   $f26, $f26                    #Converts the number of inputs (Integer) into a double
         div.d     $f12, $f20, $f26              #Divide the sum ($f20) by number of inputs ($f26) and store in $f12
         li        $v0, SysPrintDouble           #Prints the average of values stored in $f12
         syscall 

#Loads back return address and number of inputs, deallocates stack, and jump back to the return address
printEnd: 
         lw        $ra, return($sp)              #Loads the return address back into $ra from the stack
         lw        $a0, numOfInput($sp)          #Loads the number of input back into $a0 from the stack
         add       $sp, $sp, stackSize           #Deallocates stackSize (8) bytes of memeory for the stack
         jr        $ra

#Sort function
sort:
         add       $sp, $sp, -stackSize          #Allocates stackSize (8) bytes of memeory for the stack
         sw        $ra, return($sp)              #Stores the return address into return (0) position of the stack
         sw        $a0, numOfInput($sp)          #Stores the number of input into the numOfInput (4) position of the stack    
         move      $t1, $a0                      #Moves the number of input into $t1 register
         
#Moves to the next loop of the bubble sort
nextLoop:	
         addi      $t1, $t1, -1                  #Decrement $t1 by 1; number of loops		
         beq       $t1, 0, exitSort              #Branch to exitSort if $t1 = 0
         move      $t6, $a1                      #Moves memory address of buffer into $t6
         move      $t4, $t1                      #Moves the loop counter into temporary register $t4
	
#Compares [i] and [i+1]
compareWord:	
         l.d       $f4, 0($t6)                   #Loads [i] of the buffer into $f4
         l.d       $f6, nextWord($t6)            #Loads [i + 1] of the buffer into $f6
         c.le.d    $f4, $f6                      #Compares $f4 is less than $f6 (buffer[j]<buffer[j+1])
                                                 #Returns true if $f4 is less than $f6
         bc1t      nextPosition                  #Branches to nextPosition if the above code returns true

#The contents in [i] and [i+1] switches	
switch: 
         l.d       $f10, 0($t6)                  #Loads [i] into $f10				
         l.d       $f12, nextWord($t6)           #Loads [i+1] into $f12		
         s.d       $f10, nextWord($t6)           #Stores the value of [i] ($f10) into [i + 1] position 	
         s.d       $f12, 0($t6)	                 #Stores the value of [i + 1] ($f12) into [i] position 	
         
#Moves to the next position of the buffer 					
nextPosition:
         
         addi      $t4, $t4, -1                  #Decrements $t4 by 1; the position counter
         beq       $t4, 0, nextLoop              #Branches to nextLoop if the $t4 (Position counter) = 0 (Reaches end of buffer)
         add       $t6, $t6, nextWord            #Incresease the buffer memory address by nextWord (8) 
         j         compareWord                   #Loops until $t4 reaches 0
         
#Loads back return address and number of inputs, deallocates stack, and jump back to the return address	
exitSort:
         lw        $ra, return($sp)              #Loads the return address back into $ra from the stack
         lw        $a0, numOfInput($sp)          #Loads the number of input back into $a0 from the stack
         add       $sp, $sp, stackSize          #Deallocates stackSize (8) bytes of memeory for the stack
         jr        $ra

 

	
