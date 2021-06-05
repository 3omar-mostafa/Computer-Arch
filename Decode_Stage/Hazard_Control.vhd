LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY hazard_control IS
    PORT (
        clk, Rst : IN STD_LOGIC;
        CurrentIR, NextIR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        IsLoadUse : OUT STD_LOGIC
    );
END hazard_control;

ARCHITECTURE arch_hazard_control OF hazard_control IS

    -- IR Format From 31 DOWNTO 16
    -- Control_Signals | OPCode | Rsrc | Rdst | 0 |
    --       0000      | 00000  | 000  | 000  | 0 |
    --       |  |      | |   |  | | |  | | |  | | |
    --       V  V      | V   V  | V V  | V V  | V |
    --      31  28     | 27  23 |22 20 |19 17 |16 |

    SIGNAL CurrentRdst, CurrentRsrc, NextRdst, NextRsrc : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL NextOpCode : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL isLoadInstruction, isNotUseInstruction, isSpecialCase : STD_LOGIC;
BEGIN
    CurrentRdst <= CurrentIR(19 DOWNTO 17);
    CurrentRsrc <= CurrentIR(22 DOWNTO 20);
    NextRsrc    <= NextIR(22 DOWNTO 20);
    NextRdst    <= NextIR(19 DOWNTO 17);
    NextOpCode  <= NextIR(31 DOWNTO 23);

    isLoadInstruction <= '1' WHEN CurrentIR(31 DOWNTO 23) = "110110000" ELSE '0';

    isNotUseInstruction <= '1' WHEN 
                            (NextOpCode = "000000000" OR 
                            NextOpCode = "000000001" OR
                            NextOpCode = "000000010" OR
                            NextOpCode = "000000011" OR
                            NextOpCode = "000101001" OR 
                            NextOpCode = "010101101" OR 
                            NextOpCode = "100110100" OR 
                            NextOpCode = "000011101" OR 
                            NextOpCode = "000011110")
                            ELSE '0';

    isSpecialCase <= '1' WHEN (NextOpCode = "000110100" OR NextOpCode = "110110000") ELSE '0';

    IsLoadUse <= '1' WHEN (isNotUseInstruction = '0' AND isLoadInstruction = '1' AND isSpecialCase = '1' AND NextRsrc = CurrentRdst)
            ELSE '1' WHEN (isNotUseInstruction = '0' AND isLoadInstruction = '1' AND isSpecialCase = '0' AND ((NextRdst = CurrentRdst) OR (NextRsrc = CurrentRdst))) ELSE
                 '0';

END ARCHITECTURE;