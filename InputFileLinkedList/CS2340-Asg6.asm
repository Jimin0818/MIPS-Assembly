#Opens and reads a given file, then count reoccuring words in that given file through the use 
#of linked lists. Then prints the word, times of occurance, and which line the word occured in.   
#This is assignment #6 for CS2340, commented and written by Ji Min Yoon starting April 16th
#Net ID: JXY210022
         .include "Syscalls.asm"
         .eqv     letterct 32
         .eqv     lineLL 36
         .eqv     nextLL 40
         .eqv     questionSize 200
         .eqv     bufferSize 512
         .eqv     wordLLSize 44
         .eqv     lineLLSize 32
         .eqv     positionStart 1
         .eqv     toUpper 32
         .data 
question:.space 200
buffer:  .space 512
         .align 2
fileNameReq: .asciiz "File Name: " 
errorM:  .asciiz "Error, Please enter a valid file name\n"
newLine: .asciiz "\n"
textWord:.asciiz "Word: "
textCount:.asciiz "		Count: "
textLine:.asciiz "		Line: "
         
         .text 
main:
         li   $s2, 0 #Boolean value to check if its the first linked list created
#Gets file name from the user
askPrompt:
         la   $a0, fileNameReq
         li   $v0, SysPrintString       #Prints the prompt: "File Name: "
         syscall 
         la   $a0, question            #Loads address of input buffer into $a0
         li   $a1, questionSize        #Length of buffer
         li   $v0, SysReadString       #Loads user input(String) into $v0 
         syscall
         move $t1, $a0                 #Moves file addres into two registers
         move $t3, $a0
#Removes the invisible new line character from the inputted file name
removeNL:
         lb   $t2, ($t3)
         beq  $t2, '\n', openFile      #If the byte equals \n, then leave loop
         addi $t3, $t3, 1
         j    removeNL
#Opens the given file
openFile:
         sb   $zero, ($t3)             #Replaces the new line character with null terminator
         move $a0, $t1
         li   $a1, 0                    #Makes the file read only
         li   $v0, SysOpenFile
         syscall                       #Moves the file name to $a0, and opens the file 
         bltz $v0, errorMsg            #Branches to errorMsg if $v0 is negative; negative = invalid file name
         move $t0, $v0                 #Moves file descriptor in $t0
#Reads the given file
readFile: 
         move $a0, $t0                 #Move the file descriptor into $a0
         la   $a1, buffer
         li   $a2, bufferSize
         li   $v0, SysReadFile          
         syscall                       #Reads the file, and stores data into allocated space: buffer           
         move $s0, $a1                 #Moves address of buffer int0 $s0
         move $t1, $v0                 #Iteration counter; number of bytes read
closeFile:
         move $a0, $t0
         li   $v0, SysCloseFile
         syscall
#Initialize counters need for processing the file
processData:
         move $t6, $s0                 #Address of the buffer
         li   $t4, 0                   #Letter counter
         li   $s3, 1                   #Current line counter
         li   $s7, 0                   #Byte counter
         li   $s1, 0                   #Word counter; number of words linked list
#Process the file, separate each words into its own linked list 
processFile:
         lb   $t0, ($s0)               #Loads the first byte of the file into $t0
         beqz $t1, exitProcess        #Breaks loop when the iteration counters is zero; number of bytes left to read is zero
#Removes non valid characters
         beq  $t0, '-', isWord
         blt  $t0, '0', notWord 
         blt  $t0, ':', isWord
         blt  $t0, 'A', notWord
         blt  $t0, '[', isWord 
         blt  $t0, 'a', notWord
         blt  $t0, '{', isWord
notWord:
         bnez $t4, notWord2            #Makes sure it doesn't count two non valid characters as a word
         bne  $t0, '\n', skip          #Branch if $t0 is not a new line
         addi $s3, $s3, 1              #Increments the new line counter if $t0 is a new line character      
skip:
#If there are two non valid characters in a row, it increases the buffer address, and temp buffer address, and decrease 
#iteration counter
         addi $s0, $s0, 1 
         addi $t1, $t1, -1
         addi $t6, $t6, 1
         j    processFile
#Separating the words into its own linked list
notWord2:
         addi $s0, $s0, 1              #Increase buffer address
         addi $t1, $t1, -1             #Decrease iteration counter
         beqz $s2, isFirst1            #boolean: if its the first value, saves the register
