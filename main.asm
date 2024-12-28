.data
# Unified data section
prompt_system: .asciiz "Enter the current system: "
prompt_number: .asciiz "Enter the number: "
prompt_new_system: .asciiz "Enter the new system: "
output_result: .asciiz "The number in the new system: "
error_invalid: .asciiz "Invalid input!\n"
number: .space 50
decimal_result: .word 8
new_base_result: .space 50

# Additional data from other functions
prompt_result: .asciiz "Number in decimal: "
ans: .word 0

prompt_decimal: .asciiz "Enter a decimal number: "
choice: .asciiz "\nEnter the new system (2 for Binary, 8 for Octal, 16 for Hexadecimal): "
newline: .asciiz "\n"

.text
.globl main

# Main function
main:
    # Prompt for current system
    li $v0, 4
    la $a0, prompt_system
    syscall

    li $v0, 5
    syscall
    move $t0, $v0  # $t0 = current system
    move $t5, $v0

    # Prompt for number
    li $v0, 4
    la $a0, prompt_number
    syscall

    li $v0, 8
    la $a0, number
    li $a1, 50
    syscall

    # Validate the input number
    move $a0, $a0  # Address of the number string
    move $a1, $t0  # Current system
    jal validate_input

    # Check if validation passed
    beqz $v0, invalid_input

    # Convert to decimal
    move $a0, $t5      # Current system
    la $a1, number     # Address of the number string
    jal otherToDecimal
    sw $v0, decimal_result  # Store decimal result
    
     #lw $a0, decimal_result         
     #li $v0, 1        
     #syscall                   


    
    

    # Prompt for new system
    li $v0, 4
    la $a0, prompt_new_system
    syscall

    li $v0, 5
    syscall
    move $t1, $v0  # $t1 = new system

    # Convert decimal to the new system
    lw $a1, decimal_result  # Load decimal result
    move $a2, $t1           # New system
    jal DecimalToOther
    
    move $t5, $a0

    # Output the result
    li $v0, 4
    la $a0, output_result
    syscall

    move $a0, $t5
    li $v0, 4
    syscall

    j exit

invalid_input:
    li $v0, 4
    la $a0, error_invalid
    syscall
    j exit

exit:
    li $v0, 10
    syscall

# validate_input function
.globl validate_input
validate_input:
    li $v0, 1  # Assume valid unless proven otherwise

validate_loop:
    lb $t0, 0($a0)  # Load the current character
    beq $t0, 10, validate_done  # If newline, we're done

    # Check if the character is a valid digit for the base
    li $t1, 48  # ASCII '0'
    li $t2, 57  # ASCII '9'
    blt $t0, $t1, invalid_digit  # If less than '0', invalid
    ble $t0, $t2, check_numeric  # If between '0' and '9', check numeric

    li $t1, 65  # ASCII 'A'
    li $t2, 90  # ASCII 'Z'
    blt $t0, $t1, invalid_digit  # If less than 'A', invalid
    ble $t0, $t2, check_uppercase  # If between 'A' and 'Z', check uppercase

    li $t1, 97  # ASCII 'a'
    li $t2, 122  # ASCII 'z'
    blt $t0, $t1, invalid_digit  # If less than 'a', invalid
    ble $t0, $t2, check_lowercase  # If between 'a' and 'z', check lowercase

    j invalid_digit  # If none of the above, invalid

check_numeric:
    sub $t0, $t0, 48  # Convert ASCII to numeric value
    j check_digit

check_uppercase:
    sub $t0, $t0, 55  # Convert ASCII 'A'-'Z' to 10-35
    j check_digit

check_lowercase:
    sub $t0, $t0, 87  # Convert ASCII 'a'-'z' to 10-35

check_digit:
    bge $t0, $a1, invalid_digit  # If digit >= base, invalid
    addi $a0, $a0, 1  # Move to the next character
    j validate_loop

invalid_digit:
    li $v0, 0  # Set result to invalid

validate_done:
    jr $ra  # Return
    
    
.globl otherToDecimal
otherToDecimal:

  #li $v0, 1        
  #syscall

  # Calculate length of input string
  move $t0, $a1     # Load address of the string into $t0
  li $t1, 0          # Initialize counter for length
loop:
    lb $t2, 0($t0) 
    beqz $t2, done   # Break if null terminator is reached
    addi $t1, $t1, 1 # Increment length counter
    addi $t0, $t0, 1 # Move to the next character
    j loop
done:
 # $t1 contains the length of the string
  subi $t1, $t1, 1
  
 

   lw $t0,ans
   li $t4, 1     #power counter
   move $t2, $a1 #loading the number address 
   addi $t1, $t1, -1
   loop_start:  
    #looping throgh the stirng char by char breaking when $t1 < 0 
     bltz $t1,loop_end
     add $t5, $t2, $t1
     lb $t6, 0($t5)
     subi $t6, $t6, 48 #converting asscii to int
   
   # Calulating the value of each char 
     mul $t7, $t6, $t4
     add $t0, $t0, $t7
   
   #incrementing the power(by multiplying by the base)"$a0"
   # and decrmenting counter 
    mul $t4, $t4, $a0
    subi $t1, $t1, 1
    j loop_start  

 loop_end:  
  move $v0, $t0     # Move the result to $v0 for returning
  jr $ra


# DecimalToOther function
.globl DecimalToOther
DecimalToOther:
    move $t3, $a1
    move $t6, $a2

    la $t0, new_base_result
    addi $t0, $t0, 31
    sb $zero, 0($t0)
    subi $t0, $t0, 1

convertLoop:
    beqz $t3, convertEnd
    divu $t5, $t3, $t6
    mfhi $t7

    li $t8, 10
    blt $t7, $t8, storeDigit

    addi $t9, $t7, 55
    sb $t9, 0($t0)
    subi $t0, $t0, 1
    j updateQuotient

storeDigit:
    addi $t9, $t7, 48
    sb $t9, 0($t0)
    subi $t0, $t0, 1

updateQuotient:
    mflo $t3
    j convertLoop

convertEnd:
    addi $t0, $t0, 1
    move $a0, $t0
    jr $ra