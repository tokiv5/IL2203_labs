library IEEE;
use IEEE.std_logic_1164.all;

package my_components is
    procedure and_gate(signal a, b: IN std_logic; signal q: OUT std_logic);
    procedure or_gate(signal a, b: IN std_logic; signal q: OUT std_logic);
    procedure not_gate(signal a: IN std_logic; signal q: OUT std_logic);
    procedure xor_gate(signal a, b: IN std_logic; signal q: OUT std_logic);
end package;

package body my_components is
    procedure and_gate(signal a, b: IN std_logic; signal q: OUT std_logic) is --procedure is a sub-function, behave like components here
    begin
        q <= a and b;
    end procedure;

    procedure or_gate(signal a, b: IN std_logic; signal q: OUT std_logic) is --procedure is a sub-function, behave like components here
    begin
        q <= a or b;
    end procedure;

    procedure not_gate(signal a: IN std_logic; signal q: OUT std_logic) is --procedure is a sub-function, behave like components here
    begin
        q <= not(a);
    end procedure;

    procedure xor_gate(signal a, b: IN std_logic; signal q: OUT std_logic) is --procedure is a sub-function, behave like components here
    begin
        q <= a xor b;
    end procedure;
end package body;


library IEEE;
use IEEE.std_logic_1164.all;

entity full_adder is
    port(a, b, cin: IN std_logic;
        cout, sum: OUT std_logic);
end full_adder;

architecture data_flow of full_adder is
begin
    cout <= (a and b) or (a and cin) or (b and cin);
    sum <= (a xor b xor cin);
end data_flow;

use work.my_components.all;
architecture structure of full_adder is
    signal a_and_b, a_and_cin, b_and_cin, tmp_or, a_xor_b: std_logic;
begin
    U0: and_gate(a, b, a_and_b);
    U1: and_gate(a, cin, a_and_cin);
    U2: and_gate(b, cin, b_and_cin);
    U3: or_gate(a_and_b, a_and_cin, tmp_or);
    U4: or_gate(tmp_or, b_and_cin, cout);
    U5: xor_gate(a, b, a_xor_b);
    U6: xor_gate(a_xor_b, cin, sum);
end structure;