afterIsFirst1:
         li   $a0, wordLLSize          #0= word, 32= count, 36= line pointer, 40= next pointer
         li   $v0, SysAlloc 
         syscall                       #Allocate space using sbrk for words linked list
         addi $s1, $s1, 1              #Incrase word counter
         move $t7, $t4                 #Moves number of letters to temp register
         beqz $s2, isFirst             #Another boolean: if its the first word, skips the next step
         sw   $v0, nextLL($t2)         #Stores the address of next linked list 
afterFirst:
         move $t2, $v0                 #Move address of linked list 
         li   $a0, lineLLSize  
         li   $v0, SysAlloc 
         syscall                       #Allocate space using sbrk for line position
         li   $t3, 1                  
         sb   $t3, ($v0)               #Stores 1 onto the first position; first position: times of occurance
         sb   $s3, positionStart($v0)  #Then stores the position 
         sw   $t4, letterct($t2)       #Store number of letters in the word linked list
         sw   $v0, lineLL($t2)             #Store address of line list in the word linked list
#Fills the words linked list with the word
fillWord:
         beqz $t4, endFillWord         #If the letter counter reaches zero, exit
         lb   $t5, ($t6)               #Loads the byte from the buffer
         blt  $t5,'[', dontConvert     #If the byte is upper case, then branch to dontConvert else continue 
         addi $t5, $t5, -toUpper       #Subtratcs 32 to make lower case letters into uppercase
dontConvert:
         sb   $t5, ($t2)                 #Stores the byte into word linked list
         addi $t2, $t2, 1              #Increment address of word linked list
         addi $t6, $t6, 1              #Increment address of temp buffer
         addi $t4, $t4, -1             #Decrease iteration counter
         j    fillWord                 #Jump back to fillWord until the whole word is transferred
endFillWord:
         sub  $t2, $t2, $t7            #Subtract the linked list by number to letters to put it at 0 position
         addi $t6, $t6, 1              #INcrement address of temp buffer
         j    processFile
#If it is valid character, increase word counter, buffer address, and byte counter and decrease iteration counter                                                                                                                                                                                                                  
isWord:
         addi $s0, $s0, 1              #Increase array 
         addi $t4, $t4, 1              #Word counter
         addi $t1, $t1, -1             #Decrease iteration 
         addi $s7, $s7, 1              #Byte counter
         j processFile  
checkRepeats:
         move $t0, $s5
         lw   $t5, letterct($s5)
         lw   $t1, nextLL($s5)
         lw   $t2, lineLL($s5)
checkR2:
         lb   $t3, ($s5)
         lb   $t4, ($t1)

#Prints out the results
exitProcess:
         lw   $t1, letterct($s5)       #Loads letter count
         lw   $t2, nextLL($s5)         #Loads nexr linked list address
         lw   $t4, lineLL($s5)         #Loasd line linked list address
         beqz $s7, bye                 #When the word count reaches zero, branch to bye
         la   $a0, textWord            
         li   $v0, SysPrintString    
         syscall                       #Prints statement" "Word: "
exit:
         addi $s7, $s7, -1             #Decrease total byte
         beqz $t1, next
#Prints out the word
         lb   $t3, ($s5)
         move $a0, $t3
         li   $v0, SysPrintChar
         syscall 
         addi $s5, $s5, 1              #Increase address
         addi $t1, $t1, -1             #Decrease letter counter
         j    exit 
next:
         la   $a0, textCount
         li   $v0, SysPrintString    
         syscall                       #Prints out statement: "COunt: "
#Loads the count from line linked list and prints
         lb   $t5, ($t4)
         move $a0, $t5
         li   $v0, SysPrintInt
         syscall 
         la   $a0, textLine
         li   $v0, SysPrintString    
         syscall                       #Prints out statement: "Line: " 
nextP:
         beqz $t5, end
         addi $t4, $t4, 1
         lb   $t6, ($t4)
         move $a0, $t6
         li   $v0, SysPrintInt
         syscall                       #Prints out the lines from line linked list
         addi $t5, $t5, -1
         j    nextP
end:
         la   $a0, newLine		
         li   $v0, SysPrintString
         syscall                       #Prints new line
         move $s5, $t2                 #Move the next linked list as current linked list
         j exitProcess
#Terminates program
bye: 
         li   $v0, SysExit
         syscall	
#Prints out error message    
errorMsg:
         la   $a0, errorM
         li   $v0, SysPrintString   
         syscall 
         j askPrompt
isFirst:
         move $t2, $v0                 #Saves the address of first linked list into $t2 and $s5
         move $s5, $t2
         addi $s2, $s2, 1              #Changes the boolean value 
         j    afterFirst
#Acts as a condition, skips certain code if boolean is true
isFirst1:
         j    afterIsFirst1
