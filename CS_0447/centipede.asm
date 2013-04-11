# Centipede in MIPS
#
.data 

	playerPos: .word 32
	
	sleepLength: .word 20
	
	lastKey: .word 0
	
	score: .word 0
	
	scoreStr: .asciiz "You lost! Your score is: "
	
	# Bullet Layout:
	# AA BB CC XX
	# AA = exists (0/1)
	# BB = x coordinate
	# CC = y coordinate
	bullet1:	.word 0x00000000
	bullet2:	.word 0x00000000
	
	# Centipede Byte Layout:
	# AA BB CC XX (hex)
	# AA = active (0/1)
	# BB = x coordinate
	# CC = y coordinate
	centipede:	.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
			.word 0x00000000
	centipedeEnd:	.word 0x00000000
	
.text
	jal _seedRNG
	
	jal _clearBoard
	jal _createCent
	
	li $a0, 10
	jal _setRandomMushrooms
	
	li $s0, 0	# $s0 = Move centipede counter
	
main_loop:
	jal _readKey
	
	jal _movePlayer
	jal _redrawPlayer
	
	jal _fireBullet
	
	la $a0, bullet1
	jal _moveBullet
	
	la $a0, bullet2
	jal _moveBullet
	
	blt $s0, 9, main_skipCent # only move centipede every 10 ticks
	li $s0, 0 # reset counter

	la $a0, centipede
	jal _moveCent
main_skipCent:
	
	jal _didWin
	beq $v0, 0, main_didntWin
	## Won ##
	
	jal _createCent # create new centipede
	
	li $a0, 5
	jal _setRandomMushrooms # add 5 new mushrooms
	
	lw $a0, score
	add $a0, $a0, 100
	sw $a0, score # increase score
	
	lw $a0, sleepLength # Update delay
	ble $a0, 4, main_didntWin
	subi $a0, $a0, 2
	sw $a0, sleepLength
main_didntWin:

	jal _didLose
	beq $v0, 0, main_didntLose
	## Lost ##
	
	la $a0, scoreStr
	li $v0, 4
	syscall # Print score string
	
	lw $a0, score
	li $v0, 1
	syscall # Print score
	
	li $v0, 10
	syscall # Exit program
main_didntLose:

	lw $a0, sleepLength # Sleep
	li $v0, 32
	syscall
	
	add $s0, $s0, 1
	j main_loop # continue main loop
	
	li $v0, 10 # exit program
	syscall

# --------------------------------

# FUNCTION clearBoard()
# Preserves: $t
_clearBoard:
	# Prologue
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$t0, 4($sp)
	sw	$t1, 8($sp)

	li $t0, 0 # pixel x
	li $t1, 0 # pixel y

_clearBoard_loop:
	move $a0, $t0
	move $a1, $t1
	li $a2, 0
	jal _setLED # set LED color
	
	add $t0, $t0, 1
	blt $t0, 64, _clearBoard_loop
	
	li $t0, 0
	add $t1, $t1, 1
	blt $t1, 64, _clearBoard_loop
	
	# Epilogue
	lw	$ra, 0($sp)
	lw	$t0, 4($sp)
	lw	$t1, 8($sp)
	addi	$sp, $sp, 4
	jr $ra

# --------------------------------

# FUNCTION createCent()
# Preserves: $t
_createCent:
	# Prologue
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$t0, 4($sp)

	li $t0, 0
	la $t1, centipede
	
_createCent_loop:
	li $a0, 1
	sb $a0, 0($t1) # Active to 1
	
	li $a1, 9
	sub $a1, $a1, $t0
	sb $a1, 1($t1) # X coordinate (9-$t0)
	
	sb $zero, 2($t1) # Y coordinate to 0
	
	lb $a0, 1($t1)
	li $a1, 0
	li $a2, 1
	jal _setLED # Set pixel

	addi $t0, $t0, 1
	addi $t1, $t1, 4
	
	blt $t0, 10, _createCent_loop

	# Epilogue
	lw	$ra, 0($sp)
	lw	$t0, 4($sp)
	addi	$sp, $sp, 8
	jr $ra

