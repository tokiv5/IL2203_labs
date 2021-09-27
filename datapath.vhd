use work.all;
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

entity datapath is
    generic(N:integer:=4;
            M:integer:=3);
    port (
        input_data, offset: IN std_logic_vector(N-1 downto 0);
        clk, reset, write, readA, readB, IE, OE, byPassA, byPassB:IN std_logic;
        WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
        output_data: OUT std_logic_vector(N-1 downto 0);
        Z_flag, N_flag, O_flag, out_clk: OUT std_logic  -- add reset_t here if want to show if the rst button works
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

    signal clk_1, readA_inside, Z_flag_reg, N_flag_reg, O_flag_reg: std_logic;
    signal WD, tmp_out, QA, QB, A, B: std_logic_vector(N-1 downto 0);
    signal RA_inside: std_logic_vector(M-1 downto 0);

begin
    -- Uncomment this block to run on board:
    -- C0: divider
    -- port map(clk_50M => clk,
    -- clk_1 => clk_1);
    -- out_clk<=clk_1; -- To show the clock by a LED light:

    M0: mux
    generic map(N => N)
    port map(sel => IE,
    in1 => tmp_out,
    in2 => input_data,
    y => WD);

    M1: mux
    generic map(N => N)
    port map(sel => byPassA,
    in1 => QA,
    in2 => offset,
    y => A);

    M2: mux
    generic map(N => N)
    port map(sel => byPassB,
    in1 => QB,
    in2 => offset,
    y => B);

    RF0: RF
    generic map(N => N, M => M)
    port map(clk => clk,   -- use clk_1 to run on board
    reset => reset,
    write => write,
    readA => readA_inside,
    readB => readB,
    WD => WD,
    WAddr => WAddr,
    RA => RA_inside,
    RB => RB,
    QA => QA,
    QB => QB);

    ALU0: ALU
    generic map(N => N)
    port map(clk => clk, -- use clk_1 to run on board
    reset => '0',
    en => '1',
    op => "111",
    a => A,
    b => B,
    y => tmp_out,
    Z_flag => Z_flag_reg,
    N_flag => N_flag_reg,
    O_flag => O_flag_reg);

    -- Input:
    RA_inside <= RA when byPassB = '0' else (others => '1');
    readA_inside <= readA when byPassB = '0' else '1';
    
    -- Output reg:
    process(clk, tmp_out, OE, Z_flag_reg, N_flag_reg, O_flag_reg)
    begin
        if (clk'event and clk='1') then
            Z_flag  <= Z_flag_reg;
            N_flag  <= N_flag_reg;
            O_flag  <= O_flag_reg;
            if OE ='1' then
                output_data <= tmp_out;
            else
                output_data <= (others => 'Z');
            end if;
        end if;
    end process;

    -- Explicit signals for testing buttons:
    -- reset_t <= reset; 
    
end architecture data_flow; 
