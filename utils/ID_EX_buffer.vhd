LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY ID_EX_buffer IS
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
END ID_EX_buffer;

ARCHITECTURE arch_ID_EX_buffer OF ID_EX_buffer IS

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

    SIGNAL controlSignalsIn : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL controlSignalsOut : STD_LOGIC_VECTOR (8 DOWNTO 0);

BEGIN
    controlSignalsIn <= MR & MW & WB & isLoadStore & pop & push & branch & jump & hasNextOp;

    R0 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clk, reset, RsrcData, RsrcDataOut);
    R1 : POS_N_REGISTER GENERIC MAP(3) PORT MAP('1', clk, reset, RsrcAddress, RsrcAddressOut);

    R2 : POS_N_REGISTER GENERIC MAP(32) PORT MAP('1', clk, reset, RdestData, RdestDataOut);
    R3 : POS_N_REGISTER GENERIC MAP(3) PORT MAP('1', clk, reset, RdestAddress, RdestAddressOut);

    R4 : POS_N_REGISTER GENERIC MAP(16) PORT MAP('1', clk, reset, ImmediateVal, ImmediateValOut);

    R5 : POS_N_REGISTER GENERIC MAP(5) PORT MAP('1', clk, reset, OpCode, OpCodeOut);

    R6 : POS_N_REGISTER GENERIC MAP(9) PORT MAP('1', clk, reset, controlSignalsIn, controlSignalsOut);

    MROut <= controlSignalsOut(8);
    MWOut <= controlSignalsOut(7);
    WBOut <= controlSignalsOut(6);
    isLoadStoreOut <= controlSignalsOut(5);
    popOut <= controlSignalsOut(4);
    pushOut <= controlSignalsOut(3);
    branchOut <= controlSignalsOut(2);
    jumpOut <= controlSignalsOut(1);
    hasNextOpOut <= controlSignalsOut(0);

END ARCHITECTURE;