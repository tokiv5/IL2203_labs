use work.all;
architecture test_full_adder of test is
    component full_adder
        port(a, b, cin: IN std_logic;
            cout, sum: OUT std_logic);
    end component;
    for DUT0: full_adder use entity work.full_adder(data_flow);
    for DUT1: full_adder use entity work.full_adder(structure);
    signal a, b, cin: std_logic:='0';
    signal cout_0, cout_1, sum_0, sum_1: std_logic;
    signal res_0, res_1: std_logic_vector(1 downto 0);
begin
    DUT0: full_adder port map(a, b, cin, cout_0, sum_0);
    DUT1: full_adder port map(a, b, cin, cout_1, sum_1);
    a <= not(a) after 5 ns;
    b <= not(b) after 10 ns;
    cin <= not(cin) after 20 ns;

    res_0 <= cout_0 & sum_0;
    res_1 <= cout_1 & sum_1;

    --assert (a+b+cin = res_0) severity note "result doesn't match";
    --assert (a+b+cin = res_1) severity note "result doesn't match";
end test_full_adder;