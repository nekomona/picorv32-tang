.global isp_flasher_begin
.global isp_flasher_end

isp_flasher_begin:
# a0 ... instr buffer pointer
#   0 instr
#   1-3 addr
#   4-259 page dat
# a1 ... flashio pointer

# address of UART dat reg
li t0, 0x2000008
addi t6, x0, 0
addi a4, a1, 0

# instr read
isp_flasher_IREAD:
lw t1, 0(t0)
blt t1, x0, isp_flasher_IREAD

li t2, 0x55
beq t1, t2, isp_flasher_ACK
li t2, 0x10
beq t1, t2, isp_flasher_WBUF
li t2, 0x30
beq t1, t2, isp_flasher_ESEC
li t2, 0x40
beq t1, t2, isp_flasher_WPAG
li t2, 0xF0
beq t1, t2, isp_flasher_RST

j isp_flasher_IREAD

# ack
# 0x55
# 0x56
isp_flasher_ACK:
li t1, 0x56
sw t1, 0(t0)
j isp_flasher_IREAD

# write buffer
# 0x10 len dat0-datn
# 0x11 ....                       chk 
isp_flasher_WBUF:
li t1, 0x11
sw t1, 0(t0)

addi t2, a0, 4
isp_flasher_RLEN:
lw t1, 0(t0)
blt t1, x0, isp_flasher_RLEN
addi t1, t1, 1
addi t6, t1, 0

addi t4, x0, 0

isp_flasher_RDAT:
lw t3, 0(t0)
blt t3, x0, isp_flasher_RDAT
sb t3, 0(t2)
addi t2, t2, 1
addi t1, t1, -1
add t4, t4, t3
bnez t1, isp_flasher_RDAT

isp_flasher_RCOMP:
andi t4, t4, 0xFF
sw t4, 0(t0)

j isp_flasher_IREAD

# sector erase
# 0x30 addr2-0
# 0x31                     0x32
isp_flasher_ESEC:
li t1, 0x31
sw t1, 0(t0)

# prepare instr and addr
li t1, 0x20
sb t1, 0(a0)
isp_flasher_ERADA:
lw t1, 0(t0)
blt t1, x0, isp_flasher_ERADA
sb t1, 1(a0)
isp_flasher_ERADB:
lw t1, 0(t0)
blt t1, x0, isp_flasher_ERADB
sb t1, 2(a0)
isp_flasher_ERADC:
lw t1, 0(t0)
blt t1, x0, isp_flasher_ERADC
sb t1, 3(a0)

# call flashio to proceed erase
addi a1, x0, 4
addi a2, x0, 6
addi sp, sp, -4
sw ra, 0(sp)
jal ra, isp_flasher_CFLASH
lw ra, 0(sp)
addi sp, sp, 4

# call flashio to check status byte
isp_flasher_ECSTAT:
li t1, 0x05
sb t1, 0(a0)
addi a1, x0, 2
addi a2, x0, 0
addi sp, sp, -4
sw ra, 0(sp)
jal ra, isp_flasher_CFLASH
lw ra, 0(sp)
addi sp, sp, 4
lbu t2, 1(a0)
andi t2, t2, 1
bnez t2, isp_flasher_ECSTAT

li t1, 0x32
sw t1, 0(t0)
j isp_flasher_IREAD

# page write
# page length saved in t6 from last wbuf
# flashio have 16.25ms wait to fit WRSR tw requirement so no wait in page write
# 0x40 addr0 - 2
# 0x41                   0x42
isp_flasher_WPAG:
li t1, 0x41
sw t1, 0(t0)

li t1, 0x02
sb t1, 0(a0)
isp_flasher_WRADA:
lw t1, 0(t0)
blt t1, x0, isp_flasher_WRADA
sb t1, 1(a0)
isp_flasher_WRADB:
lw t1, 0(t0)
blt t1, x0, isp_flasher_WRADB
sb t1, 2(a0)
isp_flasher_WRADC:
lw t1, 0(t0)
blt t1, x0, isp_flasher_WRADC
sb t1, 3(a0)

beqz t6, isp_flasher_WFIN

# call flashio
addi a1, t6, 4
addi a2, x0, 6
addi sp, sp, -4
sw ra, 0(sp)
jal ra, isp_flasher_CFLASH
lw ra, 0(sp)
addi sp, sp, 4

isp_flasher_WFIN:
li t1, 0x42
sw t1, 0(t0)
j isp_flasher_IREAD

# reset system
# 0xF0
# 0xF1
isp_flasher_RST:
li t1, 0xF1
sw t1, 0(t0)

# better impl on software reset planned
# stack pointer
li x2, 4096

addi t1, x0, 0
lui t1, 0x1000 #li t1, 0x1000000 avoid using luipc
jalr x0, t1, 0

isp_flasher_CFLASH:
addi sp, sp, -36
# ra a0 t0 - t6
sw ra, 32(sp)
sw a0, 28(sp)
sw t0, 24(sp)
sw t1, 20(sp)
sw t2, 16(sp)
sw t3, 12(sp)
sw t4, 8(sp)
sw t5, 4(sp)
sw t6, 0(sp)
#call flashio_worker
jalr a4

lw ra, 32(sp)
lw a0, 28(sp)
lw t0, 24(sp)
lw t1, 20(sp)
lw t2, 16(sp)
lw t3, 12(sp)
lw t4, 8(sp)
lw t5, 4(sp)
lw t6, 0(sp)
addi sp, sp, 36
ret

isp_flasher_end:
