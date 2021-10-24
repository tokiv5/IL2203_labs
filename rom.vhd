library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

entity rom is
    generic(N:integer:=16);

    port(
        write_addr, read_addr: IN std_logic_vector(A-1 downto 0);
        INS, Din: OUT std_logic_vector(N-1 downto 0) -- instructions
        write_enable: IN std_logic
    );
end entity rom;

architecture structure of rom is
    type memory is array(2**N-1 downto 0) of std_logic_vector(N-1 downto 0);
    signal mem: memory:= (others => (others => '0'));
begin
    INS <= mem(conv_integer(unsigned(read_addr)));
    mem(conv_integer(unsigned(write_addr))) <= Din when write_enable = '1' else mem(conv_integer(unsigned(write_addr)));
end structure;