# --------------------------------

# FUNCTION destroyCentipede($a0, $a1)
# $a0 = X coord of centipede block
# $a1 = Y coord of centipede block
# Preserve: $t
_destroyCentipede:
	# Prologue
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	la $s0, centipede
	la $s1, centipedeEnd
	
_destroyCentipede_loop:
	lb $a2, 1($s0)
	lb $a3, 2($s0)
	
	bne $a0, $a2, _destroyCentipede_notBlock
	bne $a1, $a3, _destroyCentipede_notBlock
	
	# Found centipede
	li $a2, 0
	jal _setLED
	
	sw $zero, 0($s0)
	j _destroyCentipede_exit
	
_destroyCentipede_notBlock:
	add $s0, $s0, 4
	ble $s0, $s1, _destroyCentipede_loop
	
_destroyCentipede_exit:
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr $ra

# --------------------------------

# FUNCTION didLose()
# Returns: $v0 = Did lose (0/1)
# Preserves: $t
_didLose:
	# Prologue
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	la $s0, centipede
	la $s1, centipedeEnd
	
	li $v0, 0 # default to win
	
_didLose_loop:
	lb $a0, 2($s0)
	
	beq $a0, 60, _didLose_lost
	
	add $s0, $s0, 4
	ble $s0, $s1, _didLose_loop
	
	j _didLose_exit
	
_didLose_lost:
	li $v0, 1
_didLose_exit:
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr $ra
	
# --------------------------------

# FUNCTION didWin()
# Returns: $v0 = Did win (0/1)
# Preserves: $t
_didWin:
	# Prologue
	addi	$sp, $sp, -12
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	
	la $s0, centipede
	la $s1, centipedeEnd
	
	li $v0, 1 # default to win
	
_didWin_loop:
	lb $a0, 0($s0)
	
	beq $a0, 1, _didWin_false
	
	add $s0, $s0, 4
	ble $s0, $s1, _didWin_loop
	
	j _didWin_exit
	
_didWin_false:
	li $v0, 0
_didWin_exit:
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	addi	$sp, $sp, 12
	jr $ra
	
# --------------------------------

# FUNCTION findCentEnd($a0, $a1)
# $a0 = Pointer to centipede
# $a1 = Pointer to end of centipede
# Returns: $v0 = Pointer to last centipede segment
# Preserves: $t
_findCentEnd:
	# Prologue
	addi	$sp, $sp, -8
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	
	move $t0, $a0
	move $t1, $a1 # Save arguments
	
_findCentEnd_loop:
	addi $t0, $t0, 4 # Increment
	
	bgt $t0, $t1, _findCentEnd_exit # Break if after end
	
	lb $a0, 0($t0)
	beq $a0, 0, _findCentEnd_exit # Break if inactive

	j _findCentEnd_loop
	
_findCentEnd_exit:
	subi $v0, $t0, 4

	# Epilogue
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	addi	$sp, $sp, 8
	jr $ra

# --------------------------------

# FUNCTION findNextLocation($a0, $a1)
# $a0 = Pointer to centipede
# $a1 = Pointer to end of centipede
# Returns: $v0 = New X
# Returns: $v1 = New Y
# Preserves: $t
_findNextLocation:
	# Prologue
	addi	$sp, $sp, -20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)
	
	move $s0, $a0 # new X
	move $s1, $a1 # new Y
	move $s2, $a0 # old X backup
	move $s3, $a1 # old Y backup
	
	andi $a0, $s1, 0x1 # $a0 = 0 (even row) or 1 (odd row)
	
	beq $a0, 1, _findNextLocation_oddRow
	
_findNextLocation_evenRow:
	beq $s0, 63, _findNextLocation_dropDown
	
	addi $s0, $s0, 1
	
	j _findNextLocation_mushroomCheck
	
