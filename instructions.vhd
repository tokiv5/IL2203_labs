library IEEE;
use IEEE.std_logic_1164.all;

package instructions is

    subtype op_alu is std_logic_vector(2 downto 0);
    constant opADD:op_alu :="000";
    constant opSUB:op_alu :="001";
    constant opAND:op_alu :="010";
    constant opOR:op_alu :="011";
    constant opXOR:op_alu :="100";
    constant opNOT:op_alu :="101";
    constant opMOV:op_alu :="110";
    constant opINCR:op_alu :="111";

    
    subtype opcode is std_logic_vector(3 downto 0);
    constant ADD:opcode :="0000";
    constant iSUB:opcode :="0001";
    constant iAND:opcode :="0010";
    constant iOR:opcode :="0011";
    constant iXOR:opcode :="0100";
    constant iNOT:opcode :="0101";
    constant MOV:opcode :="0110";
    constant NOP:opcode :="0111";
    constant LD:opcode :="1000";
    constant ST:opcode :="1001";
    constant LDI:opcode :="1010";
    constant NU:opcode :="1011";
    constant BRZ:opcode :="1100";
    constant BRN:opcode :="1101";
    constant BRO:opcode :="1110";
    constant BRA:opcode :="1111";

    subtype bypass is std_logic_vector(2 downto 0);
    constant No_B:bypass:="000"; -- No Bypass
    constant BP_BW:bypass:="011"; -- Bypass B + Write
    constant BP_A:bypass:="100";
    constant BP_B:bypass:="010";
    constant BP_W:bypass:="001";
    
    subtype select_flag is std_logic_vector(2 downto 0);
    constant ZERO:select_flag :="001";
    constant NEGA:select_flag :="010";
    constant OVER:select_flag :="100";
    
    subtype reg_code is std_logic_vector(2 downto 0);
    constant R0:reg_code:="000";
    constant R1:reg_code:="001";
    constant R2:reg_code:="010";
    constant R3:reg_code:="011";
    constant R4:reg_code:="100";
    constant R5:reg_code:="101";
    constant R6:reg_code:="110";
    constant R7:reg_code:="111";

    subtype latch_enables is std_logic_vector(3 downto 0); 
    constant None:latch_enables :="0000";
    constant L_IR:latch_enables :="0001";
    constant L_ADDR:latch_enables :="0010";
    constant L_OUT:latch_enables :="0010";
    constant L_FLAG:latch_enables :="1000";


    -- type instruction is record
    --     OP:opcode;
    --     IE:std_logic;
    --     WrReg,ReadA,ReadB:regs;
    --     ALU,SHIFT:opcode;
    --     OE:std_logic;  
    -- end record;
    -- constant program:program:=(
    --     ('0',R0,R0,R0,OpXor,pass, '0'),      -- Create 0 (state S0) 
    --     ('1',R1,Rx,Rx,OpAnd,pass,'0'),       -- Data = Inport (R1) 
    --     ('0',R3,R0,R0,OpAdd,pass,'0'),       -- Ocount = 0 (R3) 
    --     ('0',R2,R0,Rx,OpIncr,pass,'0'),      -- Mask= 1 (Ocount+1) 
    --     ('0',R4,R1,R2,OpAnd,pass,'0'),       -- Temp = Data AND Mask
    --     ('0',R3,R3,R4,OpAdd,pass,'0'),       -- Ocount = Ocount + Temp 
    --     ('0',R1,R1,R0,OpAdd,shiftr,'1'),     -- Data = Data >> 1
    --     ('0',Rx,R3,R0,OpAdd,pass,'1')        -- Out = Ocount
    --     ); 

    subtype immediate is std_logic_vector(8 downto 0);

    subtype instruction is std_logic_vector(15 downto 0);
    constant Tail3:reg_code :="000";
    type program is array (natural range<>) of instruction;
    -- signal RAM:program(0 to 255):=( 
    --     (LDI & R5 & B"1_0000_0000"), 
    --     (ADD & R5 & R5 & R5 & Tail3), 
    --     (ADD & R5 & R5 & R5 & Tail3), 
    --     (ADD & R5 & R5 & R5 & Tail3), 
    --     (ADD & R5 & R5 & R5 & Tail3), 
    --     (LDI & R6 & B"0_0001_0100"),
    --     (iSUB & R0 & R0 & R1 & Tail3), 
    --     (BRZ & X"003"), -- exit
    --     (NOP & R0 & R0 & R0 & Tail3), 
    --     (BRA & X"FFC"), -- LoopA
    --     (ST & R0 & R6 & R2 & Tail3), -- exit 
    --     (ST & R0 & R5 & R2 & Tail3), 
    --     (BRA & X"000"),
    --     others=>(NOP & R0 & R0 & R0 & Tail3)
    --     );
    

    procedure create(
        signal A: IN std_logic_vector(6 downto 0);
        signal uInstr: OUT std_logic_vector(9 downto 0)
        );

end package;

package body instructions is
    procedure create(signal A: IN std_logic_vector(6 downto 0);signal uInstr: OUT std_logic_vector(9 downto 0)) is
    begin      
        -- TODO
        null;
    end procedure;
end package body;
