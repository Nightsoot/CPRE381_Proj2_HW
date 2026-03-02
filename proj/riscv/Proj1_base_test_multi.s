.data

a: .word 1 2 15 7 8 12

.text

addi s0, x0 1
nop
nop
nop
nop
addi s1, x0 2
nop
nop
nop
nop
sll t0, s0, s1 # t0 should be 4
nop
nop
nop
nop
slli t1, s1, 2 # t1 should be 8
nop
nop
nop
nop
addi s2, x0, -2
nop
nop
nop
nop
addi s3, x0, -6
nop
nop
nop
nop
sra t2, s2, s0 # t2 should be -1
nop
nop
nop
nop
srai t3, s3, 1 # t3 should be -3
nop
nop
nop
nop
srl t4, s2, s0
nop
nop
nop
nop
srli t5, s3, 2
nop
nop
nop
nop
lui s4 0x10010
#li s4 0x10010000
nop
nop
nop
nop
sw t0, 0(s4)
nop
nop
nop
nop
lw s5, 0(s4)
nop
nop
nop
nop
add t0, s5, s1
nop
nop
nop
nop
lw t1, 4(s4)
nop
nop
nop
nop
sub t2, t1, t0
nop
nop
nop
nop
lui t3, 0xFFFFF
nop
nop
nop
nop
addi t3 t3 -1
nop
nop
nop
nop
lui t4, 0xAAAAA
nop
nop
nop
nop
addi t4 t4 -556
nop
nop
nop
nop
and t5 t3, t4
nop
nop
nop
nop
li t0 0x543
nop
nop
nop
nop
add t1 zero zero
nop
nop
nop
nop
addi t1 t1 0x718 
nop
nop
nop
nop
slti t6 t0 0x7FF
nop
nop
nop
nop
slt t6 t0 t3
nop
nop
nop
nop
sltu t6 t0 t4
nop
nop
nop
nop
or t2, t0, t1
nop
nop
nop
nop
xor t3, t5, t2
nop
nop
nop
nop
li t0, 5
nop
nop
nop
nop
andi t1, t0, 1
nop
nop
nop
nop
ori  t2, t1, 2
nop
nop
nop
nop
xori t3, t2, 6
nop
nop
nop
nop
auipc t5, 14
nop
nop
nop
nop


wfi