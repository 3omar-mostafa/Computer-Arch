LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NEG_N_REGISTER IS
    GENERIC (N : INTEGER := 32);
    PORT (
        Enable   : IN STD_LOGIC;
        clk, rst : IN STD_LOGIC;
        D        : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        Q        : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0)
    );
END NEG_N_REGISTER;

ARCHITECTURE arch_Register OF NEG_N_REGISTER IS

    COMPONENT NEG_D_FLIP_FLOP IS
        PORT (
            Enable   : IN STD_LOGIC;
            clk, rst : IN STD_LOGIC;
            D        : IN STD_LOGIC;
            Q        : OUT STD_LOGIC
        );
    END COMPONENT;

BEGIN

    generate_DFF_ARRAY : FOR i IN 0 TO N - 1 GENERATE
        DFF : NEG_D_FLIP_FLOP PORT MAP(Enable, clk, rst, D(i), Q(i));
    END GENERATE;

END ARCHITECTURE;
