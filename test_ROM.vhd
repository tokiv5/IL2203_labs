use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture test_ROM of test is
    constant N:integer:=4;
    constant M:integer:=3;
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
    
    signal clk, reset: std_logic:='0';
    signal instr_head:std_logic_vector(3 downto 0);-- A6..A3: highest 4 bits of IR;
    signal flag:std_logic;-- A2: the selected flag;
    signal uPC:std_logic_vector(1 downto 0);-- A1A0: uPgmCounter for FSM;
    
    signal write, readA, readB, IE, OE, byPassA, byPassB, byPassW:std_logic;
    signal op, SEL: std_logic_vector(2 downto 0);
    signal LE: std_logic_vector(3 downto 0);
    signal RW: std_logic;
    
    -- type int_array is array(integer range<>) of integer;
    -- constant values:int_array:=(0,1,2,3,4,5,6,7);
    
begin
    DUT: ROM port map(
        clk, reset,
        instr_head,flag,uPC,
        write, readA, readB, IE, OE, byPassA, byPassB, byPassW, op, 
        SEL, LE, RW
    );


    clk <= not clk after 5 ns;
    reset <= '1' after 3 ns, '0' after 8 ns;

    instr_head <= "0000";
    flag <= '0';
    uPC <= "00";

end architecture test_ROM;