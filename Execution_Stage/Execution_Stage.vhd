LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY Execution_Stage IS
    PORT (
        clk, rst                           : IN STD_LOGIC;
        isLoadStore, hasNextOperand        : IN STD_LOGIC;
        push, pop, branch, jump            : IN STD_LOGIC;
        ID_EX_Rsrc, ID_EX_Rdst             : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
        EX_Mem_Rdst, Mem_WB_Rdst           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        EX_Mem_WriteBack, Mem_WB_WriteBack : IN STD_LOGIC;
        RsrcData, RdstData                 : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        Mem_Stage_Out, WB_Stage_Out        : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
        ImmediateValue                     : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        OpCode                             : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
        PCin                               : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
        InPort                             : IN STD_LOGIC_VECTOR(31 DOWNTO 0);

        PCout                              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        OutPort                            : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        RsrcOut, AluOut                    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        isBranchTaken                      : OUT STD_LOGIC
    );
END Execution_Stage;

ARCHITECTURE arch_Execution_Stage OF Execution_Stage IS
    COMPONENT ALU IS
        PORT (
            clk, rst   : IN STD_LOGIC;
            push, pop  : IN STD_LOGIC;
            opcode     : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            Rsrc, Rdst : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            InPort     : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            Rout       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            OutPort    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Flags      : OUT STD_LOGIC_VECTOR(2 DOWNTO 0) -- Flags bits order : Carry, Negative, Zero
        );
    END COMPONENT;

    COMPONENT Forwarding_Unit IS
        PORT (
            ID_EX_Rsrc, ID_EX_Rdst             : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_Mem_Rdst, Mem_WB_Rdst           : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            EX_Mem_WriteBack, Mem_WB_WriteBack : IN STD_LOGIC;
            Sel_Rsrc, Sel_Rdst                 : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT BRANCH_CONTROL IS
        PORT (
            CLK, RESET, HAS_NEXT_OPERAND, BRANCH, JMP : IN STD_LOGIC;
            PC_IN, R_DEST_ADDRESS                     : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
            OPCODE                                    : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
            FLAGS                                     : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            IS_BRANCH_TAKEN                           : OUT STD_LOGIC;
            PC_OUT                                    : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    END COMPONENT;


    SIGNAL Flags                        : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL Sel_Rsrc, Sel_Rdst           : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL aluRsrc, aluRdst             : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL forwardedRsrc, forwardedRdst : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL extendedImmediateValue       : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    RsrcOut                              <= forwardedRsrc;
    extendedImmediateValue(31 DOWNTO 16) <= (OTHERS => ImmediateValue(15));
    extendedImmediateValue(15 DOWNTO 0)  <= ImmediateValue;

    forwardedRsrc <= Mem_Stage_Out WHEN Sel_Rsrc = "01" ELSE
                     WB_Stage_Out  WHEN Sel_Rsrc = "10" ELSE
                     RsrcData;

    forwardedRdst <= Mem_Stage_Out WHEN Sel_Rdst = "01" ELSE
                     WB_Stage_Out  WHEN Sel_Rdst = "10" ELSE
                     RdstData;

    aluRsrc <= forwardedRsrc WHEN hasNextOperand = '0' ELSE
               extendedImmediateValue;

    aluRdst <= forwardedRsrc WHEN (isLoadStore = '1' OR hasNextOperand = '1') ELSE
               forwardedRdst;

    alu_unit    : ALU PORT MAP(clk, rst, push, pop, OpCode, aluRsrc, aluRdst, InPort, AluOut, OutPort, Flags);
    forward     : Forwarding_Unit PORT MAP(ID_EX_Rsrc, ID_EX_Rdst, EX_Mem_Rdst, Mem_WB_Rdst, EX_Mem_WriteBack, Mem_WB_WriteBack, Sel_Rsrc, Sel_Rdst);
    branch_unit : BRANCH_CONTROL PORT MAP(clk, rst, hasNextOperand, branch, jump, PCin, forwardedRdst, OpCode, Flags, isBranchTaken, PCout);

END ARCHITECTURE;
