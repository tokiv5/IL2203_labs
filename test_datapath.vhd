use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture test_datapath of test is
    constant N:integer:=4;
    constant M:integer:=3;
    component datapath
        port (
            input_data: IN std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE:IN std_logic;
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic;
            output_data: OUT std_logic_vector(N-1 downto 0)
        );
    end component;

    signal clk, reset: std_logic:='0';
    signal Z_flag, N_flag, O_flag: std_logic;
    signal write, readA, readB, OE, IE: std_logic := '1';
    signal WAddr, RA, RB: std_logic_vector(M-1 downto 0);
    signal input_data: std_logic_vector(N-1 downto 0);
    signal output_data: std_logic_vector(N-1 downto 0);
    type int_array is array(integer range<>) of integer;
    constant values:int_array:=(0,1,2,3,4,5,6,7);

    begin
        DUT: datapath port map(input_data, clk, reset, write, readA, readB, IE, OE, WAddr, RA, RB, Z_flag, N_flag, O_flag, output_data);
        
        clk <= not clk after 5 ns;
        IE <= '0' after 100 ns;
        -- OE <= not OE after 15 ns;
        -- write <= '0' , '1' after 30 ns, '0' after 200 ns;

        reset <= '1' ,'0' after 8 ns;
        WAddr <= conv_std_logic_vector(0,M) after 10 ns, conv_std_logic_vector(1,M) after 30 ns;
        input_data <= conv_std_logic_vector(1,N) after 20 ns;
        
        RA <= conv_std_logic_vector(0, M);
        RB <= conv_std_logic_vector(1, M);

        -- write_initiate: process
        -- begin
        --     wait for 2 ns;
            -- for i in values'range loop
            --     WAddr <= conv_std_logic_vector(i,M);
            --     input_data <= conv_std_logic_vector(i,N);
            --     wait for 10 ns;
            -- end loop;    
        -- end process write_initiate;

        -- read: process
        -- begin
        --     for j in values'range loop
        --         RA <= conv_std_logic_vector(j, M);
        --         RB <= conv_std_logic_vector(7-j, M);
        --         wait for 10 ns;
        --     end loop;  
        -- end process read;
    end architecture test_datapath;
