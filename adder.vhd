library IEEE;
use IEEE.std_logic_1164.all;
entity adder is
    port(a, b: IN std_logic_vector(3 downto 0);
        sum: OUT std_logic_vector(3 downto 0));
end adder;

architecture structure of adder is
    component full_adder
        port(a, b, cin: IN std_logic;
            cout, sum: OUT std_logic);
    end component;
    signal cin, cout: std_logic:='0';
    signal carry: std_logic_vector(a'range);
begin
    G0: for i in a'range generate
        i0: if i = 0 generate
            U: full_adder
                port map(a => a(i),
                b => b(i),
                cin => cin,
                cout => carry(i),
                sum => sum(i));
        end generate;

        ie: if i > 0 generate
            U: full_adder
                port map(a => a(i),
                b => b(i),
                cin => carry(i-1),
                cout => carry(i),
                sum => sum(i));
        end generate;
    end generate;
end structure;
