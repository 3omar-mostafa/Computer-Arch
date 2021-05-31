LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY IR_DECODER IS
    PORT (
        CLK, RESET            : IN STD_LOGIC;
        IR                    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        R_SRC_NUM, R_DEST_NUM : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        OPCODE                : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        IMMEDIATE             : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END IR_DECODER;

-- IR Format From 31 DOWNTO 16
-- Control_Signals | OPCode | Rsrc | Rdst | 0 |
--       0000      | 00000  | 000  | 000  | 0 |
--       |  |      | |   |  | | |  | | |  | | |
--       V  V      | V   V  | V V  | V V  | V |
--      31  28     | 27  23 |22 20 |19 17 |16 |

ARCHITECTURE ARCH_IR_DECODER OF IR_DECODER IS

BEGIN

    PROCESS (CLK, RESET)
    BEGIN

        IF RESET = '1' THEN

            R_SRC_NUM  <= (OTHERS => '0');
            R_DEST_NUM <= (OTHERS => '0');
            OPCODE     <= (OTHERS => '0');
            IMMEDIATE  <= (OTHERS => '0');

        ELSIF RISING_EDGE(CLK) THEN

            R_DEST_NUM <= IR(19 DOWNTO 17);
            R_SRC_NUM  <= IR(22 DOWNTO 20);
            OPCODE     <= IR(27 DOWNTO 23);
            IMMEDIATE  <= IR(15 DOWNTO 0);

        END IF;
    END PROCESS;

END ARCHITECTURE;
