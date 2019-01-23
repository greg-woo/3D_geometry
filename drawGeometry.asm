##
##  GREG WOO, 260777364
##

.data  # start data segment with bitmapDisplay so that it is at 0x10010000
.globl bitmapDisplay # force it to show at the top of the symbol table
bitmapDisplay:    .space 0x80000  # Reserve space for memory mapped bitmap display
bitmapBuffer:     .space 0x80000  # Reserve space for an "offscreen" buffer
width:            .word 512       # Screen Width in Pixels, 512 = 0x200
height:           .word 256       # Screen Height in Pixels, 256 = 0x100

lineCount   :     .space 4        # int containing number of lines
lineData:         .space 0x4800   # space for teapot line data
lineDataFileName: .asciiz "teapotLineData.bin"
errorMessage:     .asciiz "Error: File must be in directory where MARS is started."

# TODO: declare other data you need or want here!
testMatrix: .float 
1 2 3 4
5 6 7 8
9 10 11 12
13 14 15 16
testVec1: .float 1 0 0 0
testVec2: .float 4 1 3 0
testVec3: .float 0 0 1 0
testVec4: .float 0 0 0 1
testResult: .space 16

M: .float
331.3682, 156.83034, -163.18181, 1700.7253
-39.86386, -48.649902, -328.51334, 1119.5535
0.13962941, 1.028447, -0.64546686, 0.48553467
0.11424224, 0.84145665, -0.52810925, 6.3950152

R: .float
 0.9994 0.0349 0 0
-0.0349 0.9994 0 0
0 0 1 0
0 0 0 1


.text

##################################################################
# main entry point
# We will use save registers here without saving and restoring to
# the stack only because this is the main function!  All other 
# functions MUST RESPECT REGISTER CONVENTIONS
main:	la $a0 lineDataFileName
	la $a1 lineData
	la $a2 lineCount
	jal loadLineData
	la $s0 lineData 	# keep buffer pointer handy for later
	la $s1 lineCount
	lw $s1 0($s1)	   	# keep line count handy for later

	# TODO: write your test code here, as well as your final 
	# animation loop.  We will likewise test individually 
	# the functions that you implement below.
	#addi $t0, $zero, 0x00ff0000
	
	
	#add $a0 $zero
	#jr $ra	
	#li $a0 8
	#li $a1 30
	#jal drawPoint
	
	
	##Tester for clear and copy
	#li $a0, 0x00ff0000
	#jal clearBuffer
	#jal copyBuffer
	#li $a0, 0x00000000
	#jal clearBuffer
	#jal copyBuffer

	
	### Tester for draw point
	#li $a0 543
	#li $a1 123
	#jal drawPoint
	
	### Tester for draw line
	#li $a0 10
	#li $a1 10
	#li $a2 500
	#li $a3 250
	#jal drawLine
	
	### Tester for matrix mult
	#la $a0 testMatrix 
	#la $a1 testVec1
	#la $a2 testVec2
	#jal mulMatrixVec
	
	
loopFinal: 
	li $a0, 0x00000000 # setting color to black
	jal clearBuffer
	
	move $a0, $s0 # initializing for draw3D
	move $a1, $s1
	jal draw3DLines
	jal copyBuffer
	
	move $a0, $s0 # initializing for rotate
	move $a1, $s1
	jal rotate3DLines
	
	j loopFinal # repeat loop
	
	li $v0, 10      # load exit call code 10 into $v0
	syscall         # call operating system to exit
        
        

###############################################################
# void clearBuffer( int colour )
clearBuffer:	
		addi $sp $sp -12 # save space on stack
		sw $ra 0($sp) # return address
		
		sw $s0, 4($sp)
		sw $s1, 8($sp)

		la $s0, bitmapBuffer # setting s0 equal to first bit
		addi $s1, $s0, 0x80000 # for comparison

clearBufferLoop:
		bge $s0, $s1 done # if s0 matches s1 (s1 = s0 + 0x80000) then stop
		sw $a0, ($s0) # store colour into buffer
		addi $s0 $s0 4 # increment buffer by 4
		# we now repeat this for a total of 16 times
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		sw $a0, ($s0)
		addi $s0 $s0 4
		j clearBufferLoop
		
done:		lw $ra, 0($sp)
		
		# restore save registers
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		
		addi $sp $sp 12 # restore stack
		
		jr $ra

###############################################################
# copyBuffer()
copyBuffer:
		la $t0, bitmapBuffer # t0 has the buffer address
		la $t1, bitmapDisplay # t1 has the dislay address
		li $t2, 0x80000 # for comparison
		li $t3, 0 # t3 as our counter 
	
