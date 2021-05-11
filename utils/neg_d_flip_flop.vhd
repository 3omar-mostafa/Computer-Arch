LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY NEG_D_FLIP_FLOP IS
    PORT (
        Enable   : IN STD_LOGIC;
        clk, rst : IN STD_LOGIC;
        D        : IN STD_LOGIC;
        Q        : OUT STD_LOGIC
    );
END NEG_D_FLIP_FLOP;

ARCHITECTURE arch_D_FLIP_FLOP OF NEG_D_FLIP_FLOP IS

BEGIN

    Q <= '0' WHEN rst = '1' ELSE
        D WHEN Enable = '1' AND rst = '0' AND falling_edge(clk);

END ARCHITECTURE;
