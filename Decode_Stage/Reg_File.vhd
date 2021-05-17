LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY REG_FILE IS
    PORT (
        CLK, RESET : IN STD_LOGIC;
        DATA_IN : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        R_DEST_EN : IN STD_LOGIC;
        R_SRC_NUM : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_DEST_NUM : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        R_SRC_OUT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        R_DEST_OUT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
    );
END REG_FILE;

ARCHITECTURE ARCH_REG_FILE OF REG_FILE IS

    COMPONENT NEG_N_REGISTER IS
        GENERIC (N : INTEGER := 32);
        PORT (
            Enable    : IN STD_LOGIC;
            clk, rst  : IN STD_LOGIC;
            D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT N_DECODER IS
        GENERIC (N : INTEGER := 3); -- 3x8 DECODER
        PORT (
            Enable : IN STD_LOGIC;
            InpuT : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
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

    R_DEST_DECODER : N_DECODER GENERIC MAP(3) PORT MAP(R_DEST_EN, R_DEST_NUM, R_DEST_ENABLES);

    R7 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(7), CLK, RESET, DATA_IN, R7_OUT);
    R6 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(6), CLK, RESET, DATA_IN, R6_OUT);
    R5 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(5), CLK, RESET, DATA_IN, R5_OUT);
    R4 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(4), CLK, RESET, DATA_IN, R4_OUT);
    R3 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(3), CLK, RESET, DATA_IN, R3_OUT);
    R2 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(2), CLK, RESET, DATA_IN, R2_OUT);
    R1 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(1), CLK, RESET, DATA_IN, R1_OUT);
    R0 : NEG_N_REGISTER GENERIC MAP(32) PORT MAP(R_DEST_ENABLES(0), CLK, RESET, DATA_IN, R0_OUT);

    PROCESS (CLK)
    BEGIN

        IF RISING_EDGE(CLK) THEN

            CASE R_SRC_NUM IS
                WHEN "000" =>
                    R_SRC_OUT <= R0_OUT;
                WHEN "001" =>
                    R_SRC_OUT <= R1_OUT;
                WHEN "010" =>
                    R_SRC_OUT <= R2_OUT;
                WHEN "011" =>
                    R_SRC_OUT <= R3_OUT;
                WHEN "100" =>
                    R_SRC_OUT <= R4_OUT;
                WHEN "101" =>
                    R_SRC_OUT <= R5_OUT;
                WHEN "110" =>
                    R_SRC_OUT <= R6_OUT;
                WHEN "111" =>
                    R_SRC_OUT <= R7_OUT;
                WHEN OTHERS =>
                    R_SRC_OUT <= (OTHERS => '0');
            END CASE;

            CASE R_DEST_NUM IS
                WHEN "000" =>
                    R_DEST_OUT <= R0_OUT;
                WHEN "001" =>
                    R_DEST_OUT <= R1_OUT;
                WHEN "010" =>
                    R_DEST_OUT <= R2_OUT;
                WHEN "011" =>
                    R_DEST_OUT <= R3_OUT;
                WHEN "100" =>
                    R_DEST_OUT <= R4_OUT;
                WHEN "101" =>
                    R_DEST_OUT <= R5_OUT;
                WHEN "110" =>
                    R_DEST_OUT <= R6_OUT;
                WHEN "111" =>
                    R_DEST_OUT <= R7_OUT;
                WHEN OTHERS =>
                    R_DEST_OUT <= (OTHERS => '0');
            END CASE;

        END IF;

    END PROCESS;

END ARCHITECTURE;