LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

ENTITY Ram IS
	GENERIC(
		RamAddrWidth: INTEGER :=20;
		DataWidth: INTEGER :=32
	);
	PORT(
		Clk:IN std_logic;
		MW,MR : IN std_logic;
		Address : IN std_logic_vector(RamAddrWidth-1 DOWNTO 0);
		RamDataIn  : IN std_logic_vector(DataWidth-1 DOWNTO 0);
		RamDataOut : OUT std_logic_vector(DataWidth-1 DOWNTO 0));
END ENTITY;
ARCHITECTURE RamArch OF Ram IS
	TYPE RamType IS ARRAY(0 TO (2**(RamAddrWidth))-1) of std_logic_vector(((DataWidth/2)-1) DOWNTO 0);
	SIGNAL RamArray : RamType:=(
		OTHERS =>(OTHERS => '0')
	);
	BEGIN
		PROCESS(Clk) IS
		BEGIN
			IF rising_edge(Clk) AND (MR = '1' OR MW = '1') THEN
			    IF MW = '1' THEN
		       		 RamArray(to_integer(unsigned(Address))) <= RamDataIn(((DataWidth/2)-1) DOWNTO 0);
			         RamArray(to_integer(unsigned(Address)+1)) <= RamDataIn(DataWidth-1 DOWNTO (DataWidth/2));
			    ELSIF MR = '1' THEN 
				 RamDataOut(((DataWidth/2)-1) DOWNTO 0) <= RamArray(to_integer(unsigned(Address)));
				 RamDataOut(DataWidth-1 DOWNTO (DataWidth/2)) <= RamArray(to_integer(unsigned(Address)+1));
			    END IF;
			END IF;
		END PROCESS;
		
END RamArch;