copyBufferLoop: 
		lw $t7, ($t0) # load first buffer colour
		sw $t7, ($t1)  # putting that colour on our display
		# we now repeat this
		lw $t7, 4($t0)
		sw $t7, 4($t1) 
		lw $t7, 8($t0)
		sw $t7, 8($t1) 
		lw $t7, 12($t0)
		sw $t7, 12($t1) 
		lw $t7, 16($t0)
		sw $t7, 16($t1) 
		
		addi $t0, $t0, 16 # increment buffer
		addi $t1, $t1, 16 # increment display
		addi $t3, $t3, 16 # increment our counter t3
		
		bne $t3, $t2, copyBufferLoop # if our counter hasn't reach the max then we loop
		jr $ra
		
###############################################################
# drawPoint( int x, int y ) 
drawPoint: 	addi $sp $sp -12 # save space on stack
		sw $ra 0($sp) # return address
		
		sw $s0, 4($sp)
		sw $s1, 8($sp)

		sltiu $t0, $a0, 512 # checking bounds for x
		beq $t0, $0, done2
		sltiu $t1, $a1, 256 # checking bounds for y
		beq $t1, $0, done2
		
		addi $t3, $0, 0x0000ff00 # setting temp3 = green
		addi $t4, $0, 512 # setting temp4 = width
		
		# we have to do b + 4(x + wy)
		mult $t4, $a1	# z = wy
		mflo $t6
		add $t5, $a0, $t6 # a = x + z
		addi $t4, $0, 4 # resetting t4 to 4
		mult  $t5, $t4 # d = a * 4
		mflo $t6
		addi $t4, $t6, 0x10090000 # d + b
		sw $t3, ($t4) #store green at memory location t4
	
done2:		# restore save registers
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		
		addi $sp $sp 12 # restore stack
		
		jr $ra	
		
###############################################################
# void drawline( int x0, int y0, int x1, int y1 )
drawLine:
		addi $sp $sp -32 # save space on stack
		sw $ra 0($sp) # return address

		sw $s0, 4($sp) # offsetX
		sw $s1, 8($sp) # offsetY
		
		sw $s2, 12($sp) # x
		sw $s3, 16($sp) # y
		
		sw $s4, 20($sp) # dX
		sw $s5, 24($sp) # dY
		sw $s6, 28($sp) # error

		addi $s0, $0, 1 # offsetx = 1
		addi $s1, $0, 1 # offsety = 1

		add $s2, $0, $a0 # x = x0
		add $s3, $0, $a1 # y = y0

		sub $s4, $a2, $a0 # dx = x1 - x0
		sub $s5, $a3, $a1 # dy = y1 - y0
		#add $s3, $0, $t3 # copy dx into s3
		#add $s4, $0, $t4 # copy dy into s4

		slt $t0, $s4, $0 # if dx < 0 than t0 = 1
		beq $t0, $0, dxNegElse  # if t0 != 1, then skip the following steps
			sub $s4, $0, $s4 # dx = -dx
			add $s0, $0, -1 # offsetx = -1

dxNegElse:	slt $t0, $s5, $0 # if dy < 0 than t0 = 1
		beq $t0, $0, dyNegElse  # if t0 != 1, then skip the following steps
			sub $s5, $0, $s5 # dy = -dy
			add $s1, $0, -1 # offsety = -1

dyNegElse:	add $a0, $s2, $0 # initializing argument 0
		add $a1, $s3, $0 # initializing argument 1

		jal drawPoint # calling drawpoint with x,y as args

		slt $t0, $s5, $s4 # if s5 < s4 / dy < dx
		beq $t0, $0, dyBigger # if dy >= dx then go to dyBigger
			add $s6, $s4, $0 # error = dx
			beq $s2, $a2, done3 # checks if we have to go through the loop
whileXneX1:		sub $t1, $0, $s5
			sub $t1, $t1, $s5 # t1 = - 2* dy
			add $s6, $s6, $t1 # error = error - 2*dy

			slt $t1, $s6, $0 # if (error < 0)
			beq $t1, $0, errorPos1 # error is positive
				add $s3, $s3, $s1 # y = y + offsetY
				add $t6, $0, $s4
				add $t6, $t6, $s4 # t6 = 2*dx
				add $s6, $s6, $t6 # error = error + 2*dx
errorPos1:		add $s2, $s2, $s0 # x = x + offsetX
			add $a0, $0, $s2 # initializing argument 0
			add $a1, $0, $s3 # initializing argument 1
			jal drawPoint # calling drawpoint with x,y as args
			bne $s2, $a2, whileXneX1 # checks if we have to go through the loop again
			j done3 # function is done
			
dyBigger:		add $s6, $s5, $0 # error = dy
			beq $s3, $a3, done3 # checks if we have to go through the loop
