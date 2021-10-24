use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

architecture test_decoder of test is

    constant N: integer:= 16;
    constant M: integer:= 3;
    component decoder
    port(
        ins_OP: IN std_logic_vector(3 downto 0):= "0000"; -- From IR, to tell which instruction is
        flags, clk, reset: IN std_logic; --From flag mux
        RA_enable, RB_enable, WA_enable, byPassB, byPassW, IE, OE, RW: OUT std_logic; -- uInstruction
        op, SEL: OUT std_logic_vector(2 downto 0); -- uInstruction for ALU
        LE: OUT std_logic_vector(3 downto 0) -- Latch signal for IR, flag, Addr and Dout
    ); 
    end component;

    signal ins_OP: std_logic_vector(3 downto 0) := "0000";
    signal LE: std_logic_vector(3 downto 0);
    signal clk, flags, reset, RA_enable, RB_enable, WA_enable, byPassB, byPassW, IE, OE, RW: std_logic:= '0';
    signal op, SEL: std_logic_vector(2 downto 0);

begin
    DUT: decoder port map(ins_OP, flags, clk, reset, RA_enable, RB_enable, WA_enable, byPassB, byPassW, IE, OE, RW, op, SEL, LE);
    clk <= not clk after 5 ns;
    flags <= '0';
    process
    begin
        wait for 40 ns;
        ins_OP <= ins_OP + 1;
    end process;
end test_decoder ; -- testbench