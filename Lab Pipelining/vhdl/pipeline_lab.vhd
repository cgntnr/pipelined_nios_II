library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_lab is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        Button0 : in  std_logic;
        Button1 : in  std_logic;
        LEDS    : out std_logic_vector(95 downto 0)
    );
end pipeline_lab;

architecture synth of pipeline_lab is
    constant SIZE     : natural                                    := 128;
    constant OPERANDS : std_logic_vector((24 * SIZE) - 1 downto 0) := X"FFFFFF" & X"FFFFFF" & X"010101" & X"010101" & X"CA536F" & X"4F672B" & X"D306E8" & X"28AF31" & X"450D4B" & X"A9ADA6" & X"7F55A9" & X"709667" & X"1B64DB" & X"B4CC67" & X"1EF1E3" & X"B3FA79" & X"8FAA6B" & X"71EE74" & X"7AD505" & X"0E007D" & X"A2C7F6" & X"021F5D" & X"7F56B6" & X"02C937" & X"3ABE68" & X"5D8FF5" & X"BBADF4" & X"10D847" & X"185CA0" & X"E8230B" & X"DCED2A" & X"6CE67E" & X"0A89D2" & X"68C386" & X"BAD6E7" & X"50CEEE" & X"D9CFAC" & X"D9F97F" & X"5020A9" & X"780228" & X"867AD8" & X"AA5AC4" & X"479D28" & X"380122" & X"35EC47" & X"D1304D" & X"7ADDC1" & X"B55E5C" & X"649CD0" & X"47F725" & X"FBA172" & X"C1CCAF" & X"E82EA3" & X"651E40" & X"1EC7D7" & X"D7B44D" & X"224804" & X"9A8BC5" & X"F718D1" & X"B5D36E" & X"F187E0" & X"11794A" & X"F38525" & X"1B613D" & X"F718B5" & X"A50A7A" & X"D249BB" & X"28445E" & X"8B7F3B" & X"C932B8" & X"BF6FEE" & X"DCC7C0" & X"F71071" & X"C06528" & X"D35066" & X"3A6109" & X"787A70" & X"C58BA8" & X"A96806" & X"7FFB40" & X"761692" & X"86C34D" & X"682168" & X"124B25" & X"89496A" & X"8E6EB4" & X"D10179" & X"80ABB9" & X"B29D0F" & X"05F9DD" & X"D7C18D" & X"220879" & X"62FC2F" & X"5107E9" & X"27D499" & X"E048C4" & X"B79982" & X"27424E" & X"3FCCF2" & X"9ECAFC" & X"81F703" & X"669AF8" & X"7E2F29" & X"BB69D1" & X"85AB78" & X"6833E6" & X"C03463" & X"417E3B" & X"8338D8" & X"26A2A8" & X"E7E7DE" & X"287BAE" & X"7997F5" & X"C0FB5A" & X"FE3EEE" & X"4589F6" & X"ACEFFA" & X"F1218A" & X"46851B" & X"54A54A" & X"F0ED43" & X"D2D893" & X"D1C9C6" & X"A4D90A" & X"AE4DF3" & X"8839E7" & X"229BE6" & X"E7EEB2" ;
    constant OPERATIONS : std_logic_vector(SIZE - 1 downto 0)        := X"50" & X"E6" & X"53" & X"14" & X"E0" & X"99" & X"01" & X"3E" & X"8E" & X"43" & X"D1" & X"D6" & X"7C" & X"29" & X"C4" & X"BD" ;
    constant RESULTS    : std_logic_vector((32 * SIZE) - 1 downto 0) := X"FE0001FF" & X"FC0EEA0A" & X"00000003" & X"0000000A" & X"053738B2" & X"01379DE7" & X"00222CF0" & X"047E1EAA" & X"015A3882" & X"30A30C22" & X"0F833EEA" & X"0E7813C0" & X"1CC0B504" & X"3E96EB90" & X"000DBDF9" & X"3750C346" & X"140FA4E2" & X"09BB30C1" & X"0016C038" & X"00009920" & X"8FE541EE" & X"0080472C" & X"0F834191" & X"0000A439" & X"1790AF80" & X"49A7953D" & X"6B1CCBB0" & X"0001F040" & X"0D044E00" & X"ACB0DCA9" & X"062D48F6" & X"32A46938" & X"00008759" & X"06FB8A69" & X"475C3A74" & X"901C3188" & X"4C7512B0" & X"3C7BDCEF" & X"01C78200" & X"00003F20" & X"133A0734" & X"12D20DE0" & X"026FA160" & X"009641E1" & X"007A2F15" & X"00DEEF70" & X"6D4F38A4" & X"3FFC2C71" & X"3F405000" & X"0526C783" & X"14879A3C" & X"4CCF6F74" & X"0379A7C0" & X"003C1680" & X"6DB192C6" & X"7F61E7A5" & X"0001BB40" & X"2D2BE704" & X"DDDECDC5" & X"3FFE02BA" & X"C917D8D2" & X"0001A41A" & X"CFD9F44A" & X"02216B55" & X"DDDECDC5" & X"0019F80C" & X"0B566BAA" & X"0279F8E0" & X"16429FEA" & X"614D22B1" & X"4F57126A" & X"57F7D7C0" & X"00392270" & X"510396D9" & X"041C3FA0" & X"000DB1A4" & X"0B5358C0" & X"20F895C0" & X"30A20B45" & X"0F856232" & X"0B8F5B14" & X"133AFA71" & X"00BAE6E8" & X"0001CA31" & X"03AA70B8" & X"17AA30E0" & X"00009C73" & X"1002C839" & X"3BD9F211" & X"0001087A" & X"2CCD45E1" & X"00147AA0" & X"089BC308" & X"029146D2" & X"00249565" & X"0C1E8100" & X"17FA8964" & X"00239DE1" & X"00F20865" & X"25296434" & X"10856632" & X"06759DB4" & X"003DBF6C" & X"1D1626B5" & X"197835C0" & X"084F3E6A" & X"5102E690" & X"0360EEDA" & X"118F4155" & X"2C796780" & X"9E29BE40" & X"0027B0F9" & X"0CC936B2" & X"51062719" & X"0D419780" & X"441D3F38" & X"D6418B66" & X"C91615CA" & X"00CFE3BE" & X"09113BE6" & X"C5C8D829" & X"3CE62590" & X"71C011FA" & X"2B22A941" & X"36A583A1" & X"1465B6D1" & X"4C278CBE" & X"A9BF4BF1" ;

    -- state machines
    type state_type is (IDLE, COUNT, FINISHED);
    signal state_compute : state_type;
    signal state_verify  : state_type;

    -- clk for the arithmetic unit
    signal pipeline_clk : std_logic;
    signal inputs       : unsigned(23 downto 0);
    signal start        : std_logic;
    signal sel          : std_logic;
    signal done         : std_logic;

    -- buffers in and out for the inputs and outputs of the arithmetic unit
    type array_in is array (15 downto 0) of std_logic_vector(23 downto 0);
    type array_out is array (15 downto 0) of std_logic_vector(15 downto 0);

    signal start_in   : std_logic_vector(SIZE - 1 downto 0);
    signal FIFO_in    : std_logic_vector((24 * SIZE) - 1 downto 0);
    signal FIFO_in_op : std_logic_vector(SIZE - 1 downto 0);
    signal FIFO_out   : std_logic_vector((32 * SIZE) - 1 downto 0);
    signal FIFO_comp  : std_logic_vector((32 * SIZE) - 1 downto 0);

    -- accumulator for the comparison
    signal accum_comp : std_logic;

    signal arith_result : unsigned(31 downto 0);

    component PLL IS
        port(
            inclk0 : in  std_logic := '0';
            c0     : out std_logic
        );
    end component;

