LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Forwarding_Unit IS
    PORT (
        ID_EX_Rsrc, ID_EX_Rdst             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_Mem_Rdst, Mem_WB_Rdst           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_Mem_WriteBack, Mem_WB_WriteBack : IN STD_LOGIC;
        Sel_Rsrc, Sel_Rdst                 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
    );
END Forwarding_Unit;

ARCHITECTURE arch_Forwarding_Unit OF Forwarding_Unit IS

BEGIN

    Sel_Rsrc <= "01" WHEN (EX_Mem_WriteBack = '1' AND EX_Mem_Rdst = ID_EX_Rsrc) ELSE
                "10" WHEN (Mem_WB_WriteBack = '1' AND Mem_WB_Rdst = ID_EX_Rsrc) ELSE
                "11";

    Sel_Rdst <= "01" WHEN (EX_Mem_WriteBack = '1' AND EX_Mem_Rdst = ID_EX_Rdst) ELSE
                "10" WHEN (Mem_WB_WriteBack = '1' AND Mem_WB_Rdst = ID_EX_Rdst) ELSE
                "11";

END ARCHITECTURE;
