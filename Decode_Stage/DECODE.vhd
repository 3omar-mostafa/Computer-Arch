LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY Decoding_Stage IS
    PORT (
        CLK, RESET                                                                               : IN STD_LOGIC;
        IR                                                                                       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        REG_FILE_DATA_IN                                                                         : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        REG_FILE_R_DEST_EN                                                                       : IN STD_LOGIC;
        REG_FILE_R_DEST_NUM_WB                                                                   : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        IS_LOAD_STORE, MEM_READ, MEM_WRITE, WRITE_BACK, BRANCH, JMP, HAS_NEXT_OPERAND, PUSH, POP : OUT STD_LOGIC;
        RsrcAddress, RdestAddress                                                                : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        RsrcData, RdestData                                                                      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        OpCode                                                                                   : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
        ImmediateVal                                                                             : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END Decoding_Stage;

ARCHITECTURE DECODE_ARCH OF Decoding_Stage IS

    COMPONENT CONTROL_UNIT IS
        PORT (
            CLK, RESET                                                                               : IN STD_LOGIC;
            IR                                                                                       : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            IS_LOAD_STORE, MEM_READ, MEM_WRITE, WRITE_BACK, BRANCH, JMP, HAS_NEXT_OPERAND, PUSH, POP : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT IR_DECODER IS
        PORT (
            CLK, RESET            : IN STD_LOGIC;
            IR                    : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            R_SRC_NUM, R_DEST_NUM : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            OPCODE                : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
            IMMEDIATE             : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT REG_FILE IS
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
    END COMPONENT;

    SIGNAL IR_R_SRC_NUM, IR_R_DEST_NUM : STD_LOGIC_VECTOR (2 DOWNTO 0);
BEGIN

    CU : CONTROL_UNIT PORT MAP(CLK, RESET, IR, IS_LOAD_STORE, MEM_READ, MEM_WRITE, WRITE_BACK, BRANCH, JMP, HAS_NEXT_OPERAND, PUSH, POP);

    IR_D : IR_DECODER PORT MAP(CLK, RESET, IR, IR_R_SRC_NUM, IR_R_DEST_NUM, OpCode, ImmediateVal);

    REG_F : REG_FILE PORT MAP(CLK, RESET, REG_FILE_DATA_IN, REG_FILE_R_DEST_EN, REG_FILE_R_DEST_NUM_WB, IR_R_SRC_NUM, IR_R_DEST_NUM, RsrcData, RdestData);
    
    RsrcAddress <= IR_R_SRC_NUM;

    RdestAddress <= IR_R_DEST_NUM;

END DECODE_ARCH;