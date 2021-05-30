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
force -freeze sim:/pipeline/Clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/pipeline/Rst 1 0
add log  \
sim:/pipeline/MEMDataOut \
sim:/pipeline/IR \
sim:/pipeline/RamAddress
mem load -i {./RAM.mem} -format mti /pipeline/R/RamArray
run
force -freeze sim:/pipeline/Rst 0 0
run
radix -decimal
add log sim:/pipeline/EXECUTING_STG/alu_unit/*
add log sim:/pipeline/EXECUTING_STG/branch_unit/*
add log sim:/pipeline/*

