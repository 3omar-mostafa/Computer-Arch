LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IF_ID_buffer IS
    PORT (
        clock : IN STD_LOGIC;
        reset  : IN STD_LOGIC;
        IRInput : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
	IROutput : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END IF_ID_buffer;

ARCHITECTURE arch_IF_ID_buffer OF IF_ID_buffer IS

        COMPONENT POS_N_REGISTER IS
	GENERIC (N : INTEGER := 32);
        PORT (
        Enable   : IN STD_LOGIC;
        clk, rst : IN STD_LOGIC;
        D        : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        Q        : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    	);
    	END COMPONENT;


BEGIN
        IR : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clock, reset, IRInput, IROutput);
  
END ARCHITECTURE;
