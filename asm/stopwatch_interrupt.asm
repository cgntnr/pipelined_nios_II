.equ    RAM, 0x1000
.equ    LEDs, 0x2000
.equ    TIMER, 0x2020
.equ    BUTTON, 0x2030

.equ    LFSR, RAM

br main
br interrupt_handler

main:
    ; Variable initialization for spend_time
    addi t0, zero, 18
    stw t0, LFSR(zero)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING ABOVE THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

    ; WRITE YOUR CONSTANT DEFINITIONS AND main HERE		
	addi t0, zero, 0xff
	stw  t0, LEDs+12(zero)	
	addi sp, zero, LEDs ;initializing sp to use from end of RAM
	addi t1, zero, 500
	add  t2, zero, zero
	addi t3, zero, 10000
	add  t0, zero, zero
loop:
	add  t0, t0, t3
	addi t2, t2, 1
	bne  t2, t1, loop  ; period value for 100 ms	
	addi t0, t0, -1

;	addi t0 ,zero, 999  ;;value for nios simulator
	stw  t0, TIMER + 4(zero) ; period set	

	add  t0, zero, zero ;instantiate counter
	stw  t0, RAM + 0x500 (zero) ;used middle of RAM to store counter
	

	addi t0, zero, 11 
	stw  t0, TIMER + 8(zero) ; bits for start ito and cont set to 1
	addi t0, zero, 5 	
	wrctl ienable, t0 ; Timer and Button irq bits enabled, UART not used
	addi t0, zero, 1
	wrctl status, t0 ; interrupts enabled (PIE bit)

inf_loop:
	jmpi inf_loop


interrupt_handler:
    ; WRITE YOUR INTERRUPT HANDLER HERE
	addi   sp, sp, -16
    stw    s0, 0(sp)
    stw    s1, 4(sp)
    stw    s2, 8(sp)
	stw	   ra, 12(sp)

	rdctl s0, ipending  ; read the ipending register to identify the source
	addi  s1, zero, 1   ; t1 = 1
	and   s2, s0, s1    ; checking the timer bit
	beq   s2, zero, timer_done  ; skip if timer bit is 0
	call timer_isr
    timer_done:
	addi  s1, zero, 4 ; to check third bit 
	rdctl s0, ipending
	and   s2, s0, s1  ; checking the buttons bit
	beq   s2, zero, buttons_done  ; skip if buttons bit is 0
	call button_isr
	buttons_done:
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 8(sp)
	ldw ra, 12(sp)
	addi sp, sp, 16
	addi  ea, ea, -4 ; correct the exception return address
eret ; return from exception


timer_isr:
	addi   sp, sp, -12
    stw    s0, 0(sp)
    stw    s1, 4(sp)
	stw    ra, 8(sp)	

	ldw   t0, RAM + 0x500 (zero)
	addi   t0, t0,1 		;increment counter
	stw   t0, RAM + 0x500 (zero)

	rdctl s0, ienable   ; checking ienable
	addi  s1, zero, 4    ; to check if in spend time or not
	and   s1, s1, s0  
	beq   s1, zero, dont_display 	
	add  a0, t0, zero
	call display
    dont_display:
	stw  zero, TIMER + 12(zero) ; to clear TO bit
	ldw s0, 0(sp)
	ldw s1, 4(sp)	
	ldw ra, 8(sp)
	addi sp, sp, 12

ret

button_isr:
	addi   sp, sp, -16
    stw    s0, 0(sp)
    stw    s1, 4(sp)
    stw    s2, 8(sp)
	stw    ra, 12(sp)

	ldw   s0, BUTTON + 4(zero) ; get the edgecapture
	addi  s1, zero, 1
	and   s2, s0, s1 ;checking if first button pressed
	beq   s2, zero, button_0_not_pressed  

	stw  zero, BUTTON + 4(zero) ;clearing edgecapture
	addi s0, zero, 1
	wrctl ienable, s0 ; only Timer irq enabled when in spend_time			
	wrctl status, s0 ; interrupts enabled again(PIE bit)
	call spend_time
	addi s0, zero, 5 	
	wrctl ienable, s0 ; both interrupts enable again

    button_0_not_pressed:
	ldw s0, 0(sp)
	ldw s1, 4(sp)
	ldw s2, 8(sp)	
	ldw ra, 12(sp)
	addi sp, sp, 16	
