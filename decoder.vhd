library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity decoder is
    generic(N:integer:=16);
    port(
        ins_OP: IN std_logic_vector(3 downto 0); -- From IR, to tell which instruction is
        flags, clk, reset: IN std_logic; --From flag mux
        RA_enable, RB_enable, WA_enable, byPassB, byPassW, IE, OE, RW: OUT std_logic; -- uInstruction
        op, SEL: OUT std_logic_vector(2 downto 0); -- uInstruction for ALU
        LE: OUT std_logic_vector(3 downto 0) -- Latch signal for IR, flag, Addr and Dout
    );
end entity decoder;

architecture structure of decoder is
    signal pres_state: std_logic_vector(1 downto 0) := "00"; -- uPC

    subtype opCode is std_logic_vector(2 downto 0);
    constant opADD: opCode:= "000";
    constant opSUB: opCode:= "001";
    constant opAND: opCode:= "010";
    constant opOR: opCode:= "011";
    constant opXOR: opCode:= "100";
    constant opNOT: opCode:= "101";
    constant opMOV: opCode:= "110";
    constant opINC: opCode:= "111";

    subtype selFlag is std_logic_vector(2 downto 0);
    constant ZFL: selFlag:= "100";
    constant NFL: selFlag:= "010";
    constant OFL: selFlag:= "001";

    subtype latchEn is std_logic_vector(3 downto 0);
    constant L_IR: latchEn:= "1000";
    constant L_Flag: latchEn:= "0100";
    constant L_Addr: latchEn:= "0010";
    constant L_Dout: latchEn:= "0001";
    constant L_none: latchEn:= "0000";

    type uIns is record
        IE: std_logic;
        bypass: std_logic_vector(1 downto 0); --BW B W none
        WA_en: std_logic;
        RA_en: std_logic;
        RB_en: std_logic;
        ALU: opCode;
        OE: std_logic; -- useless ?
        RW: std_logic; -- for mem ?
        SEL: selFlag; -- flags select
        LE: std_logic_vector(3 downto 0); -- What is this ?
    end record;

    type uPr is array(0 to 3) of uIns; -- four states FSM

    -- IE, ByPass, WA, RA, RB, op, OE, RW, SEL. LE
    constant uADD: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opADD, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    constant uSUB: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opSUB, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    constant uAND: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opAND, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    constant uOR: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opOR, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );
    
    constant uXOR: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opXOR, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    constant uNOT: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opNOT, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    constant uMOV: uPr:= (
        ('0', "00", '0', '0', '0', opADD, '1', '0', ZFL, L_none),
        ('0', "00", '0','1','1', opMOV, '1', '0' ,ZFL , L_IR), -- FO
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_Flag), -- EX
        ('0', "10", '1','0','0', opMOV,'1', '0', ZFL, L_Addr) -- WA
    );

    -- constant uINC: uPr:= (
    --     ('0', "00", '0', '0', '0', opINC, '0', '0', ZFL, L_IR),
    --     ('0', "00", '1','1','1', opINC, '0', '0' ,ZFL , L_FLAG), -- FO
    --     ('0', "11", '1','1','0', opINC, '1', '0' ,ZFL, L_Addr), -- EX
    --     ('0', "00", '0','0','0', opMOV,'0', '0', ZFL, L_none) -- WA
    -- );

    constant uNOP: uPr:= (
        ('0', "00", '0', '0', '0', opINC, '1', '0', ZFL, L_none),
        ('0', "01", '1','1','0', opINC, '1', '0' ,ZFL, L_IR), -- EX
        ('0', "10", '0','0','0', opMOV, '1', '0' ,ZFL , L_Addr), -- FO
        ('0', "00", '0','0','0', opMOV,'1', '0', ZFL, L_none) -- WA
    );

    constant uBRZ_F: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_IR),
        ('0', "01", '0', '1','0', opINC, '1', '0', ZFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );

    constant uBRZ_T: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_IR),
        ('0', "01", '0', '1','0', opADD, '1', '0', ZFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );

    constant uBRN_F: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', NFL, L_IR),
        ('0', "01", '0', '1','0', opINC, '1', '0', NFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );

    constant uBRN_T: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', NFL, L_IR),
        ('0', "01", '0', '1','0', opADD, '1', '0', NFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );

    constant uBRO_F: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', OFL, L_IR),
        ('0', "01", '0', '1','0', opINC, '1', '0', OFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );
    
    constant uBRO_T: uPr:= (
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "00", '0', '0', '0', opMOV, '1', '0', OFL, L_IR),
        ('0', "01", '0', '1','0', opADD, '1', '0', OFL, L_Flag),
        ('0', "10", '1', '0','0', opMOV,'1', '0', ZFL, L_Addr)
    );

    constant uBRA: uPr:= ( 
        ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
        ('0', "01", '0','1','0', opADD, '1', '0' ,ZFL, L_IR),
        ('0', "10", '1', '0', '0', opMOV, '1', '0', ZFL, L_Addr),
        ('0', "00", '0', '0', '0', opMOV,'1', '0', ZFL, L_none)
    );

    -- constant uST: uPr:= (
    --     ('0', "00", '0', '0', '0', opMOV, '1', '0', ZFL, L_none),
    -- );
    
    signal pres_uPr: uPr;
