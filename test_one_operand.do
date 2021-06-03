vsim -gui work.pipeline
add wave  \
sim:/pipeline/Clk \
sim:/pipeline/Rst
add wave  \
sim:/pipeline/PCOUT \
sim:/pipeline/PCIN \
sim:/pipeline/AluEXOUT \
sim:/pipeline/AluMEMIN \
sim:/pipeline/AluWBIN
mem load -i {./Test_Cases/OneOperand.mem} -format mti /pipeline/InstructionRam/RamArray
radix -hexadecimal
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

add log -r sim:/pipeline/*

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
force -freeze sim:/pipeline/IN_PORT 10 0
run
run
run
run
run
run