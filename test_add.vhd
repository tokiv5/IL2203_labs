use work.all;
library IEEE;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;
architecture test_adder of test is
    component adder
        port(a, b: IN std_logic_vector(3 downto 0);
            sum: OUT std_logic_vector(3 downto 0));
    end component;
    signal a, b,sum: std_logic_vector(3 downto 0);
    type int_array is array(integer range <>) of integer; -- integer index array
    constant values: int_array:=(0, -1);
begin
    DUT: adder port map(a, b, sum);
    
    b <= (others => '0'); -- every bits in b become '0'
    
    process
    begin
        for i in values'range loop
            a <= conv_std_logic_vector(values(i), 4); -- Convert integer into bit vector
            wait for 1 fs;
            assert (a + b = sum) report "results doesn't match" severity warning;
            wait for 10 ns;
        end loop;
    end process;
end test_adder;