.equ LEDS, 0x2000
.equ TIMER, 0x2020
.equ BUTTONS, 0x2030

_start:
br main ; jump to the main function
interrupt_handler:
; save the registers to the stack
	addi sp, sp, -24
	stw s0, 0(sp)
	stw	s1, 4(sp)
	stw s2, 8(sp)
	stw s3, 12(sp)
	stw s4, 16(sp)
	stw ra, 20(sp)

	rdctl s0, ipending  ; read the ipending register to identify the source
	addi  s1, zero, 1   ; t1 = 1
	and   s2, s0, s1    ; checking the timer bit
	beq   s2, zero, timer_done  ; skip if timer bit is 0
	call timer_isr
	timer_done:
	addi  s1, zero, 4 ; to check third bit 
	and   s2, s0, s1  ; checking the buttons bit
	beq   s2, zero, buttons_done  ; skip if buttons bit is 0
	call buttons_isr
	buttons_done:
	ldw   s0, 0(sp)
	ldw   s1, 4(sp)
	ldw   s2, 8(sp)
	ldw   s3, 12(sp)
	ldw   s4, 16(sp)
	ldw   ra, 20(sp)
	addi  sp, sp, 24 ; restore the registers from the stack
	addi  ea, ea, -4 ; correct the exception return address
eret ; return from exception


buttons_isr: ; ??? do we have to set smth for the other two buttons???
	ldw  t0, BUTTONS + 4(zero) ; get the edgecapture
	ldw  t3, LEDS(zero) ;getting current leds0
	addi t1, zero, 3 ;to check pressing at the same time
	and  t2, t0, t1 
	beq  t2, t1, both_pressed
	addi t1, zero, 1
	and  t2, t0, t1 ;checking if first button pressed
	sub  t3, t3, t2 ;decrementing counter
	srli t0, t0, 1   ;getting the second bit to lsb
	and  t2, t0, t1  ;checking if second button pressed
	add  t3, t3, t2  ;incrementing counter
	stw  t3, LEDS(zero) ;updating leds0
	both_pressed:
	stw  zero, BUTTONS + 4(zero) ;clearing edgecapture	
	ret

timer_isr:
	stw  zero, TIMER + 12(zero) ; to clear TO bit
	ldw  t0, LEDS + 4(zero)  ;get second counter value from leds1
	addi t0, t0, 1          ;increment counter value
	stw  t0, LEDS + 4(zero)  ; update leds1
	ret

main:  ; main procedure here
	addi sp, zero, LEDS ;initializing sp to use from end of RAM
	add t1, zero, zero ;first counter,changed by buttons
	add t2, zero, zero ;second counter, changed by interrupts
	add s0, zero, zero ;third counter
	stw  t1, LEDS(zero) ;updates leds0 
	stw  t2, LEDS + 4(zero) ;updates leds1
	addi t0, zero, 5 	
	wrctl ienable, t0 ; Timer and Button irq bits enabled, UART not used
	addi t0, zero, 1
	wrctl status, t0 ; interrupts enabled (PIE bit)

;	addi t5, zero, 5000
;	add t6, zero, zero
;	addi t7, zero, 10000
;	add t0, zero, zero
;loop:
;	add  t0, t0, t7
;	addi t6, t6, 1
;	bne  t6, t5, loop
;	addi t0, t0, -1
	
	addi t0, zero, 999  ; 1000-1 
	stw  t0, TIMER + 4(zero) ; period set
	addi t0, zero, 11 
	stw  t0 , TIMER + 8(zero) ; bits for start ito and cont set to 1

third_counter_loop:
	stw s0, LEDS + 8(zero) ; updates leds2
	addi s0, s0, 1
	jmpi third_counter_loop;
