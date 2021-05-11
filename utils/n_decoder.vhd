LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY N_DECODER IS
    GENERIC (N : INTEGER := 4); -- N=2 means 2x4 Decoder, N=3 means 3x8 ...
    PORT (
        Enable : IN STD_LOGIC;
        Input  : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
        Output : OUT STD_LOGIC_VECTOR ((2 ** N) - 1 DOWNTO 0)
    );
END N_DECODER;

ARCHITECTURE arch_DECODER OF N_DECODER IS

BEGIN
    PROCESS (Enable, Input)
    BEGIN
        Output <= (OTHERS => '0');
        IF (Enable = '1') THEN
            Output(to_integer(unsigned(Input))) <= '1';
        END IF;

    END PROCESS;

END ARCHITECTURE;
