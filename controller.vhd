library IEEE;
use IEEE.std_logic_1164.all;

entity cpu is
    generic(N:integer:=16);
    port(
        clk, reset: IN std_logic;
        out_clk, RW: OUT std_logic;
        IR_tmp: IN std_logic_vector(15 downto 0);
        input_data: IN std_logic_vector(N-1 downto 0);
        Dout, Address: OUT std_logic_vector(N-1 downto 0)
    );
end entity cpu;

architecture behave of cpu is

    -- Signals for registers
    signal IR: std_logic_vector(15 downto 0);
    signal ALU_out: std_logic_vector(N-1 downto 0);
    signal ZFL, NFL, OFL, flags: std_logic;
    signal SEL: std_logic_vector(2 downto 0);
    signal LE: std_logic_vector(3 downto 0);

    -- Signals for connecting decoder and datapath
    signal offset_tmp: std_logic_vector(15 downto 0);
    signal w_en, RA_en, RB_en, IE, OE, byPassB, byPassW, Z_Reg, N_Reg, O_Reg: std_logic;
    signal op: std_logic_vector(2 downto 0);

    component datapath
        generic(N:integer:=4;
                M:integer:=3);
        port (
            input_data, offset: IN std_logic_vector(N-1 downto 0);
            --PC: OUT std_logic_vector(N-1 downto 0);
            clk, reset, write, readA, readB, IE, OE, byPassA, byPassB, byPassW:IN std_logic;
            op: IN std_logic_vector(2 downto 0);
            WAddr, RA, RB:IN std_logic_vector(M-1 downto 0);
            Z_flag, N_flag, O_flag: OUT std_logic;
            output_data: OUT std_logic_vector(N-1 downto 0);
            out_clk: OUT std_logic
        );
    end component;

    component decoder
        generic(N:integer:=16);
        port(
            ins_OP: IN std_logic_vector(3 downto 0); -- From IR, to tell which instruction is
            flags, clk, reset: IN std_logic; --From flag mux
            RA_enable, RB_enable, WA_enable, byPassB, byPassW, IE, OE, RW: OUT std_logic; -- uInstruction
            op, SEL: OUT std_logic_vector(2 downto 0); -- uInstruction for ALU
            LE: OUT std_logic_vector(3 downto 0) -- Latch signal for IR, flag, Addr and Dout
        );
    end component;

begin
    offset_tmp(11 downto 0) <= IR(11 downto 0);
    offset_tmp(15 downto 12) <= (others => '0');

    D0: datapath
    generic map(N => N)
    port map(
        input_data => input_data,
        offset => offset_tmp,
        clk => clk,
        reset => '0',
        write => w_en,
        readA => RA_en,
        readB => RB_en,
        IE => IE,
        OE => OE,
        byPassA => '0',
        byPassB => byPassB,
        byPassW => byPassW,
        op => op,
        WAddr => IR(11 downto 9),
        RA => IR(8 downto 6),
        RB => IR(5 downto 3),
        Z_flag => ZFL,
        N_flag => NFL,
        O_flag => OFL,
        output_data => ALU_out,
        out_clk => out_clk
    );

    DC0: decoder
    generic map(N => N)
    port map(
        ins_OP => IR(15 downto 12),
        flags => flags,
        clk => clk,
        reset => reset,
        RA_enable => RA_en,
        RB_enable => RB_en,
        WA_enable => w_en,
        byPassB => byPassB,
        byPassW => byPassW,
        IE => IE,
        OE => OE,
        RW => RW,
        op => op,
        SEL => SEL,
        LE => LE
    );
    -- This line should be deleted after memory is implmented
    IR <= IR_tmp;
    flags <= Z_Reg when SEL = "100" else
        N_Reg when SEL = "010" else
        O_Reg when SEL = "001" else
        '0';
    
    process(LE, ALU_out)
    begin
        --if clk'event and clk = '1' then
            -- Latch registers
            -- if LE(3) = '1' then IR <= IR_tmp; end if;
            if LE(2) = '1' then
                Z_Reg <= ZFL;
                N_Reg <= NFL;
                O_Reg <= OFL;
            end if;
            if LE(1) = '1' then Address <= ALU_out; end if;
            if LE(0) = '1' then Dout <= ALU_out; end if;
        --end if;
    end process;
end behave; -- behave