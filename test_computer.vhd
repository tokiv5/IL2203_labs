use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

architecture test_computer of test is
    component computer
    port (
        clk, reset: IN std_logic;
        Dout_GPIO: OUT std_logic_vector(7 downto 0)
      ) ;
    end component;
    signal clk, reset: std_logic := '0';
    signal Dout_GPIO: std_logic_vector(7 downto 0);
begin
    DUT: computer port map(clk, reset, Dout_GPIO);
    clk <= not clk after 5 ns;
    reset <= '0', '1' after 2 ns, '0' after 6 ns;
end test_computer;