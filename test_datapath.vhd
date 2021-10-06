use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;

architecture test_datapath of test is
    constant N:integer:=4;
    constant M:integer:=3;
    component datapath
        generic(N:integer; M:integer);
        port (
            input_data, offset: IN std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW:IN std_logic;
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            op: IN std_logic_vector(2 downto 0);
            output_data: OUT std_logic_vector(N-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic 
        );
    end component;

    signal reset,clk: std_logic:='0';
    signal write, readA, readB, OE, IE, byPassA, byPassB, byPassW: std_logic;
    signal Z_flag, N_flag, O_flag: std_logic;
    signal WAddr, RA, RB: std_logic_vector(M-1 downto 0);
    signal op: std_logic_vector(2 downto 0);
    signal input_data, output_data, offset: std_logic_vector(N-1 downto 0);

    type int_array is array(integer range<>) of integer;
    constant values:int_array:=(0,1,2,3,4,5,6,7);

    begin
        DUT: datapath 
            generic map(N,M)
            port map(input_data, offset, 
<<<<<<< HEAD
                clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW,
=======
                clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, 
>>>>>>> 258343501442a028cf2a43f74c69ffa02e01c289
                WAddr, RA, RB, 
                op,
                output_data,
                Z_flag, N_flag, O_flag);

        input_data <= conv_std_logic_vector(0,N);
        offset <= (others=>'0');
        
        clk <= not clk after 5 ns;
        reset <= '1' after 3 ns, '0' after 8 ns;

        IE <= '1', '0' after 50 ns;
        byPassA <= '0';
        byPassB <= '1';
<<<<<<< HEAD
        byPassW <= '0';
=======
>>>>>>> 258343501442a028cf2a43f74c69ffa02e01c289
        write <= '1';
        readA <= '1';
        readB <= '1';
        OE <= '1';

        WAddr <= conv_std_logic_vector(0,M); -- , conv_std_logic_vector(1,M) after 30 ns;
        RA <= conv_std_logic_vector(0, M);
        RB <= conv_std_logic_vector(1, M);

        op <= "111";

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
