LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY EX_MEM_buffer IS
	PORT (
		clock, reset, MR, MW, WB : IN STD_LOGIC;
		RdestAddress             : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
		Rdst, AluIn              : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		MROut, MWOut, WBOut      : OUT STD_LOGIC;
		RdestAddressOut          : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		RdstOut, AluOut          : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END EX_MEM_buffer;

ARCHITECTURE arch_EX_MEM_buffer OF EX_MEM_buffer IS

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

	SIGNAL controlSignalsIn  : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL controlSignalsOut : STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN
	controlSignalsIn <= MR & MW & WB;

	R0 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clock, reset, Rdst, RdstOut);
	R1 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clock, reset, AluIn, AluOut);
	R2 : POS_N_REGISTER GENERIC MAP(3) PORT MAP('1', clock, reset, RdestAddress, RdestAddressOut);
	R3 : POS_N_REGISTER GENERIC MAP(3) PORT MAP('1', clock, reset, controlSignalsIn, controlSignalsOut);

	MROut <= controlSignalsOut(2);
	MWOut <= controlSignalsOut(1);
	WBOut <= controlSignalsOut(0);

END ARCHITECTURE;
