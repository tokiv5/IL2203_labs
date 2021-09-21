library IEEE;
use IEEE.std_logic_1164.all;
-- use IEEE.std_logic_signed.all;

entity mux is
    generic(N:integer:=4);
    port (
        sel: IN std_logic;
        in1, in2: IN std_logic_vector(N-1 downto 0);
        y: OUT std_logic_vector(N-1 downto 0)
    );
end entity mux;

architecture data_flow of mux is
begin
    y <= in1 when sel = '0' else in2;
end architecture data_flow;