_findNextLocation_oddRow:
	beq $s0, 0, _findNextLocation_dropDown
	
	subi $s0, $s0, 1
	
	j _findNextLocation_mushroomCheck

_findNextLocation_mushroomCheck:
	move $a0, $s0
	move $a1, $s1
	jal _getLED
	
	beq $v0, 3, _findNextLocation_dropDown
	j _findNextLocation_exit
	
_findNextLocation_dropDown:
	move $s0, $s2
	addi $s1, $s3, 1
	
	move $a0, $s0
	move $a1, $s1
	jal _getLED
	
	bne $v0, 1, _findNextLocation_exit # if drop worked, exit
	
	move $s0, $s2
	move $s1, $s3
	
_findNextLocation_exit:
	move $v0, $s0
	move $v1, $s1
	
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	addi	$sp, $sp, 20
	jr $ra

# --------------------------------

# FUNCTION fireBullet()
# Preserves: $t
_fireBullet:
	# Prologue
	addi	$sp, $sp, -4
	sw	$ra, 0($sp)
	
	lw $a0, lastKey
	
	bne $a0, 0xE0, _fireBullet_exit # skip if not up arrow
	
	la $a0, bullet1
	lb $a1, 0($a0)
	beq $a1, 0, _fireBullet_good
	
	la $a0, bullet2
	lb $a1, 0($a0)
	beq $a1, 0, _fireBullet_good
	
	j _fireBullet_exit
	
_fireBullet_good:

	li $a1, 1
	sb $a1, 0($a0) # bullet used
	lw $a2, playerPos
	sb $a2, 1($a0) # bullet x
	li $a3, 61
	sb $a3, 2($a0) # bullet y

	move $a0, $a2
	move $a1, $a3
	li $a2, 2
	jal _setLED
	
_fireBullet_exit:
	# Epilogue
	lw	$ra, 0($sp)
	addi	$sp, $sp, 4
	jr $ra

# --------------------------------

# FUNCTION moveBullet($a0)
# $a0 = Pointer to bullet
# Preserve: $t
_moveBullet:
	# Prologue
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$t0, 4($sp)
	sw	$s0, 8($sp)
	sw	$s1, 12($sp)
	
	move $t0, $a0		# $t0 = Pointer to bullet
	
	lb $s0, 0($t0) # Check if bullet exists
	beq $s0, 0, _moveBullet_exit
	
	lb $s0, 1($t0)		# $s0 = Bullet X
	lb $s1, 2($t0)		# $s1 = Bullet Y

	### Top ###
	bne $s1, 0, _moveBullet_notTop # Destroy bullet if at top
	j _moveBullet_destroy
_moveBullet_notTop:
	
	move $a0, $s0
	subi $a1, $s1, 1
	jal _getLED # Check LED to see if it hit something
	
	beq $v0, 1, _moveBullet_hitCent
	beq $v0, 3, _moveBullet_hitMushroom
	
	j _moveBullet_nothingHit
	
_moveBullet_hitCent:
	move $a0, $s0
	sub $a1, $s1, 1
	jal _destroyCentipede
	
	move $a0, $s0
	sub $a1, $s1, 1
	li $a2, 3
	jal _setLED
	
	lw $a0, score
	addi $a0, $a0, 5
	sw $a0, score # Add 5 to score
	
	j _moveBullet_destroy
	
_moveBullet_hitMushroom:
	move $a0, $s0 # Destroy mushroom
	sub $a1, $s1, 1
	li $a2, 0
	jal _setLED
	
	lw $a0, score
	addi $a0, $a0, 1
	sw $a0, score # Add 1 to score
	
	j _moveBullet_destroy
	
