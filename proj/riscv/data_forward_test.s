.data 
    array_size: .word 12
    array: .word 65, 12, 10, 89, 11, 70, 67, 5, 9, 45, 90, 7
    # TODO: You may add additional temporary data here
.text

la s0 array #auipc + arithmetic hazard

#double arithmetic hazard
addi t1 t1 1
add t1 t1 t1
add t1 t1 t1

nop
nop
nop
nop

#arithmetic to load hazard
addi s0 s0 4
lw t2 0(s0)

nop
nop
nop
nop

#load to arithmetic hazard (this is the only one that should actually stall)
lw t2 0(s0)
addi t2 t2 5

nop
nop
nop
nop

#load to store hazard
lw t2 0(s0)
sw t2 4(s0)

nop
nop
nop
nop

#arithmetic to store hazard
addi t2 zero 5
sw t2 4(s0)

nop
nop
nop
nop

#pc + 4 to arithmetic hazard
jal here
here: addi ra ra 1


wfi

