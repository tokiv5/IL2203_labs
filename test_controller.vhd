use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

architecture test_controller of test is
    component controller
    generic(N: integer:= 16);
    port(
        clk, reset: IN std_logic;
        out_clk, RW: OUT std_logic;
        IR_tmp: IN std_logic_vector(15 downto 0);
        input_data: IN std_logic_vector(N-1 downto 0)
    );
    end component;
    signal clk, reset: std_logic:= '0';
    signal out_clk, RW: std_logic;
    signal IR_tmp: std_logic_vector(15 downto 0);
    signal input_data: std_logic_vector(15 downto 0):= (others => '0');
    signal PC_test: integer:= 0;
    type INS is array(integer range<>) of std_logic_vector;
    constant instructions: INS:= (("0101000000000000"), -- Not R0 R0
                                  ("0000001000010000"), -- Add R1 R0 R2
                                  ("1101000000001000"), -- BRN 8
                                  ("1111000000000100"), -- BRA 4
                                  ("1010100000010000") -- LDI R4 16
                                  ); 
begin
    DUT: controller port map(clk, reset, out_clk, RW, IR_tmp, input_data);
    clk <= not clk after 5 ns;
    P0 : process
    begin
        IR_tmp <= instructions(PC_test);
        wait for 40ns;
        PC_test <= PC_test + 1;
    end process ; -- P0
end test_controller ; -- test_controller