LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY POS_N_REGISTER IS
    GENERIC (N : INTEGER := 32);
    PORT (
        Enable    : IN STD_LOGIC;
        clk, rst  : IN STD_LOGIC;
        D         : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        Q         : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        rst_value : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0') -- Reset to rst_value if provided, else reset to zeros [This is an optional parameter]
    );
END POS_N_REGISTER;

ARCHITECTURE arch_Register OF POS_N_REGISTER IS

    COMPONENT POS_D_FLIP_FLOP IS
        PORT (
            Enable    : IN STD_LOGIC;
            clk, rst  : IN STD_LOGIC;
            D         : IN STD_LOGIC;
            Q         : OUT STD_LOGIC;
            rst_value : IN STD_LOGIC := '0'
        );
    END COMPONENT;

BEGIN

    generate_DFF_ARRAY : FOR i IN 0 TO N - 1 GENERATE
        DFF : POS_D_FLIP_FLOP PORT MAP(Enable, clk, rst, D(i), Q(i), rst_value(i));
    END GENERATE;

END ARCHITECTURE;
