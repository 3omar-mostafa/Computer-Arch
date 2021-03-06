LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY REG_FILE IS
    PORT (
        CLK, RESET    : IN STD_LOGIC;
        DATA_IN       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        R_DEST_EN     : IN STD_LOGIC;
        R_DEST_NUM_WB : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_SRC_NUM     : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_DEST_NUM    : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_SRC_OUT     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        R_DEST_OUT    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END REG_FILE;

ARCHITECTURE ARCH_REG_FILE OF REG_FILE IS

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

    COMPONENT N_DECODER IS
        GENERIC (N : INTEGER := 3); -- 3x8 DECODER
        PORT (
            Enable : IN STD_LOGIC;
            InpuT  : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
            Output : OUT STD_LOGIC_VECTOR ((2 ** N) - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL R_DEST_ENABLES : STD_LOGIC_VECTOR(7 DOWNTO 0);

    SIGNAL R7_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R6_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R5_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R4_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R3_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R2_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R1_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL R0_OUT : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    R_DEST_DECODER : N_DECODER GENERIC MAP(3) PORT MAP(R_DEST_EN, R_DEST_NUM_WB, R_DEST_ENABLES);

    R7 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(7), CLK, RESET, DATA_IN, R7_OUT);
    R6 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(6), CLK, RESET, DATA_IN, R6_OUT);
    R5 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(5), CLK, RESET, DATA_IN, R5_OUT);
    R4 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(4), CLK, RESET, DATA_IN, R4_OUT);
    R3 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(3), CLK, RESET, DATA_IN, R3_OUT);
    R2 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(2), CLK, RESET, DATA_IN, R2_OUT);
    R1 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(1), CLK, RESET, DATA_IN, R1_OUT);
    R0 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(0), CLK, RESET, DATA_IN, R0_OUT);

    R_SRC_OUT <= R0_OUT WHEN R_SRC_NUM = "000" ELSE
                 R1_OUT WHEN R_SRC_NUM = "001" ELSE
                 R2_OUT WHEN R_SRC_NUM = "010" ELSE
                 R3_OUT WHEN R_SRC_NUM = "011" ELSE
                 R4_OUT WHEN R_SRC_NUM = "100" ELSE
                 R5_OUT WHEN R_SRC_NUM = "101" ELSE
                 R6_OUT WHEN R_SRC_NUM = "110" ELSE
                 R7_OUT WHEN R_SRC_NUM = "111" ELSE
                 (OTHERS => '0');

    R_DEST_OUT <= R0_OUT WHEN R_DEST_NUM = "000" ELSE
                  R1_OUT WHEN R_DEST_NUM = "001" ELSE
                  R2_OUT WHEN R_DEST_NUM = "010" ELSE
                  R3_OUT WHEN R_DEST_NUM = "011" ELSE
                  R4_OUT WHEN R_DEST_NUM = "100" ELSE
                  R5_OUT WHEN R_DEST_NUM = "101" ELSE
                  R6_OUT WHEN R_DEST_NUM = "110" ELSE
                  R7_OUT WHEN R_DEST_NUM = "111" ELSE
                  (OTHERS => '0');

END ARCHITECTURE;