.equ    RAM, 0x1000
.equ    LEDs, 0x2000
.equ    TIMER, 0x2020
.equ    BUTTON, 0x2030

.equ    LFSR, RAM

; Variable initialization for spend_time
addi t0, zero, 18
stw t0, LFSR(zero)

; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
; DO NOT CHANGE ANYTHING ABOVE THIS LINE
; <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

addi t0, zero, 0xff
stw  t0, LEDS+12(zero)

addi sp, zero, LEDs ; stack pointer initialization
add  s0, zero, zero ; s0: counter

addi s2, zero, 0x4c4b
slli s2, s2, 8
ori  s2, s2, 40 ; s2: number of cycles in 0.1 s = 5,000,000 = 0x4c4b40

add  s1, zero, zero ; s1: cycle counter

main_loop:
    inner_loop:
        ldw  t0, BUTTON + 4(zero) ; read edgecapture | 4
        stw  zero, BUTTON + 4(zero) ; clear edgecapture | 4
        andi t0, t0, 1 ; we only care about the first button | 3
        beq  t0, zero, inner_loop_end ; 4

        call spend_time ; 163 + 7 * x
        ldw  t1, LFSR(zero) ; 4
        slli t1, t1, 15 ; 3
        addi t0, zero, 1 ; 3
        slli t0, t0, 22 ; 3
        add  t1, t0, t1 ; t1: x | 3
        slli t0, t1, 3 ; t0: 8 * x | 3
        sub  t0, t0, t1 ; t0: 7 * x | 3
        addi t0, t0, 195 ; 3
        add  s1, s1, t0 ; 3

        stw  zero, BUTTON + 4(zero) ; clear edgecapture again | 4

    inner_loop_end:
        addi s1, s1, 22 ; 3
        blt  s1, s2, inner_loop ; 4

    update_loop:
        sub  s1, s1, s2
        addi s0, s0, 1 ; update counter
        add  a0, s0, zero
        call display
        bge  s1, s2, update_loop

    br main_loop

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

flip_leds: ; 40
    addi t0, zero, -1 ; 3
    ldw t1, LEDs(zero) ; 4
    xor t1, t1, t0 ; 3
    stw t1, LEDs(zero) ; 4
    ldw t1, LEDs+4(zero) ; 4
    xor t1, t1, t0 ; 3
    stw t1, LEDs+4(zero) ; 4
    ldw t1, LEDs+8(zero) ; 4
    xor t1, t1, t0 ; 3
    stw t1, LEDs+8(zero) ; 4
    ret ; 4

spend_time: ; 159 + 7 * x
    addi sp, sp, -4 ; 3
    stw  ra, 0(sp) ; 4
    call flip_leds ; 44
    ldw t1, LFSR(zero) ; 4
    add t0, zero, t1 ; 3
    srli t1, t1, 2 ; 3
    xor t0, t0, t1 ; 3
    srli t1, t1, 1 ; 3
    xor t0, t0, t1 ; 3
    srli t1, t1, 1 ; 3
    xor t0, t0, t1 ; 3
    andi t0, t0, 1 ; 3
    slli t0, t0, 7 ; 3
    srli t1, t1, 1 ; 3
    or t1, t0, t1 ; 3
    stw t1, LFSR(zero) ; 4
    slli t1, t1, 15 ; 3
    addi t0, zero, 1 ; 3
    slli t0, t0, 22 ; 3
    add t1, t0, t1 ; t1: x | 3

spend_time_loop:
    addi   t1, t1, -1 ; 3
    bne    t1, zero, spend_time_loop ; 4
    
    call flip_leds ; 44
    ldw ra, 0(sp) ; 4
    addi sp, sp, 4 ; 3

    ret ; 4

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
