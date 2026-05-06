.data

a: .byte 1 2 15 7 8 12

.text

la t0 a
li t2 8
j check
loop:
lb t1 0(t0)
addi t1 t1 1
sb t1 0(t0)
check:
addi t2 t2 -1
addi t0 t0 1
bne t2 zero loop
wfi