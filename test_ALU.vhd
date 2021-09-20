use work.all;
library IEEE;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

architecture test_ALU of test is
    constant N:integer:=4;
    component ALU
        generic(N:integer:=4);
        port(
            clk,reset,en: IN std_logic;
            op: IN std_logic_vector(2 downto 0);
            a, b: IN std_logic_vector(N-1 downto 0);
            y: OUT std_logic_vector(N-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic
        );
    end component;

    signal clk: std_logic:='0';
    signal en,reset: std_logic;
    signal op: std_logic_vector(2 downto 0);
    signal a, b: std_logic_vector(N-1 downto 0);
    signal y: std_logic_vector(N-1 downto 0);
    signal Z_flag, N_flag, O_flag: std_logic;
    
    type int_array is array(integer range<>) of integer;
    constant values_a:int_array:=(-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7);
    -- constant values_a:int_array:=(0,1,2,3,4,5,6,7);
    constant values_b:int_array:=(-8,-7,-6,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7);
    -- constant values_b:int_array:=(0,1,2,3,4,5,6,7);
    constant values_op:int_array:=(0,1,2,3,4,5,6,7);
    
begin
    DUT: ALU 
        generic map(N => N)
        port map(clk,reset,en,op, a, b, y, Z_flag, N_flag, O_flag);

    -- generate signals:
    clk <= not clk after 5 ns;
    reset <= '0' ,'1' after 101 ns,'0' after 201 ns;
    en <= '1' , '0' after 51 ns, '1' after 81 ns;
    process
    begin
        -- wait for 1 ns;
        for k in values_op'range loop
            op <= conv_std_logic_vector(values_op(k),3);
            for j in values_b'range loop
                b <= conv_std_logic_vector(values_b(j),N);
                for i in values_a'range loop
                    a <= conv_std_logic_vector(values_a(i),N);
                    wait for 10 ns;
                end loop;
            end loop;
        end loop;
    end process;

    -- Testing:
    moniter: process
    begin
        wait until reset = '1';
        wait for 1 ps;
        assert(y & Z_flag & N_flag & O_flag = "0000")
            report "RESET failed"
            severity warning;

        wait until clk = '1';
        if (en='0' and reset='0') then
            wait for 1 ps;
            assert(false)
                report "EN = 0"
                severity note;
        elsif (en='1' and reset='0') then
            wait for 1 ps;
            -- Functions testing begin:
            case op is
                when "000" => --add
                    assert(a+b=y)
                        report "ADD failed"
                        severity warning;
                    if (conv_integer(a)+conv_integer(b)/=conv_integer(y)) then
                        assert(O_flag='1')
                            report "O_flag failed"
                            severity warning;
                    else
                        assert(O_flag='0')
                            report "O_flag failed"
                            severity warning;
                    end if;
                when "001" => --sub
                    assert(a-b=y)
                        report "SUB failed"
                        severity warning;
                    if (conv_integer(a)-conv_integer(b)/=conv_integer(y)) then
                        assert(O_flag='1')
                            report "O_flag failed"
                            severity warning;   
                    else
                        assert(O_flag='0')
                            report "O_flag failed"
                            severity warning;
                    end if;
                when "010" => --and
                    assert((a and b) = y)
                        report "AND failed"
                        severity warning;
                when "011" => --or
                    assert((a or b) = y)
                        report "OR failed"
                        severity warning;
                when "100" => --xor
                    assert((a xor b) = y)
                        report "XOR failed"
                        severity warning;
                when "101" => --not
                    assert((not(a)) = y)
                        report "NOT failed"
                        severity warning;
                when "110" => --mov
                    assert(a=y)
                        report "MOV failed"
                        severity warning;
                when "111" => -- incr 1 for lab3
                    assert(a+conv_std_logic_vector(1,N)=y)
                        report "INCR failed"
                        severity warning;
                    if (conv_integer(a)+1 /= conv_integer(y)) then
                        assert(O_flag='1')
                            report "O_flag failed"
                            severity warning;   
                    else
                        assert(O_flag='0')
                            report "O_flag failed"
                            severity warning;
                    end if;
                -- when "111" => -- zero function in lab1 and lab2
                --     assert(y=0)
                --         report "ZERO failed"
                --         severity warning;
                when others =>
                    assert(FALSE)
                        report "OP invalid"
                        severity warning;
            end case;

            if ((y=0 and Z_flag='0') or (y/=0 and Z_flag='1')) then 
                assert(FALSE)
                    report "Z_flag failed"
                    severity warning;
            end if;
            if ((y<0 and N_flag='0') or (y>-1 and N_flag='1')) then 
                assert(FALSE)
                    report "N_flag failed"
                    severity warning;
            end if;
        end if;
    end process moniter;

end test_ALU ; -- test_ALU