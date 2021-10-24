use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture test_RF of test is
    constant N:integer:=4;
    constant M:integer:=3;
    component RF
        port (
            clk,reset,write,readA,readB:IN std_logic;
            WD:IN std_logic_vector(N-1 downto 0);
            WAddr,RA,RB:IN std_logic_vector(M-1 downto 0);
            QA,QB:OUT std_logic_vector(N-1 downto 0)
        );
    end component;
    
    signal clk: std_logic:='0';
    signal reset,write,readA,readB: std_logic;
    signal WAddr,RA, RB: std_logic_vector(M-1 downto 0);
    signal WD: std_logic_vector(N-1 downto 0);
    signal QA,QB: std_logic_vector(N-1 downto 0);
    
    type int_array is array(integer range<>) of integer;
    constant values:int_array:=(0,1,2,3,4,5,6,7);
    
    
begin
    DUT: RF port map(clk,reset,write,readA,readB,WD,WAddr,RA,RB,QA,QB);

    -- generate signals:
    clk <= not clk after 5 ns;
    reset <= '1' ,'0' after 21 ns;
    write <= '0' , '1' after 30 ns, '0' after 200 ns;

    write_initiate: process
    begin
        wait for 30 ns;
        for i in values'range loop
            WAddr <= conv_std_logic_vector(i,M);
            WD <= conv_std_logic_vector(42,N);
            wait for 10 ns;
            WD <= conv_std_logic_vector(85,N);
            wait for 10 ns;
        end loop;    
    end process write_initiate;
    
    readA <= '0' , '1' after 100 ns;
    readB <= '0' , '1' after 120 ns;
    read: process
    begin
        for j in values'range loop
            RA <= conv_std_logic_vector(j,M);
            RB <= conv_std_logic_vector(7-j,M);
            wait for 1 ns;
            if (readA='0') then 
                assert (QA=conv_std_logic_vector(0,N))
                report "readA = '0' but QA is not zero"
                severity warning;
                elsif (readA='1') then
                    assert (QA=conv_std_logic_vector(j,N))
                        report "Read A not match"
                        severity warning;
            end if;
            if (readB='0') then 
                assert (QB=conv_std_logic_vector(0,N))
                report "readB = '0' but QB is not zero"
                severity warning;
                elsif (readA='1') then
                    assert (QB=conv_std_logic_vector(7-j,N))
                        report "Read B not match"
                        severity warning;
            end if;
            wait for 9 ns;
        end loop;  
    end process read;
    
end architecture test_RF;