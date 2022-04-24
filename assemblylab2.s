.data
    N = 8	; set this to whatever integer you want
    array: .skip N*4   ; allocate N space for an array
    num_not_found: .asciz "Number not found."
    found_at: .asciz "Number found at index "
    enter_num: .asciz "Enter a number to put into the array: "
    enter_num_to_find: .asciz "Enter a number to find: "

.text
main:
    ldr r1, =enter_num ; load the enter_num prompt into r1 to be used for the get_number procedure
    ldr r2, =N        ; load N into r2
    ldr r3, =array    ; store the memory address of the first array element in r3
    mov r4, #0		  ; start a counter in r4 at 0
    b .L2
.L2:
    bl get_number     ; call get_number procedure to fill the array
    str r0, [r3], #4  ; store the user's number in the array (r3)
    add r4, r4, #1	  ; increment the counter
.L3:
    cmp r4, r2		  ; compare the counter in r4 to N in r2
    blt .L2			  ; go back to L3 if we haven't filled the array yet
    ldr r3, =array	  ; reset r3 back to beginning of the array
    bl sort			  ; once we have, call the sort procedure
    ldr r1, =enter_num_to_find ; load the enter_num_to_find prompt into r1 to be used for the get_number procedure
    bl get_number     ; call get_number procedure to get the number to find
    bl search		  ; call the search procedure
    mov r0, #1		  ; otherwise, set r0 to 1 to indicate that we want to print
    ldr r1, =found_at ; load the found_at message into r1
    swi 0x69		  ; print the found_at message
    mov r0, #1		  ; set r0 to 1 to indicate that we want to print
    mov r1, r9		  ; load the index we found into r1
    swi 0x6b		  ; print the index
    b exit			  ; exit the program

get_number:
	  ; Arguments: r1 = prompt, r2 = N (Array Size), r3 = Array location
    mov r0, #1		  ; set r0 to 1 to indicate we want to print
    swi 0x69		  ; print the prompt
    mov r0, #0		  ; set r0 to 0 to indicate we want to read in
    swi 0x6c		  ; read user number
    mov pc, lr		  ; return
	
sort:
	  ; Arguments: r2 = N (Array Size), r3 = Array location
	  stmfd sp!, {r2, r3} 
.L4:
	  mov r4, #0		  ; r4 = current element index
	  mov r8, #0		  ; r8 = number of swaps
.L5:
	  add r5, r4, #1	 ; r5 = next element index
	  cmp r5, r2		  ; check for the end of the array
	  bge .L6			  ; when we reach the end, check for changes
	  ldr r6, [r3, r4, lsl #2] ; r6 = current element value
	  ldr r7, [r3, r5, lsl #2] ; r7 = next element value
	  cmp r6, r7		  ; compare element values
	  strgt r7, [r3, r4, lsl #2] ; if r6 > r7, store current value at next
	  strgt r6, [r3, r5, lsl #2] ; if r6 > r7, store next value at current
	  addgt r8, r8, #1  ; if r6 > r7, increment swap counter
	  mov r4, r5
	  b .L5
.L6:
	  cmp r8, #0		  ; see if there were changes this iteration
	  subgt r2, r2, #1  ; skip last value in next loop
	  bgt .L4
.L7:	
	  ldmfd sp!, {r2, r3}
	  mov pc, lr
    
search:
	  ; Arguments: r0 = number to find, r2 = N (Array Size), r3 = Array location
	  stmfd sp!, {r2, r3}
	  mov r4, #0		  ; r4 = first index
	  sub r5, r2, #1	  ; r5 = last index
	  add r6, r4, r5
	  mov r6, r6, lsr #1 ; r6 = middle index (first index + last index) / 2
	  mov r7, #0		  ; start a counter in r7
.L8:
	  cmp r7, r2		  ; compare counter to size of the array
	  bgt .L12		  ; if we've checked every element, we couldn't find the element
	  ldr r8, [r3, r6, lsl #2] ; r7 = middle value
	  cmp r0, r8		  ; compare number_to_find to the middle value
	  blt .L9
	  bgt .L10
	  beq .L11
	  b .L12
.L9:
	  sub r5, r6, #1	  ; set last index to middle index - 1
	  add r6, r4, r5
	  mov r6, r6, lsr #1 ; set middle index to (first index + last index) / 2
	  add r7, r7, #1	  ; increment the counter
	  b .L8
.L10:
	  add r4, r6, #1	  ; set first index to middle index + 1
	  add r6, r4, r5
	  mov r6, r6, lsr #1 ; set middle index to (first index + last index) / 2
	  add r7, r7, #1	  ; increment the counter
	  b .L8
.L11:
	  mov r9, r6		  ; store the index of the number that was found in r9
    b .L13
.L12:
    b not_found
.L13:
	  ldmfd sp!, {r2, r3}
	  mov pc, lr
	
not_found:
    mov r0, #1		  ; set r0 to 1 to indicate that we want to print
    ldr r1, =num_not_found ; load the num_not_found message into r1
    swi 0x69		  ; print the num_not_found message
    b exit			  ; exit the program

exit:
    swi 0x11
