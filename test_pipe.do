vsim -gui work.pipeline
add wave  \
sim:/pipeline/Clk \
sim:/pipeline/Rst
add wave  \
sim:/pipeline/PCOUT \
sim:/pipeline/PCIN \
sim:/pipeline/PCEnable \
sim:/pipeline/AluEXOUT \
sim:/pipeline/AluMEMIN \
sim:/pipeline/AluWBIN
add log  \
sim:/pipeline/MEMDataOut \
sim:/pipeline/IR \
sim:/pipeline/RamAddress
mem load -i {./Test_Cases/OneOperand.mem} -format mti /pipeline/R/RamArray
radix -decimal
add log sim:/pipeline/EXECUTING_STG/alu_unit/*
add log sim:/pipeline/EXECUTING_STG/branch_unit/*
add log sim:/pipeline/*
add wave -position insertpoint  \
sim:/pipeline/IR
add wave -position insertpoint  \
sim:/pipeline/IN_PORT
add wave -position insertpoint  \
sim:/pipeline/OUT_PORT
add wave -position insertpoint  \
sim:/pipeline/EXECUTING_STG/carry_flag \
sim:/pipeline/EXECUTING_STG/negative_flag \
sim:/pipeline/EXECUTING_STG/zero_flag
add wave -position insertpoint  \
sim:/pipeline/DECODING_STG/REG_F/R0_OUT \
sim:/pipeline/DECODING_STG/REG_F/R1_OUT \
sim:/pipeline/DECODING_STG/REG_F/R2_OUT

force -freeze sim:/pipeline/Clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
run
force -freeze sim:/pipeline/Rst 0 0
run
run
run
run
run
run
run
run
force -freeze sim:/pipeline/IN_PORT 5 0
run
force -freeze sim:/pipeline/IN_PORT 16 0
run
run
run
run
run
run