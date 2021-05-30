vsim -gui work.execution_stage
add wave -r sim:/execution_stage/*
force -freeze sim:/execution_stage/clk 1 0, 0 {50 ps} -r 100
force -freeze sim:/execution_stage/rst 1 0
run
force -freeze sim:/execution_stage/rst 0 0
force -freeze sim:/execution_stage/OpCode 10000 0
force -freeze sim:/execution_stage/isLoadStore 0 0
force -freeze sim:/execution_stage/hasNextOperand 0 0
force -freeze sim:/execution_stage/push 0 0
force -freeze sim:/execution_stage/pop 0 0
force -freeze sim:/execution_stage/branch 0 0
force -freeze sim:/execution_stage/jump 0 0
force -freeze sim:/execution_stage/ID_EX_Rsrc 000 0
force -freeze sim:/execution_stage/ID_EX_Rdst 001 0
force -freeze sim:/execution_stage/EX_Mem_Rdst 010 0
force -freeze sim:/execution_stage/Mem_WB_Rdst 001 0
force -freeze sim:/execution_stage/EX_Mem_WriteBack 0 0
force -freeze sim:/execution_stage/Mem_WB_WriteBack 0 0
force -freeze sim:/execution_stage/RsrcData 00000000000000000000000000000011 0
force -freeze sim:/execution_stage/RdstData 00000000000000000000000000000100 0
force -freeze sim:/execution_stage/Mem_Stage_Out 00000000000000000000000000000000 0
force -freeze sim:/execution_stage/WB_Stage_Out 00000000000000000000000000000000 0
force -freeze sim:/execution_stage/ImmediateValue 0000000000000010 0
force -freeze sim:/execution_stage/PCin 00000000000000000000000000000000 0
force -freeze sim:/execution_stage/InPort 00000000000000000000000000000101 0
run
force -freeze sim:/execution_stage/OpCode 10001 0
run
force -freeze sim:/execution_stage/RsrcData 00000000000000000000000000000101 0
run
run