_moveBullet_nothingHit:
	## Normal ##
	move $a0, $s0
	move $a1, $s1
	li $a2, 0
	jal _setLED # Delete old bullet
	
	subi $s1, $s1, 1 # Move up
	sb $s0, 1($t0)
	sb $s1, 2($t0) # Save changes
	
	move $a0, $s0
	move $a1, $s1
	li $a2, 2
	jal _setLED # Draw new bullet

	j _moveBullet_exit
_moveBullet_destroy:
	move $a0, $s0
	move $a1, $s1
	li $a2, 0
	jal _setLED
	
	sw $zero, 0($t0)
	
_moveBullet_exit:
	# Epilogue
	lw	$ra, 0($sp)
	lw	$t0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	addi	$sp, $sp, 16
	jr $ra

# --------------------------------

# FUNCTION moveCent($a0)
# $a0 = Pointer to centipede
# Preserves: $t
_moveCent:
	# Prologue
	addi	$sp, $sp, -28
	sw	$ra, 0($sp)
	sw	$t0, 4($sp)
	sw	$s0, 8($sp)
	sw	$s1, 12($sp)
	sw	$s2, 16($sp)
	sw	$s3, 20($sp)
	sw	$s4, 24($sp)

	move $s0, $a0		# $s0 = Pointer to centipede
	la $s1, centipedeEnd	# $s1 = Pointer to end of centipede
	
	# iterate to head of first centipede
_moveCent_findHead:
	la $a0, centipedeEnd
	bgt $s0, $a0, _moveCent_exit # exit if past end

	lb $a0, 0($s0)
	beq $a0, 1, _moveCent_good # check if centipede active
	
	addi $s0, $s0, 4
	j _moveCent_findHead
	
_moveCent_good:
	lb $a0, 1($s0)
	lb $a1, 2($s0)
	jal _findNextLocation
	move $s2, $v0		# $s2 = New X
	move $s3, $v1		# $s3 = New Y
	
	move $a0, $s2
	move $a1, $s3
	li $a2, 1
	jal _setLED # add new head LED
	
	move $a0, $s0
	move $a1, $s1
	jal _findCentEnd
	move $s4, $v0		# $s4 = Pointer to end of centipede
	
	add $a0, $s4, 4
	jal _moveCent # recursive call for centipede after this
	
	lb $a0, 1($s4)
	lb $a1, 2($s4)
	li $a2, 0
	jal _setLED # unset tail LED
	
	move $t0, $s4 # save copy of end for reverse interation
	
	bne $s0, $s4, _moveCent_longCent
	## One Block Centipede ##
	sb $s2, 1($s0)
	sb $s3, 2($s0) # update position
	
	j _moveCent_exit
_moveCent_longCent:
	lw $a0, -4($t0) # get previous block
	sw $a0, 0($t0) # save to current
	
	subi $t0, $t0, 4 # move pointer back one block
	
	bgt $t0, $s0, _moveCent_longCent # continue while not beginning

	sb $s2, 1($t0)
	sb $s3, 2($t0)
	
_moveCent_exit:
	# Epilogue
	lw	$ra, 0($sp)
	lw	$t0, 4($sp)
	lw	$s0, 8($sp)
	lw	$s1, 12($sp)
	lw	$s2, 16($sp)
	lw	$s3, 20($sp)
	lw	$s4, 24($sp)
	addi	$sp, $sp, 28
	jr $ra

# --------------------------------

# FUNCTION movePlayer(lastKey)
# Preserve: $t
_movePlayer:
	lw $a0, lastKey
	lw $a1, playerPos
	
	bne $a0, 0xE2, _movePlayer_notLeft # skip if not left arrow
	blt $a1, 2, _movePlayer_notLeft # don't move off board
	sub $a1, $a1, 1 # move left
	sw $a1, playerPos # store value
_movePlayer_notLeft:

	bne $a0, 0xE3, _movePlayer_notRight # skip if not right arrow
	bgt $a1, 61, _movePlayer_notRight # don't move off board
	add $a1, $a1, 1 # move left
	sw $a1, playerPos # store value
_movePlayer_notRight:

	jr $ra

