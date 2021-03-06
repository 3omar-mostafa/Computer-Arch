LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY POS_D_FLIP_FLOP IS
    PORT (
        Enable    : IN STD_LOGIC;
        clk, rst  : IN STD_LOGIC;
        D         : IN STD_LOGIC;
        Q         : OUT STD_LOGIC;
        rst_value : IN STD_LOGIC := '0' -- Reset to rst_value if provided, else reset to zeros
    );
END POS_D_FLIP_FLOP;

ARCHITECTURE arch_D_FLIP_FLOP OF POS_D_FLIP_FLOP IS

BEGIN

    Q <= rst_value WHEN rst = '1' ELSE
        D WHEN Enable = '1' AND rst = '0' AND rising_edge(clk);

END ARCHITECTURE;
