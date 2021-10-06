use work.all;
use work.instructions.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use work.micro_instruction.all;

entity CPU is
    generic(N:integer;
            M:integer);
    port(
        clk, reset:IN std_logic; -- use clk_50M for running on board
        Din:IN std_logic_vector(N-1 downto 0);
        Address:OUT std_logic_vector(N-1 downto 0);
        Dout:OUT std_logic_vector(N-1 downto 0);
        RW:OUT std_logic
    );
end entity CPU;

architecture structure of CPU is
    component datapath
        generic(N:integer:=16;
                M:integer:=3);
        port (
            input_data, offset: IN std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW:IN std_logic;
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            op: IN std_logic_vector(2 downto 0);
            output_data: OUT std_logic_vector(N-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic 
        );
    end component;

    component ROM
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
    end component;

    component divider
        port(
            clk_50M: IN std_logic;
            clk_1: OUT std_logic
        );
    end component;

    signal uPC:std_logic_vector(1 downto 0):= "00";
    signal flag:std_logic;
    signal offset_data,instruction_register,Dout_register,Address_register:std_logic_vector(15 downto 0);
    
    signal write, readA, readB, IE, OE, byPassA, byPassB, byPassW:std_logic;
    signal op, SEL:std_logic_vector(2 downto 0);
    signal LE: std_logic_vector(3 downto 0);
    signal Z_flag,Z_flag_register,N_flag,N_flag_register,O_flag,O_flag_register:std_logic;
    signal output_data: std_logic_vector(15 downto 0);
begin
    -- Uncomment this block to run on board:
    -- C0: divider
    -- port map(clk_50M => clk_50M,
    -- clk_1 => clk);

    R0: ROM 
    port map(
        clk => clk, 
        reset => reset,
        instr_head => instruction_register(15 downto 12) , -- A6..A3: highest 4 bits of IR;
        flag => flag,-- A2: the selected flag;
        uPC => uPC,-- A1A0: uPgmCount for FSM;
        -- uInstr => instruction_register(11 downto 0),
        IE => IE, 
        OE => OE, 
        byPassA =>byPassA, 
        byPassB => byPassB, 
        byPassW => byPassW,
        op => op,
        SEL => SEL,
        LE => LE,
        RW => RW
    );

    DP0: datapath 
    port map(input_data => Din, 
        offset => offset_data, 
        clk => clk, 
        reset => reset, 
        write => write, 
        readA => readA, 
        readB => readB,
        IE => IE, 
        OE => OE, 
        byPassA =>byPassA, 
        byPassB => byPassB, 
        byPassW => byPassW,
        WAddr=> instruction_register(11 downto 9),  
        RA => instruction_register(8 downto 6),  
        RB => instruction_register(5 downto 3), 
        op => op,
        output_data => output_data,
        Z_flag => Z_flag, 
        N_flag => N_flag, 
        O_flag => O_flag
    );

    -- Wires:
    Dout <= Dout_register;
    Address <= Address_register;
    -- Extend bits wide:
    offset_data <= "0000" & instruction_register(11 downto 0) when instruction_register(11) = '0' else "1111"& instruction_register(11 downto 0);
    -- TODO:
    -- What if here is the immediat data(9 bits)?


    process(clk, uPC)
    begin
        if clk'event and (clk='1') then -- Positive flank
            uPC <= uPC + 1;
        end if;
    end process;

    process(clk, SEL, Z_flag_register,N_flag_register,O_flag_register)
    begin
        if clk'event and (clk='1') then -- Positive flank
            case SEL is
                when "001" =>
                    flag <= Z_flag_register;
                when "010" => 
                    flag <= N_flag_register;
                when "100" => 
                    flag <= O_flag_register;
                when others =>
                    flag <= Z_flag_register;
            end case;
        end if;
    end process;

    process(clk, output_data,Din, Z_flag, N_flag, O_flag)
    begin
        if clk'event and (clk='1') then -- Positive flank
            case LE is
                when "0001" =>
                    instruction_register <= Din;
                when "0010" =>
                    Address_register <= output_data;
                when "0100" =>
                    Dout_register <= output_data;
                when "1000" =>
                     Z_flag_register <=Z_flag;
                     N_flag_register <=N_flag;
                     O_flag_register <=O_flag;
                when others =>
                    null;
            end case;
        end if;
    end process;

end structure;