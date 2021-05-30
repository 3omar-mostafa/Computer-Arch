vsim -gui work.decode
add wave  \
sim:/decode/CLK \
sim:/decode/RESET \
sim:/decode/IR \
sim:/decode/REG_FILE_DATA_IN \
sim:/decode/REG_FILE_R_DEST_EN \
sim:/decode/REG_FILE_R_DEST_NUM_WB \
sim:/decode/IS_LOAD_STORE \
sim:/decode/MEM_READ \
sim:/decode/MEM_WRITE \
sim:/decode/WRITE_BACK \
sim:/decode/BRANCH \
sim:/decode/JMP \
sim:/decode/HAS_NEXT_OPERAND \
sim:/decode/PUSH \
sim:/decode/POP \
sim:/decode/RsrcAddress \
sim:/decode/RdestAddress \
sim:/decode/RsrcData \
sim:/decode/RdestData \
sim:/decode/OpCode \
sim:/decode/ImmediateVal \
sim:/decode/IR_R_SRC_NUM \
sim:/decode/IR_R_DEST_NUM
force -freeze sim:/decode/CLK 0 1, 0 {50 ps} -r 100
force -freeze sim:/decode/RESET 1 0
run
force -freeze sim:/decode/RESET 0 0
force -freeze sim:/decode/IR 11100010110111000000000000000000 0
force -freeze sim:/decode/REG_FILE_DATA_IN 00000000000000000000000000000011 0
force -freeze sim:/decode/REG_FILE_R_DEST_EN 0 0
force -freeze sim:/decode/REG_FILE_R_DEST_NUM_WB 001 0
run
run