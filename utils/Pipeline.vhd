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

	COMPONENT Ram IS
		GENERIC (
			RamAddrWidth : INTEGER := 20;
			DataWidth    : INTEGER := 32
		);
		PORT (
			Clk        : IN STD_LOGIC;
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

	COMPONENT EX_MEM_buffer IS
		PORT (
			clock, reset, MR, MW, WB : IN STD_LOGIC;
			RdestAddress             : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
			Rsrc, AluIn              : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			MROut, MWOut, WBOut      : OUT STD_LOGIC;
			RdestAddressOut          : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			RsrcOut, AluOut          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
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

	--PCIN should be from the Branch Control Unit
	SIGNAL PCIN, PCOUT, RsrcEXOUT, AluEXOUT, RsrcMEMIN, AluMEMIN, MEMDataOut, DataWBIN, AluWBIN, DataWBOut    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	--MREXOUT -> memory read the output from execution stage
	--MRMEMIN -> memory read the input to memory stage
	SIGNAL PCEnable, MREXOUT, MWEXOUT, WBEXOUT, MRMEMIN, MWMEMIN, WBMEMIN, MemAddSelector, MR, MRWBIN, WBWBIN : STD_LOGIC;
	--RdestAddEXOUT -> dest register address output from execution stage
	SIGNAL RdestAddEXOUT, RdestAddMEMIN, RdestAddWBIN                                                         : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL RamAddress                                                                                         : STD_LOGIC_VECTOR(19 DOWNTO 0);
BEGIN

	PCEnable       <= NOT(MRMEMIN OR MWMEMIN);
	MemAddSelector <= (MRMEMIN OR MWMEMIN);
	MR             <= NOT(MWMEMIN);
	RamAddress     <=
		PCOUT(19 DOWNTO 0) WHEN MemAddSelector = '0'
		ELSE
		AluMEMIN(19 DOWNTO 0) WHEN MemAddSelector = '1';

	DataWBOut <= 
		DataWBIN WHEN MRWBIN = '1'
		ELSE
			AluWBIN WHEN MRWBIN = '0';

	R     : Ram PORT MAP(Clk, MWMEMIN, MR, RamAddress, RsrcMEMIN, MEMDataOut);
	PC    : POS_N_REGISTER GENERIC MAP(32) PORT MAP(PCEnable, Clk, Rst, PCIN, PCOUT);
	EXMEM : EX_MEM_buffer PORT MAP(Clk, Rst, MREXOUT, MWEXOUT, WBEXOUT, RdestAddEXOUT, RsrcEXOUT, AluEXOUT, MRMEMIN, MWMEMIN, WBMEMIN, RdestAddMEMIN, RsrcMEMIN, AluMEMIN);

	MEMWB : MEM_WB_buffer PORT MAP(Clk, Rst, MRMEMIN, WBMEMIN, RdestAddMEMIN, MEMDataOut, AluMEMIN, MRWBIN, WBWBIN, RdestAddWBIN, DataWBIN, AluWBIN);

END arch_Pipeline;