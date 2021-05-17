LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY ALU IS
	PORT (
		push, pop  : IN STD_LOGIC;
		clk, rst   : IN STD_LOGIC;
		opcode     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		Rsrc, Rdst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		InPort     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		Rout       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		OutPort    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		Flags      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Flags bits order : Carry, Negative, Zero
	);
END ALU;

ARCHITECTURE arch_ALU OF ALU IS

	COMPONENT POS_N_REGISTER IS
		GENERIC (N : INTEGER := 32);
		PORT (
			Enable   : IN STD_LOGIC;
			clk, rst : IN STD_LOGIC;
			D        : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
			Q        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
		);
	END COMPONENT;

	
	COMPONENT NEG_N_REGISTER IS
		GENERIC (N : INTEGER := 32);
		PORT (
			Enable    : IN STD_LOGIC;
			clk, rst  : IN STD_LOGIC;
			D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
			Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
		);
	END COMPONENT;


	COMPONENT POS_D_FLIP_FLOP IS
		PORT (
			Enable   : IN STD_LOGIC;
			clk, rst : IN STD_LOGIC;
			D        : IN STD_LOGIC;
			Q        : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL carry_flag, carry_flag_enable       : STD_LOGIC;
	SIGNAL negative_flag, negative_flag_enable : STD_LOGIC;
	SIGNAL zero_flag, zero_flag_enable         : STD_LOGIC;

	SIGNAL temp_result                         : STD_LOGIC_VECTOR(32 DOWNTO 0); -- 32 not 31 to be able to get the carry

	SIGNAL SP_out                              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_in                               : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_add                              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_sub                              : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL SP_Enable                           : STD_LOGIC;

	SIGNAL OutPort_Enable                      : STD_LOGIC;

BEGIN

	carry_reg    : POS_D_FLIP_FLOP PORT MAP(carry_flag_enable, clk, rst, carry_flag, Flags(2));
	negative_reg : POS_D_FLIP_FLOP PORT MAP(negative_flag_enable, clk, rst, negative_flag, Flags(1));
	zero_reg     : POS_D_FLIP_FLOP PORT MAP(zero_flag_enable, clk, rst, zero_flag, Flags(0));

	SP_add <= SP_out + 4;
	SP_sub <= SP_out - 4;

	SP_in  <= SP_add WHEN push = '0' ELSE SP_sub;

	SP_Enable <= push OR pop;
	SP : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(SP_Enable, clk, rst, SP_in, SP_out);

	OutPort_Enable <= '1' WHEN opcode = "01000" ELSE '0';
	OutPortReg : POS_N_REGISTER GENERIC MAP(32) PORT MAP(OutPort_Enable, clk, rst, Rdst, OutPort); -- Out instruction

	-- temp_result is larger than operands by 1 to store the carry bit
	-- temp_result(32) is the carry bit
	temp_result <= (OTHERS => '0')             WHEN opcode = "00000" ELSE   -- NOP operation
        (32 => '1', OTHERS => '0')             WHEN opcode = "00001" ELSE   -- Set carry
        (OTHERS => '0')                        WHEN opcode = "00010" ELSE   -- clear carry
        (OTHERS => '0')                        WHEN opcode = "00011" ELSE   -- clear Rdst
        ('0' & NOT Rdst)                       WHEN opcode = "00100" ELSE   -- 1's complement
        ('0' & Rdst + 1)                       WHEN opcode = "00101" ELSE   -- increment
        ('0' & Rdst - 1)                       WHEN opcode = "00110" ELSE   -- decrement
        STD_LOGIC_VECTOR(-signed('0' & Rdst))  WHEN opcode = "00111" ELSE   -- 2's complement
        ('0' & InPort) 		                   WHEN opcode = "01001" ELSE   -- In instruction
        STD_LOGIC_VECTOR(Rdst(31) & rotate_left(unsigned(Rdst), 1)) WHEN opcode = "01010" ELSE
        STD_LOGIC_VECTOR(Rdst(0) & rotate_right(unsigned(Rdst), 1)) WHEN opcode = "01011" ELSE
        ('0' & SP_out) WHEN (push = '1' AND opcode = "01100") ELSE
        ('0' & SP_add) WHEN (pop = '1'  AND opcode = "01101") ELSE

        --  2 operands
        ('0' & Rdst + Rsrc)     WHEN opcode = "10000" ELSE
        ('0' & Rdst - Rsrc)     WHEN opcode = "10001" ELSE
        ('0' & (Rdst AND Rsrc)) WHEN opcode = "10010" ELSE
        ('0' & (Rdst OR Rsrc))  WHEN opcode = "10011" ELSE
        ('0' & Rsrc)            WHEN opcode = "10100" ELSE -- MOV operation
        STD_LOGIC_VECTOR(shift_left(unsigned('0' & Rdst), to_integer(unsigned(Rsrc))))  WHEN opcode = "10101" ELSE
        STD_LOGIC_VECTOR(shift_right(unsigned('0' & Rdst), to_integer(unsigned(Rsrc)))) WHEN opcode = "10110" ELSE

	    (OTHERS => '0');

	carry_flag_enable <= '1' WHEN opcode = "00001" OR opcode = "00010" OR opcode = "01010" OR opcode = "01011" OR opcode = "10000" OR opcode = "10001" OR opcode = "10101" OR opcode = "10110"
    ELSE '0';
    
	negative_flag_enable <= '1' WHEN opcode = "00100" OR opcode = "00101" OR opcode = "00110" OR opcode = "00111" OR opcode = "10000" OR opcode = "10001" OR opcode = "10010" OR opcode = "10011"
    ELSE '0';
    
	zero_flag_enable <= '1' WHEN opcode = "00011" OR opcode = "00100" OR opcode = "00101" OR opcode = "00110" OR opcode = "00111" OR opcode = "10000" OR opcode = "10001" OR opcode = "10010" OR opcode = "10011"
	ELSE '0';

	carry_flag    <= temp_result(32) WHEN (carry_flag_enable = '1');

	negative_flag <= temp_result(31) WHEN (negative_flag_enable = '1');

	zero_flag     <= '1' WHEN ((unsigned(temp_result(31 DOWNTO 0)) = 0) AND (zero_flag_enable = '1')) ELSE '0';

    Rout <= temp_result(31 DOWNTO 0);
    
END arch_ALU;