ret

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING BELOW THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; ----------------- Common functions --------------------
; a0 = tenths of second
display:
    addi   sp, sp, -20
    stw    ra, 0(sp)
    stw    s0, 4(sp)
    stw    s1, 8(sp)
    stw    s2, 12(sp)
    stw    s3, 16(sp)
    add    s0, a0, zero
    add    a0, zero, s0
    addi   a1, zero, 600
    call   divide
    add    s0, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 100
    call   divide
    add    s1, zero, v0
    add    a0, zero, v1
    addi   a1, zero, 10
    call   divide
    add    s2, zero, v0
    add    s3, zero, v1

    slli   s3, s3, 2
    slli   s2, s2, 2
    slli   s1, s1, 2
    ldw    s3, font_data(s3)
    ldw    s2, font_data(s2)
    ldw    s1, font_data(s1)

    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    addi   t6, zero, 4
    minute_loop_s3:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s2
    or     s3, s3, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s3

    minute_s2:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s2:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_s1
    or     s2, s2, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s2

    minute_s1:
    xori   t4, zero, 0x8000
    slli   t4, t4, 16
    add    t5, zero, zero
    minute_loop_s1:
    beq    zero, s0, minute_end
    beq    t6, t5, minute_end
    or     s1, s1, t4
    srli   t4, t4, 8
    addi   s0, s0, -1
    addi   t5, t5, 1
    br minute_loop_s1

    minute_end:
    stw    s1, LEDs(zero)
    stw    s2, LEDs+4(zero)
    stw    s3, LEDs+8(zero)

    ldw    ra, 0(sp)
    ldw    s0, 4(sp)
    ldw    s1, 8(sp)
    ldw    s2, 12(sp)
    ldw    s3, 16(sp)
    addi   sp, sp, 20

    ret

flip_leds:
    addi t0, zero, -1
    ldw t1, LEDs(zero)
    xor t1, t1, t0
    stw t1, LEDs(zero)
    ldw t1, LEDs+4(zero)
    xor t1, t1, t0
    stw t1, LEDs+4(zero)
    ldw t1, LEDs+8(zero)
    xor t1, t1, t0
    stw t1, LEDs+8(zero)
    ret

spend_time:
    addi sp, sp, -4
    stw  ra, 0(sp)
    call flip_leds
    ldw t1, LFSR(zero)
    add t0, zero, t1
    srli t1, t1, 2
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    srli t1, t1, 1
    xor t0, t0, t1
    andi t0, t0, 1
    slli t0, t0, 7
    srli t1, t1, 1
    or t1, t0, t1
    stw t1, LFSR(zero)
    slli t1, t1, 15
    addi t0, zero, 1
    slli t0, t0, 22
    add t1, t0, t1

spend_time_loop:
    addi   t1, t1, -1
    bne    t1, zero, spend_time_loop
    
    call flip_leds
    ldw ra, 0(sp)
    addi sp, sp, 4

    ret

; v0 = a0 / a1
; v1 = a0 % a1
divide:
    add    v0, zero, zero
divide_body:
    add    v1, a0, zero
    blt    a0, a1, end
    sub    a0, a0, a1
    addi   v0, v0, 1
    br     divide_body
end:
    ret



font_data:
    .word 0x7E427E00 ; 0
    .word 0x407E4400 ; 1
    .word 0x4E4A7A00 ; 2
    .word 0x7E4A4200 ; 3
    .word 0x7E080E00 ; 4
    .word 0x7A4A4E00 ; 5
    .word 0x7A4A7E00 ; 6
    .word 0x7E020600 ; 7
    .word 0x7E4A7E00 ; 8
    .word 0x7E4A4E00 ; 9
    .word 0x7E127E00 ; A
    .word 0x344A7E00 ; B
    .word 0x42423C00 ; C
    .word 0x3C427E00 ; D
    .word 0x424A7E00 ; E
    .word 0x020A7E00 ; F