# --------------------------------

# FUNCTION randInt($a0, $a1)
# $a0 = Minimum (inclusive)
# $a1 = Maximum (inclusive)
# Returns: $v0 = Value
# Preserve: $t
_randInt:
	# Prologue
	addi	$sp, $sp, -4
	sw	$t0, 0($sp)
	
	move $t0, $a0 # $t0 = min
	
	sub $a3, $a1, $a0
	addi $a3, $a3, 1 # range
	
	li $a0, 1 # generate random number 0 <= [int] < $a1
	move $a1, $a3
	li $v0, 42
	syscall
	
	add $v0, $a0, $t0 # add min to number
	
	# Epilogue
	lw	$t0, 0($sp)
	addi	$sp, $sp, 4
	jr $ra

# --------------------------------

# FUNCTION readKey()
# Returns: lastKey = Last key value
#		0	No key pressed
# 		0x42	Middle button pressed
# 		0xE0	Up arrow 
# 		0xE1	Down arrow 
# 		0xE2	Left arrow 
# 		0xE3	Right arrow
# Preserve: $t
_readKey:
	sw $zero, lastKey
	
	la $a1, 0xFFFF0000
	lw $a0, 0($a1)
	beq $a0, $zero, _readKey_exit
	
	lw $a2, 4($a1)
	sw $a2, lastKey
	
_readKey_exit:
	jr $ra

# --------------------------------	

# FUNCTION redrawPlayer()
# Preserves: $t
_redrawPlayer:
	# Prologue
	addi	$sp, $sp, -8
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)

	#      - X -
	#    - X X X -

	lw $s0, playerPos
	
	# Clear old LEDs
	addi $a0, $s0, -1
	li $a1, 62
	li $a2, 0
	jal _setLED
	
	addi $a0, $s0, 1
	li $a1, 62
	li $a2, 0
	jal _setLED
	
	addi $a0, $s0, -2
	li $a1, 63
	li $a2, 0
	jal _setLED
	
	addi $a0, $s0, 2
	li $a1, 63
	li $a2, 0
	jal _setLED
	
	# Set correct	
	move $a0, $s0
	li $a1, 62
	li $a2, 2
	jal _setLED
	
	addi $a0, $s0, -1
	li $a1, 63
	li $a2, 2
	jal _setLED
	
	move $a0, $s0
	li $a1, 63
	li $a2, 2
	jal _setLED
	
	addi $a0, $s0, 1
	li $a1, 63
	li $a2, 2
	jal _setLED
	
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	addi	$sp, $sp, 8
	jr $ra
	
# --------------------------------

# FUNCTION seedRNG()
# Preserves: $t
_seedRNG:
	li $v0, 30 # get time in milliseconds
	syscall
	
	move $a1, $a0 # seed from lower 32 bits of time
	li $a0, 1 # RNG id
	li $v0, 40
	syscall

	jr $ra
	
# --------------------------------
	
# FUNCTION setRandomMushrooms($a0)
# $a0 = Number of mushrooms
# Preserves: $t
_setRandomMushrooms:
	# Prologue
	addi	$sp, $sp, -16
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	
	move $s0, $a0 # number of mushrooms to generate
	
_setRandomMushrooms_loop:
	li $a0, 0 # get x coordinate
	li $a1, 63
	jal _randInt
	move $s1, $v0
	
	li $a0, 0 # get y coordinate (not bottom 4 rows)
	li $a1, 59
	jal _randInt
	move $s2, $v0
	
	move $a0, $s1 # find color at (x, y)
	move $a1, $s2
	jal _getLED
	
	bne $v0, 0, _setRandomMushrooms_loop # if not black, find new
	
	move $a0, $s1 # set to be mushroom
	move $a1, $s2
	li $a2, 3
	jal _setLED
	
	subi $s0, $s0, 1 # decrement counter
	
	bgt $s0, 0, _setRandomMushrooms_loop
	
	# Epilogue
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	addi	$sp, $sp, 16
	jr $ra

