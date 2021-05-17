LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY MEM_WB_buffer IS
	PORT (
		clock, reset, MR, WB  : IN STD_LOGIC;
		RdestAddress          : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		memoryDataIn, AluIn   : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		MROut, WBOut          : OUT STD_LOGIC;
		RdestAddressOut       : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		memoryDataOut, AluOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END MEM_WB_buffer;

ARCHITECTURE arch_MEM_WB_buffer OF MEM_WB_buffer IS

	COMPONENT POS_N_REGISTER IS
		GENERIC (N : INTEGER := 32);
		PORT (
			Enable    : IN STD_LOGIC;
			clk, rst  : IN STD_LOGIC;
			D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL controlSignalsIn  : STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL controlSignalsOut : STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN
	controlSignalsIn <= MR & WB;

	R0 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clock, reset, memoryDataIn, memoryDataOut);
	R1 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clock, reset, AluIn , AluOut);
	R2 : POS_N_REGISTER GENERIC MAP(3) PORT MAP('1', clock, reset, RdestAddress, RdestAddressOut);
	R3 : POS_N_REGISTER GENERIC MAP(2) PORT MAP('1', clock, reset, controlSignalsIn, controlSignalsOut);

	MROut <= controlSignalsOut(0);
	WBOut <= controlSignalsOut(1);
  
END ARCHITECTURE;
