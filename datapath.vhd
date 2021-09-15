use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity datapath is
    generic(N:integer:=4;
            M:integer:=3);
    port (
        input_data: IN std_logic_vector(N-1 downto 0);
        clk, reset, write, readA, readB, IE, OE:IN std_logic;
        WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
        Z_flag, N_flag, O_flag: OUT std_logic;
        output_data: OUT std_logic_vector(N-1 downto 0);
        out_clk, reset_t: OUT std_logic
    );
end entity datapath;

architecture data_flow of datapath is
    component RF
    generic(N:integer:=4;
            M:integer:=3);
    port (
        clk,reset,write,readA,readB:IN std_logic; -- Is "write" a reserved word in VHDL?
        WD:IN std_logic_vector(N-1 downto 0);  -- WD=Write_Data
        WAddr,RA,RB:IN std_logic_vector(M-1 downto 0); -- WAddr=Write_Addr, RA=Read_A_Addr, RB=Read_B_Addr
        QA,QB:OUT std_logic_vector(N-1 downto 0)
    );
    end component;

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

    component divider
    port(
        clk_50M: IN std_logic;
        clk_1: OUT std_logic
    );
    end component;

    component mux
    generic(N:integer:=4);
    port (
        sel: IN std_logic;
        in1, in2: IN std_logic_vector(N-1 downto 0);
        y: OUT std_logic_vector(N-1 downto 0)
    );
    end component;
    signal clk_1: std_logic;
    signal WD, tmp_out, QA, QB: std_logic_vector(N-1 downto 0);
begin
    C0: divider
    port map(clk_50M => clk,
    clk_1 => clk_1);
    out_clk<=clk_1;

    M0: mux
    generic map(N => N)
    port map(sel => IE,
    in1 => tmp_out,
    in2 => input_data,
    y => WD);

    RF0: RF
    generic map(N => N, M => M)
    port map(clk => clk_1,
    reset => reset,
    write => write,
    readA => readA,
    readB => readB,
    WD => WD,
    WAddr => WAddr,
    RA => RA,
    RB => RB,
    QA => QA,
    QB => QB);

    ALU0: ALU
    generic map(N => N)
    port map(clk => clk_1, -- clk
    reset => '0',
    en => '1',
    op => "000",
    a => QA,
    b => QB,
    y => tmp_out,
    Z_flag => Z_flag,
    N_flag => N_flag,
    O_flag => O_flag);

    output_data <= tmp_out when OE = '1' else (others => 'Z');
    reset_t <= reset;
    
end architecture data_flow; 
