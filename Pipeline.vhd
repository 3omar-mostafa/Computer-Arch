LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Pipeline IS
	PORT (
		Clk, Rst : IN STD_LOGIC
	);
END ENTITY;

ARCHITECTURE arch_Pipeline OF Pipeline IS
	COMPONENT POS_N_REGISTER IS
		GENERIC (N : INTEGER := 32);
		PORT (
			Enable    : IN STD_LOGIC;
			clk, rst  : IN STD_LOGIC;
			D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			rst_value : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0') -- Reset to rst_value if provided, else reset to zeros [This is an optional parameter]
		);
	END COMPONENT;

	COMPONENT NEG_N_REGISTER IS
		GENERIC (N : INTEGER := 32);
		PORT (
			Enable    : IN STD_LOGIC;
			clk, rst  : IN STD_LOGIC;
			D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			rst_value : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0') -- Reset to rst_value if provided, else reset to zeros [This is an optional parameter]
		);
	END COMPONENT;

	COMPONENT Ram IS
		GENERIC (
			RamAddrWidth : INTEGER := 20;
			DataWidth    : INTEGER := 32
		);
		PORT (
			Clk, Rst   : IN STD_LOGIC;
			MW, MR     : IN STD_LOGIC;
			Address    : IN STD_LOGIC_VECTOR(RamAddrWidth - 1 DOWNTO 0);
			RamDataIn  : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
			RamDataOut : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT IF_ID_buffer IS
		PORT (
			clock    : IN STD_LOGIC;
			reset    : IN STD_LOGIC;
			IRInput  : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			IROutput : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT ID_EX_buffer IS
		PORT (
			clk, reset, MR, MW, WB, isLoadStore, pop    : IN STD_LOGIC;
			push, branch, jump, hasNextOp               : IN STD_LOGIC;
			RsrcAddress, RdestAddress                   : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			RsrcData, RdestData                         : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ImmediateVal                                : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			OpCode                                      : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			OpCodeOut                                   : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			ImmediateValOut                             : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
			MROut, MWOut, WBOut, isLoadStoreOut, popOut : OUT STD_LOGIC;
			pushOut, branchOut, jumpOut, hasNextOpOut   : OUT STD_LOGIC;
			RsrcDataOut, RdestDataOut                   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			RsrcAddressOut, RdestAddressOut             : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
		);

	END COMPONENT;

	COMPONENT EX_MEM_buffer IS
		PORT (
			clock, reset, MR, MW, WB : IN STD_LOGIC;
			RdestAddress             : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			Rdst, AluIn              : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			MROut, MWOut, WBOut      : OUT STD_LOGIC;
			RdestAddressOut          : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			RdstOut, AluOut          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT MEM_WB_buffer IS
		PORT (
			clock, reset, MR, WB  : IN STD_LOGIC;
			RdestAddress          : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			memoryDataIn, AluIn   : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			MROut, WBOut          : OUT STD_LOGIC;
			RdestAddressOut       : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			memoryDataOut, AluOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT Decoding_Stage IS
		PORT (
			CLK, RESET                         : IN STD_LOGIC;
			IR                                 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			REG_FILE_DATA_IN                   : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			REG_FILE_R_DEST_EN                 : IN STD_LOGIC;
			REG_FILE_R_DEST_NUM_WB             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			IS_LOAD_STORE, MEM_READ, MEM_WRITE : OUT STD_LOGIC;
			WRITE_BACK, BRANCH, JMP            : OUT STD_LOGIC;
			HAS_NEXT_OPERAND, PUSH, POP        : OUT STD_LOGIC;
			RsrcAddress, RdestAddress          : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			RsrcData, RdestData                : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			OpCode                             : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
			ImmediateVal                       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT Execution_Stage IS
		PORT (
			clk, rst                           : IN STD_LOGIC;
			isLoadStore, hasNextOperand        : IN STD_LOGIC;
			push, pop, branch, jump            : IN STD_LOGIC;
			ID_EX_Rsrc, ID_EX_Rdst             : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			EX_Mem_Rdst, Mem_WB_Rdst           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			EX_Mem_WriteBack, Mem_WB_WriteBack : IN STD_LOGIC;
			RsrcData, RdstData                 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			Mem_Stage_Out, WB_Stage_Out        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			ImmediateValue                     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
			OpCode                             : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
			PCin                               : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			InPort                             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

			PCout                              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			OutPort                            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
			RdstOut, AluOut                    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
			isBranchTaken                      : OUT STD_LOGIC
		);
	END COMPONENT;

	--PCIN should be from the Branch Control Unit
	SIGNAL PCIN                                                                        : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL PCOUT, RdstEXOUT, AluEXOUT, RdstMEMIN                                       : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AluMEMIN, MEMDataOut, DataWBIN, AluWBIN, DataWBOut, IR                      : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--MREXOUT -> memory read the output from execution stage
	--MRMEMIN -> memory read the input to memory stage
	SIGNAL PCEnable, MREXOUT, MWEXOUT, WBEXOUT, MRMEMIN                                : STD_LOGIC;
	SIGNAL MWMEMIN, WBMEMIN, MemAddSelector, MR, MRWBIN, WBWBIN                        : STD_LOGIC;
	--RdestAddEXOUT -> dest register address output from execution stage
	SIGNAL RdestAddEXOUT, RdestAddMEMIN, RdestAddWBIN                                  : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL RamAddress                                                                  : STD_LOGIC_VECTOR(19 DOWNTO 0);

	SIGNAL DEC_IN_IS_LOAD_STORE, DEC_IN_MEM_READ, DEC_IN_MEM_WRITE, DEC_IN_WRITE_BACK  : STD_LOGIC;
	SIGNAL DEC_IN_BRANCH, DEC_IN_JMP, DEC_IN_HAS_NEXT_OPERAND, DEC_IN_PUSH, DEC_IN_POP : STD_LOGIC;
	SIGNAL DEC_IN_RsrcAddress, DEC_IN_RdestAddress                                     : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL DEC_IN_RsrcData, DEC_IN_RdestData                                           : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL DEC_IN_OpCode                                                               : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL DEC_IN_ImmediateVal                                                         : STD_LOGIC_VECTOR (15 DOWNTO 0);

	SIGNAL EX_IN_OpCode                                                                : STD_LOGIC_VECTOR (4 DOWNTO 0);
	SIGNAL EX_IN_ImmediateVal                                                          : STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL EX_IN_MR, EX_IN_MW, EX_IN_WB, EX_IN_isLoadStore, EX_IN_pop                  : STD_LOGIC;
	SIGNAL EX_IN_push, EX_IN_branch, EX_IN_jump, EX_IN_hasNextOp                       : STD_LOGIC;
	SIGNAL EX_IN_RsrcData, EX_IN_RdestData                                             : STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL EX_IN_RsrcAddress, EX_IN_RdestAddress                                       : STD_LOGIC_VECTOR (2 DOWNTO 0);

	SIGNAL IN_PORT, OUT_PORT, IR_Input                                                 : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

	SIGNAL isBranchTaken                                                               : STD_LOGIC;

	SIGNAL IF_ID_BUFFER_RST                                                            : STD_LOGIC;

BEGIN

	IF_ID_BUFFER_RST <= isBranchTaken;

	MR               <= NOT(MWMEMIN);
	RamAddress       <= AluMEMIN(19 DOWNTO 0);

	-- Write Back (WB) Stage
	DataWBOut <= DataWBIN WHEN MRWBIN = '1' ELSE
				 AluWBIN  WHEN MRWBIN = '0';

	DataRam : Ram PORT MAP(
		Clk, Rst,    --  Clk        
		MWMEMIN, MR, --  MW, MR    
		RamAddress,  --  Address   
		RdstMEMIN,   --  RamDataIn 
		-----------OUTPUT-----------
		MEMDataOut); --  RamDataOut

	InstructionRam : Ram PORT MAP(
		Clk, Rst,           --  Clk        
		'0', '1',           --  MW, MR    
		PCOUT(19 DOWNTO 0), --  Address   
		(OTHERS => '0'),      --  RamDataIn 
		-----------OUTPUT-----------
		IR_Input);          --  RamDataOut

	PC   : NEG_N_REGISTER GENERIC MAP(32) PORT MAP('1', Clk, Rst, PCIN, PCOUT, IR_Input);

	IFID : IF_ID_buffer PORT MAP(
		Clk,              -- clock 
		IF_ID_BUFFER_RST, -- reset   
		IR_Input,         -- IRInput 
		-----------OUTPUT-----------
		IR);              -- IROutput

	DECODING_STG : Decoding_Stage PORT MAP(
		Clk, Rst,                                                -- CLK, RESET                        
		IR,                                                      -- IR                                
		DataWBOut,                                               -- REG_FILE_DATA_IN                  
		WBWBIN,                                                  -- REG_FILE_R_DEST_EN                
		RdestAddWBIN,                                            -- REG_FILE_R_DEST_NUM_WB 
		------------------------------------------------OUTPUT------------------------------------------------
		DEC_IN_IS_LOAD_STORE, DEC_IN_MEM_READ, DEC_IN_MEM_WRITE, -- IS_LOAD_STORE, MEM_READ, MEM_WRITE
		DEC_IN_WRITE_BACK, DEC_IN_BRANCH, DEC_IN_JMP,            -- WRITE_BACK, BRANCH, JMP           
		DEC_IN_HAS_NEXT_OPERAND, DEC_IN_PUSH, DEC_IN_POP,        -- HAS_NEXT_OPERAND, PUSH, POP       
		DEC_IN_RsrcAddress, DEC_IN_RdestAddress,                 -- RsrcAddress, RdestAddress         
		DEC_IN_RsrcData, DEC_IN_RdestData,                       -- RsrcData, RdestData               
		DEC_IN_OpCode,                                           -- OpCode                            
		DEC_IN_ImmediateVal);                                    -- ImmediateVal

	IDEX : ID_EX_buffer PORT MAP(
		Clk, Rst,                                                                    -- clk, reset
		DEC_IN_MEM_READ, DEC_IN_MEM_WRITE, DEC_IN_WRITE_BACK, DEC_IN_IS_LOAD_STORE,  -- MR, MW, WB,isLoadStore
		DEC_IN_POP, DEC_IN_PUSH, DEC_IN_BRANCH, DEC_IN_JMP, DEC_IN_HAS_NEXT_OPERAND, -- pop, push, branch, jump, hasNextOp           
		DEC_IN_RsrcAddress, DEC_IN_RdestAddress,                                     -- RsrcAddress, RdestAddress               
		DEC_IN_RsrcData, DEC_IN_RdestData,                                           -- RsrcData, RdestData                     
		DEC_IN_ImmediateVal,                                                         -- ImmediateVal                            
		DEC_IN_OpCode,                                                               -- OpCode                                  
		------------------------------------------------OUTPUT------------------------------------------------
		EX_IN_OpCode,                                                                -- OpCodeOut                                  
		EX_IN_ImmediateVal,                                                          -- ImmediateValOut                            
		EX_IN_MR, EX_IN_MW, EX_IN_WB, EX_IN_isLoadStore,                             -- MROut, MWOut, WBOut, isLoadStoreOut
		EX_IN_pop, EX_IN_push, EX_IN_branch, EX_IN_jump, EX_IN_hasNextOp,            -- popOut, pushOut, branchOut, jumpOut, hasNextOpOut  
		EX_IN_RsrcData, EX_IN_RdestData,                                             -- RsrcDataOut, RdestDataOut                  
		EX_IN_RsrcAddress, EX_IN_RdestAddress);                                      -- RsrcAddressOut, RdestAddressOut

	EXECUTING_STG : Execution_Stage PORT MAP(
		Clk, Rst,                                        -- clk, rst                           
		EX_IN_isLoadStore, EX_IN_hasNextOp,              -- isLoadStore, hasNextOperand        
		EX_IN_push, EX_IN_pop, EX_IN_branch, EX_IN_jump, -- push, pop, branch, jump            
		EX_IN_RsrcAddress, EX_IN_RdestAddress,           -- ID_EX_Rsrc, ID_EX_Rdst             
		RdestAddMEMIN, RdestAddWBIN,                     -- EX_Mem_Rdst, Mem_WB_Rdst           
		WBMEMIN, WBWBIN,                                 -- EX_Mem_WriteBack, Mem_WB_WriteBack 
		EX_IN_RsrcData, EX_IN_RdestData,                 -- RsrcData, RdstData                 
		AluMEMIN, DataWBOut,                             -- Mem_Stage_Out, WB_Stage_Out        
		EX_IN_ImmediateVal,                              -- ImmediateValue                     
		EX_IN_OpCode,                                    -- OpCode                             
		PCOUT,                                           -- PCin                               
		IN_PORT,                                         -- InPort                             
		------------------------OUTPUT------------------------
		PCIN,                                            -- PCout                              
		OUT_PORT,                                        -- OutPort                            
		RdstEXOUT, AluEXOUT,                             -- RdstOut, AluOut                    
		isBranchTaken                                    -- isBranchTaken                      
	);

	EXMEM : EX_MEM_buffer PORT MAP(
		Clk, Rst,                     -- clock, reset  
		EX_IN_MR, EX_IN_MW, EX_IN_WB, -- MR, MW, WB 
		EX_IN_RdestAddress,           -- RdestAddress             
		RdstEXOUT, AluEXOUT,          -- Rdst, AluIn              
		------------------------OUTPUT------------------------
		MRMEMIN, MWMEMIN, WBMEMIN,    -- MROut, MWOut, WBOut      
		RdestAddMEMIN,                -- RdestAddressOut          
		RdstMEMIN, AluMEMIN);         -- RdstOut, AluOut          

	MEMWB : MEM_WB_buffer PORT MAP(
		Clk, Rst,             -- clock, reset                  
		MRMEMIN, WBMEMIN,     -- MR, WB 
		RdestAddMEMIN,        -- RdestAddress         
		MEMDataOut, AluMEMIN, -- memoryDataIn, AluIn  
		------------------------OUTPUT------------------------
		MRWBIN, WBWBIN,       -- MROut, WBOut         
		RdestAddWBIN,         -- RdestAddressOut      
		DataWBIN, AluWBIN);   -- memoryDataOut, AluOut

END arch_Pipeline;
