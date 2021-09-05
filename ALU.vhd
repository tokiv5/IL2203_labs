library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;
use IEEE.std_logic_arith.all;

entity ALU is
    port(op: IN std_logic_vector(2 downto 0);
        a, b: IN std_logic_vector(3 downto 0);
        y: OUT std_logic_vector(3 downto 0);
        Z_flag, N_flag, O_flag: OUT std_logic);
end ALU;

architecture structure of ALU is
    signal res: std_logic_vector(y'range);
begin
    process(op, a, b, res)
    begin
    case op is
        when "000" => --add
            res <= a + b;
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
            if (a(3) = b(3) and res(3) /= a(3)) then O_flag <= '1';
            else O_flag <= '0';
            end if;
        when "001" => --sub
            res <= a - b;
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
            if (a(3) /= b(3) and res(3) /= a(3)) then O_flag <= '1';
            else O_flag <= '0';
            end if;
        when "010" => --and
            res <= a and b;
            O_flag <= '0';
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
        when "011" => -- or
            res <= a or b;
            O_flag <= '0';
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
        when "100" => --xor
            res <= a xor b;
            O_flag <= '0';
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
        when "101" => --not
            res <= not(a);
            O_flag <= '0';
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
        when "110" => --mov
            res <= a;
            O_flag <= '0';
            if (res = "0000") then Z_flag <= '1';
            else Z_flag <= '0';
            end if;
            if (res(3) = '1') then N_flag <= '1';
            else N_flag <= '0';
            end if;
        when "111" => --zero
            res <= "0000";
            Z_flag <= '1';
            N_flag <= '0';
            O_flag <= '0';
        when others =>
            res <= "0000";
            Z_flag <= '1';
            N_flag <= '0';
            O_flag <= '0';
    end case;
    end process;
    y <= res;
end structure;