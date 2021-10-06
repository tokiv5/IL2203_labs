use work.all;
use work.instructions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ROM is
    generic(N:integer:=16);
    port (
        clk, reset: IN std_logic;
        instr_head: IN std_logic_vector(3 downto 0);-- A6..A3: highest 4 bits of IR;
        flag: IN std_logic;-- A2: the selected flag;
        uPC: IN std_logic_vector(1 downto 0);-- A1A0: uPgmCounter for FSM;
        write, readA, readB, IE, OE, byPassA, byPassB, byPassW:OUT std_logic;
        op, SEL: OUT std_logic_vector(2 downto 0);
        LE: OUT std_logic_vector(3 downto 0);
        RW: OUT std_logic
    );
end entity ROM;

architecture data_flow of ROM is
 
    type u_instruction is record 
        write:std_logic;
        readA:std_logic;
        readB:std_logic;
        IE:std_logic;
        OE:std_logic;
        bypass:std_logic_vector(2 downto 0);
        op:op_alu;
        RW:std_logic;
        SEL:std_logic_vector(2 downto 0);
        LE:std_logic_vector(3 downto 0);
    end record; -- write, readA, readB, IE, OE, bypass(3 bits), op(3 bits),RW,SEL(2 downto 0),LE(3 downto 0);

    type u_program is array (natural range<>) of u_instruction;
    -- TODO:
    -- Check every set!
    constant ADD_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opADD,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant SUB_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opSUB,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant AND_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opAND,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant OR_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opOR,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant XOR_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opXOR,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant NOT_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opNOT,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant MOV_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('1','1','1','0','0',No_B,opMOV,'1',ZERO,L_FLAG), -- FO 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant NOP_u_program:u_program:=(
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- WA 
            ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
            ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
        );
    constant LD_u_program:u_program:=(
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','1','0','0',No_B,opMOV,'1',ZERO,L_FLAG), -- FO 
        ('1','1','0','0','1',BP_BW,opINCR,'1',ZERO,L_Addr), -- EX 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- WA 
    );
    constant ST_u_program:u_program:=(
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',ZERO,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant LDI_u_program:u_program:=(
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',ZERO,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant NU_u_program:u_program:=(
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',ZERO,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRZ_u_program_0:u_program:=( -- BRZ, A2=0
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opINCR,'1',ZERO,L_FLAG), -- FE1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRZ_u_program_1:u_program:=( -- BRZ, A2=1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',ZERO,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRN_u_program_0:u_program:=( -- BRN, A2=0
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opINCR,'1',NEGA,L_FLAG), -- FE1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRN_u_program_1:u_program:=( -- BRN, A2=1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',NEGA,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRO_u_program_0:u_program:=( -- BRO, A2=0
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opINCR,'1',NEGA,L_FLAG), -- FE1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRO_u_program_1:u_program:=( -- BRO, A2=1
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',NEGA,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );
    constant BRA_u_program:u_program:=(
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,L_IR), -- LI
        ('1','1','0','0','0',BP_BW,opADD,'1',ZERO,L_FLAG), -- FE1 
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None), -- FE2
        ('0','0','0','0','0',No_B,opMOV,'1',ZERO,None) -- LM
    );

    signal uInstr:u_instruction;

begin
    process(clk,instr_head)
    begin
        if rising_edge(clk) then
            case instr_head is
                -- ALU operations:
                when "0000" =>
                    uInstr <= ADD_u_program(conv_integer(uPC));
                when "0001" =>
                    uInstr <= SUB_u_program(conv_integer(uPC));
                when "0010" =>
                    uInstr <= AND_u_program(conv_integer(uPC));
                when "0011" =>
                    uInstr <= OR_u_program(conv_integer(uPC));
                when "0100" =>
                    uInstr <= XOR_u_program(conv_integer(uPC));
                when "0101" =>
                    uInstr <= NOT_u_program(conv_integer(uPC));
                when "0110" =>
                    uInstr <= MOV_u_program(conv_integer(uPC));
                when "0111" =>
                    uInstr <= NOP_u_program(conv_integer(uPC));
                -- other operations:
                when "1000" =>
                    uInstr <= LD_u_program(conv_integer(uPC));
                when "1001" =>
                    uInstr <= ST_u_program(conv_integer(uPC));
                when "1010" =>
                    uInstr <= LDI_u_program(conv_integer(uPC));
                when "1011" =>
                    uInstr <= NU_u_program(conv_integer(uPC));
                when "1100" =>
                    if (flag = '0') then
                        uInstr <= BRZ_u_program_0(conv_integer(uPC));
                    else
                        uInstr <= BRZ_u_program_1(conv_integer(uPC));
                    end if;
                when "1101" =>
                    if (flag = '0') then
                        uInstr <= BRN_u_program_0(conv_integer(uPC));
                    else
                        uInstr <= BRN_u_program_1(conv_integer(uPC));
                    end if;
                when "1110" =>
                    if (flag = '0') then
                        uInstr <= BRO_u_program_0(conv_integer(uPC));
                    else
                        uInstr <= BRO_u_program_1(conv_integer(uPC));
                    end if;
                when "1111" =>
                    uInstr <= BRA_u_program(conv_integer(uPC));
                when others =>
                    uInstr <= NOP_u_program(conv_integer(uPC));
            end case;
        end if;
    end process;

    -- To be used by the FSM:
    LE <= uInstr.LE;
    SEL <= uInstr.SEL;
    -- To be used by external memory:
    RW <= uInstr.RW;
    -- To be sent to datapath:
    write <= uInstr.write;
    readA <= uInstr.readA;
    readB <= uInstr.readB;
    IE <= uInstr.IE;
    OE <= uInstr.OE;
    byPassA <= uInstr.byPass(2);
    byPassB <= uInstr.byPass(1);
    byPassW <= uInstr.byPass(0);
    op <= uInstr.op;
    
end architecture data_flow;