whileYneY1:		sub $t1, $0, $s4
			sub $t1, $t1, $s4 # t1 = - 2* dx
			add $s6, $s6, $t1 # error = error - 2*dx

			slt $t1, $s6, $0 # if (error < 0)
			beq $t1, $0, errorPos2 # error is positive
				add $s2, $s2, $s0 # x = x + offsetX
				add $t6, $0, $s5
				add $t6, $t6, $s5 # t6 = 2*dy
				add $s6, $s6, $t6 # error = error + 2*dy
errorPos2:		add $s3, $s3, $s1 # y = y + offsetY
			add $a0, $0, $s2 # initializing argument 0
			add $a1, $0, $s3 # initializing argument 1
			jal drawPoint # calling drawpoint with x,y as args
			bne $s3, $a3, whileYneY1 # checks if we have to go through the loop again
			j done3 # function is done

done3:		lw $ra, 0($sp)

		addi $t0, $0, 0
		addi $t1, $0, 0
		addi $t6, $0, 0

		# restore save registers
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp)
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		
		addi $sp $sp 32 # restore stack

		jr $ra
		
###############################################################

# void mulMatrixVec( float* M, float* vec, float* result )
mulMatrixVec:
		lwc1 $f4, ($a0) ### 1 row ###
		lwc1 $f6, ($a1) 
		mul.s $f8,$f4,$f6
		
		lwc1 $f4, 4($a0) # loading matrix unit
		lwc1 $f6, 4($a1) # loading vector unit
		mul.s $f10,$f4,$f6 # multiplying them together
		add.s $f8, $f10, $f8 # adding the result to f8
		
		lwc1 $f4, 8($a0) 
		lwc1 $f6, 8($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		lwc1 $f4, 12($a0) 
		lwc1 $f6, 12($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		swc1 $f8, 0($a2) # save first row
		
		lwc1 $f4, 16($a0) ### 2 row ###
		lwc1 $f6, 0($a1)
		mul.s $f8,$f4,$f6
		
		lwc1 $f4, 20($a0) 
		lwc1 $f6, 4($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		lwc1 $f4, 24($a0) 
		lwc1 $f6, 8($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8
		
		lwc1 $f4, 28($a0)
		lwc1 $f6, 12($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		swc1 $f8, 4($a2) # save 2 row
		
		lwc1 $f4, 32($a0) ### 3 row ###
		lwc1 $f6, 0($a1)
		mul.s $f8,$f4,$f6
		
		lwc1 $f4, 36($a0)
		lwc1 $f6, 4($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8
		
		lwc1 $f4, 40($a0) 
		lwc1 $f6, 8($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8
		
		lwc1 $f4, 44($a0) 
		lwc1 $f6, 12($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		swc1 $f8, 8($a2) # save 3 row
		
		lwc1 $f4, 48($a0) ### 4 row ###
		lwc1 $f6, 0($a1)
		mul.s $f8,$f4,$f6
		
		lwc1 $f4, 52($a0) 
		lwc1 $f6, 4($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		lwc1 $f4, 56($a0) 
		lwc1 $f6, 8($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8
		
		lwc1 $f4, 60($a0)
		lwc1 $f6, 12($a1)
		mul.s $f10,$f4,$f6
		add.s $f8, $f10, $f8 
		
		swc1 $f8, 12($a2) # save 4 row

		jr $ra
		
###############################################################
# (int x,int y) = point2Display( float* vec )
point2Display: 	
		lwc1 $f0, ($a0) # x
		lwc1 $f1, 4($a0) # y
		lwc1 $f2, 8($a0) # z
		lwc1 $f3, 12($a0) # w
		
		div.s $f4, $f0, $f3 # x/w
		div.s $f5, $f1, $f3 # y/w
		
		cvt.w.s $f4, $f4 # converting to word
		cvt.w.s $f5, $f5 # converting to word
		
		mfc1 $v0, $f4 # move from c1
		mfc1 $v1, $f5 # move from c1

		jr $ra
        
###############################################################
# draw3DLines( float* lineData, int lineCount )
draw3DLines:		
		addi $sp $sp -32 # save space on stack
		sw $ra  0($sp) # return address
	
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp) 
		sw $s3, 16($sp)
		sw $s4, 20($sp)
		sw $s5, 24($sp)
		sw $s6, 28($sp)
	
		# initializing s0 to s4
		la   $s0, ($a0) # s0 = lineData
		addi $s1, $a1, 0 # s1 = lineCount
		la   $s2, M # matrix M
		la   $s3, testResult # vector result
		li   $s4, 0 # counter
	
		slt $t0, $s4, $s1 # checking if counter is less than lineCount
		beq $t0, $0, done4 # if counter is bigger then end
	
draw3DLoop: 	
		la $a0, ($s2) # initializing args for mulMatrixVec
		la $a1, ($s0)
		la $a2, ($s3) 
		jal mulMatrixVec
	
		la $a0, ($s3) # using result vec for point2Display
		jal point2Display 
	
		add $s5, $v0, $0 # storing return values for drawLine
		add $s6, $v1, $0
			
		la $a0, ($s2) # initializing args for mulMatrixVec
		la $a1, 16($s0)
		la $a2, ($s3) 
		jal mulMatrixVec
	
		la $a0, ($s3) # using result vec for point2Display
		jal point2Display
	
		add $a0, $s5, $0 # initializing args for drawLine
		add $a1, $s6, $0 
		add $a2, $v0, $0
		add $a3, $v1, $0
		jal drawLine
			
		la $s0, 32($s0) # preparing for next loop
		addi $s4, $s4, 1 
		
		bne $s1, $s4, draw3DLoop # checking if reloop or not
	
done4:	
		lw $ra, 0($sp)
		
		# restore save registers
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		lw $s4, 20($sp) 
		lw $s5, 24($sp)
		lw $s6, 28($sp)
		
		addi $sp, $sp, 32 # restore stack
		
       		jr $ra
       	
###############################################################
# rotate3DLines( float* lineData, int lineCount )
rotate3DLines:
		addi $sp $sp -20 # save space on stack
		sw $ra  0($sp) # return address
	
		sw $s0, 4($sp)
		sw $s1, 8($sp)
		sw $s2, 12($sp)
		sw $s3, 16($sp)
	
		la $s0, lineData # s0 = lineData
		lw $s1, lineCount # s1 = lineCount
		la $s2, R # matrix R
		li $s3, 0 # counter
	
		slt $t0, $s3, $s1 # checking if counter is less than lineCount
		beq $t0, $0, done5 # if counter is bigger then end
	
rotate3DLoop: 	
		la $a0, ($s2) # initializing args for mulMatrixVec
		la $a1, ($s0)
		la $a2, ($a1) 
		jal mulMatrixVec
			
		la $a0, ($s2) # initializing args for mulMatrixVec by shifting by 16 the vectors
		la $a1, 16($s0)
		la $a2, 16($s0) 
		jal mulMatrixVec
			
		la $s0, 32($s0) # shifting to next line
		addi $s3, $s3, 1 # readjusting counter
		
		bne $s1, $s3, rotate3DLoop # checking if reloop or not

done5:
		lw $ra, 0($sp)
		
		# restore save registers
		lw $s0, 4($sp)
		lw $s1, 8($sp)
		lw $s2, 12($sp)
		lw $s3, 16($sp)
		
		addi $sp, $sp, 20 # restore stack
		
		jr $ra 
 
###############################################################
# void loadLineData( char* filename, float* data, int* count )
#
# Loads the line data from the specified filename into the 
# provided data buffer, and stores the count of the number 
# of lines into the provided int pointer.  The data buffer 
# must be big enough to hold the data in the file being loaded!
#
# Each line comes as 8 floats, x y z w start point and end point.
# This function does some error checking.  If the file can't be opened, it 
# forces the program to exit and prints an error message.  While other
# errors may happen on reading, note that no other errors are checked!!  
#
# Temporary registers are used to preserve passed argumnets across
# syscalls because argument registers are needed for passing information
# to different syscalls.  Temporary usage:
#
# $t0 int pointer for line count,  passed as argument
# $t1 temporary working variable
# $t2 filedescriptor
# $t3 number of bytes to read
# $t4 pointer to float data,  passed as an argument
#
loadLineData:	move $t4 $a1 		# save pointer to line count integer for later		
		move $t0 $a2 		# save pointer to line count integer for later
			     		# $a0 is already the filename
		li $a1 0     		# flags (0: read, 1: write)
		li $a2 0     		# mode (unused)
		li $v0 13    		# open file, $a0 is null-terminated string of file name
		syscall			# $v0 will contain the file descriptor
		slt $t1 $v0 $0   	# check for error, if ( v0 < 0 ) error! 
		beq $t1 $0 skipError
		la $a0 errorMessage 
		li $v0 4    		# system call for print string
		syscall
		li $v0 10    		# system call for exit
		syscall
skipError:	move $t2 $v0		# save the file descriptor for later
		move $a0 $v0         	# file descriptor (negative if error) as argument for write
  		move $a1 $t0       	# address of buffer to which to write
		li  $a2 4	    	# number of bytes to read
		li  $v0 14          	# system call for read from file
		syscall		     	# v0 will contain number of bytes read
		
		lw $t3 0($t0)	     	# read line count from memory (was read from file)
		sll $t3 $t3 5  	     	# number of bytes to allocate (2^5 = 32 times the number of lines)			  		
		
		move $a0 $t2		# file descriptor
		move $a1 $t4		# address of buffer 
		move $a2 $t3    	# number of bytes 
		li  $v0 14           	# system call for read from file
		syscall               	# v0 will contain number of bytes read

		move $a0 $t2		# file descriptor
		li  $v0 16           	# system call for close file
		syscall		     	
		
		jr $ra 