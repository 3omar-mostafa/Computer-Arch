LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MAIN IS
    PORT (
        CLK, RST : IN STD_LOGIC
    );
END MAIN;

ARCHITECTURE MAIN_ARCH OF MAIN IS

    COMPONENT IF_ID_buffer IS
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            IRInput : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            IROutput : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT ID_EX_buffer IS
        PORT (
            clk, reset, MR, MW, WB, isLoadStore, pop, push, branch, jump, hasNextOp : IN STD_LOGIC;
            RsrcAddress, RdestAddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            RsrcData, RdestData : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            ImmediateVal : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            OpCode : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            OpCodeOut : OUT STD_LOGIC_VECTOR (4 DOWNTO 0);
            ImmediateValOut : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            MROut, MWOut, WBOut, isLoadStoreOut, popOut, pushOut, branchOut, jumpOut, hasNextOpOut : OUT STD_LOGIC;
            RsrcDataOut, RdestDataOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            RsrcAddressOut, RdestAddressOut : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT EX_MEM_buffer IS
        PORT (
            clock, reset, MR, MW, WB : IN STD_LOGIC;
            RdestAddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            Rsrc, AluIn : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            MROut, MWOut, WBOut : OUT STD_LOGIC;
            RdestAddressOut : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            RsrcOut, AluOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT MEM_WB_buffer IS
        PORT (
            clock, reset, MR, WB : IN STD_LOGIC;
            RdestAddress : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            memoryDataIn, AluIn : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            MROut, WBOut : OUT STD_LOGIC;
            RdestAddressOut : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
            memoryDataOut, AluOut : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;


    --
    --             *****         DECODE STAGE         *****
    --
    COMPONENT CONTROL_UNIT IS
        PORT (
            CLK, RESET : IN STD_LOGIC;
            IR : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            IS_LOAD_STORE, MEM_READ, MEM_WRITE, WRITE_BACK, BRANCH, JMP, HAS_NEXT_OPERAND, PUSH, POP : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT IR_DECODER IS
        PORT (
            IR_REGISTER : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            FLAGS : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            CLK, RST : IN STD_LOGIC;
            BRANCH_ADDRESS : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            PC_OUT, MDR_OUT, Z_OUT, TEMP_OUT, PC_IN, Z_IN, TEMP_IN, MDR_IN, MAR_IN, Y_IN, IR_IN, READ_MEM, WRITE_MEM, CLEAR_Y, FLAG_EN, WMFC, ADDRESS_OUT : OUT STD_LOGIC;
            GENERAL_REGISTERS_IN, GENERAL_REGISTERS_OUT : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            ALU_OPERATION : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            RAM_TO_MDR : IN STD_LOGIC
        );
    END COMPONENT;

    COMPONENT REG_FILE IS
        PORT (
            CLK, RESET : IN STD_LOGIC;
            DATA_IN : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            R_DEST_EN : IN STD_LOGIC;
            R_SRC_NUM : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            R_DEST_NUM : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            R_SRC_OUT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            R_DEST_OUT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;


    --
    --             *****         EXECUTE STAGE        *****
    --
    COMPONENT ALU IS
        PORT (
            push, pop : IN STD_LOGIC;
            clk, rst : IN STD_LOGIC;
            opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            Rsrc, Rdst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            InPort : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            Rout : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            OutPort : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Flags : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Flags bits order : Carry, Negative, Zero
        );
    END COMPONENT;

    COMPONENT BRANCH_CONTROL IS
        PORT (
            CLK, RESET, HAS_NEXT_OPERAND, BRANCH, JMP : IN STD_LOGIC;
            PC_IN, R_DEST_ADDRESS : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            OPCODE : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            FLAGS : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            IS_BRANCH_TAKEN : OUT STD_LOGIC;
            PC_OUT : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT Forwarding_Unit IS
        PORT (
            ID_EX_Rsrc, ID_EX_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_Mem_Rdst, Mem_WB_Rdst : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_Mem_WriteBack, Mem_WB_WriteBack : IN STD_LOGIC;
            Sel_Rsrc, Sel_Rdst : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;



    COMPONENT Ram IS
        GENERIC (
            RamAddrWidth : INTEGER := 20;
            DataWidth : INTEGER := 32
        );
        PORT (
            Clk : IN STD_LOGIC;
            MW, MR : IN STD_LOGIC;
            Address : IN STD_LOGIC_VECTOR(RamAddrWidth - 1 DOWNTO 0);
            RamDataIn : IN STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0);
            RamDataOut : OUT STD_LOGIC_VECTOR(DataWidth - 1 DOWNTO 0));
    END COMPONENT;


    COMPONENT POS_N_REGISTER IS
        GENERIC (N : INTEGER := 32);
        PORT (
            Enable : IN STD_LOGIC;
            clk, rst : IN STD_LOGIC;
            D : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            Q : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            rst_value : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0') -- Reset to rst_value if provided, else reset to zeros [This is an optional parameter]
        );
    END COMPONENT;
BEGIN

END MAIN_ARCH;