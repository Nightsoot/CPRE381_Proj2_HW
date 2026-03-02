
.text
addi a3 a3 -1
nop
nop
nop
nop
addi a2 a2 -1
nop
nop
nop
nop
addi a3 a3 -1
nop
nop
nop
nop
addi a5 a5 0x7FF
nop
nop
nop
nop
addi a1 a1 0
nop
nop
nop
nop
addi a6 a6 12
nop
nop
nop
nop

jal ra, foo
nop
nop
nop
nop
#a0 = 20 + 10 + 5 + 40 + a6 = 87
#auipc ra, %pcrel_hi(big_jump)
#jalr ra, ra %pcrel_lo(big_jump)
j end
nop
nop
nop
nop

foo: 
nop
nop
nop
nop
beq a1, a6, skip  #terminate the deal at a2 = 10
nop
nop
nop
nop
bne a2, a3, skip2  #a2 != -1
nop
nop
nop
nop
addi a2 a2 3 #a2 = a2 + 3
nop
nop
nop
nop
addi a0 a0, 20
nop
nop
nop
nop
beq zero, zero cond
nop
nop
nop
nop
skip2:
nop
nop
nop
nop
bgeu a2, a3, skip3 #a2 >= FFFFFFFF (1)
nop
nop
nop
nop
add a3 zero zero
nop
nop
nop
nop
addi a3 a3 1
nop
nop
nop
nop
addi a0 a0, 10
nop
nop
nop
nop
beq zero, zero cond
nop
nop
nop
nop
skip3:
nop
nop
nop
nop
blt a2, a4, skip4 # a2 < -1 (5) 
nop
nop
nop
nop
add a4 zero zero
nop
nop
nop
nop
addi a4 a4 100
nop
nop
nop
nop
addi a0 a0, 5
nop
nop
nop
nop
beq zero, zero cond
nop
nop
nop
nop
skip4:
bltu a5, a2 skip5 # (0xFFFFFFFFF)
nop
nop
nop
nop
add a5 zero zero
nop
nop
nop
nop
addi a0 a0, 40
nop
nop
nop
nop
beq zero, zero cond
nop
nop
nop
nop
skip5:
addi a1 a1 1
nop
nop
nop
nop
addi a0 a0 1
nop
nop
nop
nop
cond:
addi sp, sp -4 #allocate the stack
nop
nop
nop
nop
sw ra 0(sp) #store the return address
nop
nop
nop
nop
jal ra foo #recursive call
nop
nop
nop
nop
lw ra 0(sp) # get back the return address
nop
nop
nop
nop
addi sp, sp 4 #deallocate the stack
nop
nop
nop
nop
skip: jalr zero, ra, 0 #return
nop
nop
nop
nop
j end
nop
nop
nop
nop


big_jump:
slli a2 a2 1 # a2 * 2
nop
nop
nop
nop
end: wfi
nop
nop
nop
nop