begin
    pres_uPr <= uADD when ins_OP = "0000" else
        uSUB when ins_OP = "0001" else
        uAND when ins_OP = "0010" else
        uOR when ins_OP = "0011" else
        uXOR when ins_OP = "0100" else
        uNOT when ins_OP = "0101" else
        uMOV when ins_OP = "0110" else
        uNOP when ins_OP = "0111" else
        uBRZ_F when ins_OP = "1100" and flags = '0' else
        uBRZ_T when ins_OP = "1100" and flags = '1' else
        uBRN_F when ins_OP = "1101" and flags = '0' else
        uBRN_T when ins_OP = "1101" and flags = '1' else
        uBRO_F when ins_OP = "1110" and flags = '0' else
        uBRO_T when ins_OP = "1110" and flags = '1' else
        uBRA when ins_OP = "1111" else
        uNOP;
    
    -- IE, ByPass, WA, RA, RB, op, OE, RW, SEL. LE
    process(clk, reset)
    begin
        if reset = '1' then
            pres_state <= "00";
            IE <= '0';
            byPassB <= '0';
            byPassW <= '0';
            WA_enable <= '0';
            RA_enable <= '0';
            RB_enable <= '0';
            op <= "000";
            OE <= '0';
            RW <= '0';
            SEL <= ZFL;
            LE <= L_IR;
        elsif clk'event and clk = '1' then
            IE <= pres_uPr(conv_integer(pres_state)).IE;
            byPassB <= pres_uPr(conv_integer(pres_state)).bypass(0);
            byPassW <= pres_uPr(conv_integer(pres_state)).bypass(1);
            WA_enable <= pres_uPr(conv_integer(pres_state)).WA_en;
            RA_enable <= pres_uPr(conv_integer(pres_state)).RA_en;
            RB_enable <= pres_uPr(conv_integer(pres_state)).RB_en;
            op <= pres_uPr(conv_integer(pres_state)).ALU;
            OE <= pres_uPr(conv_integer(pres_state)).OE;
            RW <= pres_uPr(conv_integer(pres_state)).RW;
            SEL <= pres_uPr(conv_integer(pres_state)).SEL;
            LE <= pres_uPr(conv_integer(pres_state)).LE;
            pres_state <= pres_state + 1;
            -- case pres_state is
            --     when "00" =>
            --         IE <= pres_uPr(0).IE;
            --         byPassB <= pres_uPr(0).bypass(0);
            --         byPassW <= pres_uPr(0).bypass(1);
            --         WA_enable <= pres_uPr(0).WA_en;
            --         RA_enable <= pres_uPr(0).RA_en;
            --         RB_enable <= pres_uPr(0).RB_en;
            --         op <= pres_uPr(0).ALU;
            --         OE <= pres_uPr(0).OE;
            --         RW <= pres_uPr(0).RW;
            --         SEL <= pres_uPr(0).SEL;
            --         LE <= pres_uPr(0).LE;
            --         pres_state <= "01";
            --     when "01" =>
            --         IE <= pres_uPr(1).IE;
            --         byPassB <= pres_uPr(1).bypass(0);
            --         byPassW <= pres_uPr(1).bypass(1);
            --         WA_enable <= pres_uPr(1).WA_en;
            --         RA_enable <= pres_uPr(1).RA_en;
            --         RB_enable <= pres_uPr(1).RB_en;
            --         op <= pres_uPr(1).ALU;
            --         OE <= pres_uPr(1).OE;
            --         RW <= pres_uPr(1).RW;
            --         SEL <= pres_uPr(1).SEL;
            --         LE <= pres_uPr(1).LE;
            --         pres_state <= "10";
            --     when "10" =>
            --         IE <= pres_uPr(2).IE;
            --         byPassB <= pres_uPr(2).bypass(0);
            --         byPassW <= pres_uPr(2).bypass(1);
            --         WA_enable <= pres_uPr(2).WA_en;
            --         RA_enable <= pres_uPr(2).RA_en;
            --         RB_enable <= pres_uPr(2).RB_en;
            --         op <= pres_uPr(2).ALU;
            --         OE <= pres_uPr(2).OE;
            --         RW <= pres_uPr(2).RW;
            --         SEL <= pres_uPr(2).SEL;
            --         LE <= pres_uPr(2).LE;
            --         pres_state <= "11";
            --     when "11" =>
            --         IE <= pres_uPr(3).IE;
            --         byPassB <= pres_uPr(3).bypass(0);
            --         byPassW <= pres_uPr(3).bypass(1);
            --         WA_enable <= pres_uPr(3).WA_en;
            --         RA_enable <= pres_uPr(3).RA_en;
            --         RB_enable <= pres_uPr(3).RB_en;
            --         op <= pres_uPr(3).ALU;
            --         OE <= pres_uPr(3).OE;
            --         RW <= pres_uPr(3).RW;
            --         SEL <= pres_uPr(3).SEL;
            --         LE <= pres_uPr(3).LE;
            --         pres_state <= "00";
            --     when others =>
            --         pres_state <= "00";
            --         IE <= '0';
            --         byPassB <= '0';
            --         byPassW <= '0';
            --         WA_enable <= '0';
            --         RA_enable <= '0';
            --         RB_enable <= '0';
            --         op <= "000";
            --         OE <= '0';
            --         RW <= '0';
            --         SEL <= ZFL;
            --         LE <= L_IR;
            -- end case;
            
        end if; 
    end process;
end structure; -- structure