begin
    -------------------------
    -- The arithmetic unit --
    -------------------------
    ArithmeticUnit : entity work.arith_unit(combinatorial) port map(
    --ArithmeticUnit : entity work.arith_unit(one_stage_pipeline) port map(
     --ArithmeticUnit : entity work.arith_unit(two_stage_pipeline_1) port map(
    --ArithmeticUnit : entity work.arith_unit(two_stage_pipeline_2) port map(
            clk     => pipeline_clk,
            reset_n => reset_n,
            start   => start,
            sel     => sel,
            a       => inputs(23 downto 16),
            b       => inputs(15 downto 8),
            c       => inputs(7 downto 0),
            d       => arith_result,
            done    => done
        );

    -- Extra clocks
    PLLUnit : PLL port map(
            inclk0 => clk,
            c0     => pipeline_clk
        );

    -- FSM compute
    FSM_compute : process(pipeline_clk, reset_n)
        variable sync_button0 : std_logic;
        variable sync_done    : std_logic;
        variable sync_result  : std_logic_vector(31 downto 0);
    begin
        if (reset_n = '0') then
            start         <= '0';
            sel           <= '0';
            state_compute <= IDLE;
            start_in      <= (others => '1');
            inputs        <= (others => '0');
            FIFO_out      <= (others => '0');
            sync_done     := '0';
            sync_button0  := '1';
            sync_result   := (others => '0');
            FIFO_in       <= OPERANDS;
            FIFO_in_op    <= OPERATIONS;
        elsif (rising_edge(pipeline_clk)) then
            inputs <= unsigned(FIFO_in(23 downto 0));
            sel    <= FIFO_in_op(0);
            -- FIFO_out
            if (sync_done = '1') then
                FIFO_out <= sync_result & FIFO_out(32 * SIZE - 1 downto 32);
            end if;

            -- FSM
            case state_compute is
                when IDLE =>
                    if (sync_button0 = '0') then
                        state_compute <= COUNT;
                    end if;

                when COUNT =>
                    start      <= start_in(0);
                    start_in   <= '0' & start_in(SIZE - 1 downto 1);
                    FIFO_in    <= (23 downto 0 => '0') & FIFO_in(24 * SIZE - 1 downto 24);
                    FIFO_in_op <= '0' & FIFO_in_op(SIZE - 1 downto 1);
                    if (start_in(0) = '0' and sync_done = '0') then
                        state_compute <= FINISHED;
                    end if;

                when FINISHED =>
                when others   =>
            end case;

            -- sync signals
            sync_done    := done;
            sync_button0 := Button0;
            sync_result  := std_logic_vector(arith_result);
        end if;
    end process;

    -- FSM verify
    FSM_verify : process(clk, reset_n)
        variable sync_state0, sync_state1 : state_type;
        variable sync_button1             : std_logic;
        variable done_out                 : std_logic_vector(SIZE - 1 downto 0);
    begin
        if (reset_n = '0') then
            state_verify <= IDLE;
            sync_button1 := '1';
            done_out     := (others => '1');
            FIFO_comp    <= RESULTS;
        elsif (rising_edge(clk)) then
            case state_verify is
                when IDLE =>
                    if (sync_state1 = FINISHED and sync_button1 = '0') then
                        state_verify <= COUNT;
                    end if;

                when COUNT =>
                    FIFO_comp <= (31 downto 0 => '0') & FIFO_comp(32 * SIZE - 1 downto 32);
                    done_out  := '0' & done_out(SIZE - 1 downto 1);
                    if (done_out(0) = '0') then
                        state_verify <= FINISHED;
                    end if;

                when FINISHED =>
                when others   =>
            end case;

            -- sync signals
            sync_state1  := sync_state0;
            sync_state0  := state_compute;
            sync_button1 := Button1;
        end if;
    end process;

    -- comparison
    process(clk, reset_n)
        variable sync_fifo : std_logic_vector(32 * SIZE - 1 downto 0);
    begin
        if (reset_n = '0') then
            accum_comp <= '1';
            sync_fifo  := (others => '0');
        elsif (rising_edge(clk)) then
            if (state_verify = IDLE) then
                sync_fifo := FIFO_out;
            else
                if (sync_fifo(15 downto 0) /= FIFO_comp(15 downto 0)) then
                    accum_comp <= '0';
                end if;
                sync_fifo := (31 downto 0 => '0') & sync_fifo(32 * SIZE - 1 downto 32);
            end if;
        end if;
    end process;

    process(state_verify, state_compute, accum_comp)
    begin
        if (state_verify = FINISHED) then
            if (accum_comp = '0') then
                LEDs <= X"000000422418182442000000"; -- Cross
            else
                LEDs <= X"000204081020402010000000"; -- Check
            end if;
        elsif (state_compute = FINISHED) then
            LEDs <= X"0000006C107C003844380000"; -- OK
        elsif (state_compute = IDLE) then
            LEDs <= X"0C700C0038447C0068147C00"; -- RDY
        else
            LEDs <= (others => '0');
        end if;
    end process;
end synth;
