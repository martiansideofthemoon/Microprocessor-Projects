org 29
db 0x7FFF
db 11
db 12
db 13
db 14
db 15

org 0
adi r0, r1, 30
lm r0, 0b00111110
add r5, r4, r3
adc r0, r1, r1
add r4, r3, r2
add r3, r2, r1
sm r0, 0b00111110

lw r0, r6, 29
add r1, r0, r0
adc r1, r5, r5
add r5, r1, r6
adi r7, r6, 11
add r5, r6, r6
beq r6, r6, 0