# --------------------------------

	# void _setLED(int x, int y, int color)
	#   sets the LED at (x,y) to color
	#   color: 0=off, 1=red, 2=orange, 3=green
	#
	# warning:   x, y and color are assumed to be legal values (0-63,0-63,0-3)
	# arguments: $a0 is x, $a1 is y, $a2 is color 
	# trashes:   
	# returns:   none
	# preserves: $t
_setLED:
	# Prologue
	addi	$sp, $sp, -16
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	sw	$t3, 12($sp)
	
	# check for bad locations
	blt $a0, 0, _setLED_exit
	bgt $a0, 63, _setLED_exit
	blt $a1, 0, _setLED_exit
	bgt $a1, 63, _setLED_exit

	# byte offset into display = y * 16 bytes + (x / 4)
	sll	$t0,$a1,4      # y * 16 bytes
	srl	$t1,$a0,2      # x / 4
	add	$t0,$t0,$t1    # byte offset into display
	li	$t2,0xffff0008	# base address of LED display
	add	$t0,$t2,$t0    # address of byte with the LED
	# now, compute led position in the byte and the mask for it
	andi	$t1,$a0,0x3    # remainder is led position in byte
	neg	$t1,$t1        # negate position for subtraction
	addi	$t1,$t1,3      # bit positions in reverse order
	sll	$t1,$t1,1      # led is 2 bits
	# compute two masks: one to clear field, one to set new color
	li	$t2,3		
	sllv	$t2,$t2,$t1
	not	$t2,$t2        # bit mask for clearing current color
	sllv	$t1,$a2,$t1    # bit mask for setting color
	# get current LED value, set the new field, store it back to LED
	lbu	$t3,0($t0)     # read current LED value	
	and	$t3,$t3,$t2    # clear the field for the color
	or	$t3,$t3,$t1    # set color field
	sb	$t3,0($t0)     # update display

_setLED_exit:
	# Epilogue
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$t2, 8($sp)
	lw	$t3, 12($sp)
	addi	$sp, $sp, 16
	jr	$ra



	# int _getLED(int x, int y)
	#   returns the value of the LED at position (x,y)
	#
	#  warning:   x and y are assumed to be legal values (0-63,0-63)
	#  arguments: $a0 holds x, $a1 holds y
	#  preserves: $t
	#  returns:   $v0 holds the value of the LED (0, 1, 2, 3)
	#
_getLED:
	blt $a0, 0, _getLED_error
	bgt $a0, 63, _getLED_error
	blt $a1, 0, _getLED_error
	bgt $a1, 63, _getLED_error
	
	# Prologue
	addi	$sp, $sp, -12
	sw	$t0, 0($sp)
	sw	$t1, 4($sp)
	sw	$t2, 8($sp)
	
	# byte offset into display = y * 16 bytes + (x / 4)
	sll  $t0,$a1,4      # y * 16 bytes
	srl  $t1,$a0,2      # x / 4
	add  $t0,$t0,$t1    # byte offset into display
	la   $t2,0xffff0008
	add  $t0,$t2,$t0    # address of byte with the LED
	# now, compute bit position in the byte and the mask for it
	andi $t1,$a0,0x3    # remainder is bit position in byte
	neg  $t1,$t1        # negate position for subtraction
	addi $t1,$t1,3      # bit positions in reverse order
    	sll  $t1,$t1,1      # led is 2 bits
	# load LED value, get the desired bit in the loaded byte
	lbu  $t2,0($t0)
	srlv $t2,$t2,$t1    # shift LED value to lsb position
	andi $v0,$t2,0x3    # mask off any remaining upper bits

	# Epilogue
	lw	$t0, 0($sp)
	lw	$t1, 4($sp)
	lw	$t2, 8($sp)
	addi	$sp, $sp, 12
	jr $ra
	
_getLED_error:
	li $v0, 0
	jr $ra
