use work.all;
library IEEE;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

architecture test_ALU of test is
    component ALU
        port(op: IN std_logic_vector(2 downto 0);
            a, b: IN std_logic_vector(3 downto 0);
            y: OUT std_logic_vector(3 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic);
    end component;
    signal op: std_logic_vector(2 downto 0) := "000";
    signal a, b: std_logic_vector(3 downto 0) := "0000";
    signal y: std_logic_vector(3 downto 0);
    signal Z_flag, N_flag, O_flag: std_logic;
begin
    DUT: ALU port map(op, a, b, y, Z_flag, N_flag, O_flag);
    op <= op + 1 after 50 ns;
    a <= a + 1 after 5 ns;
    b <= b - 1 after 5 ns;
end test_ALU;