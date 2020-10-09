library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity arith_unit is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        start   : in  std_logic;
        sel     : in  std_logic;
        A, B, C : in  unsigned(7 downto 0);
        D       : out unsigned(31 downto 0);
        done    : out std_logic
    );
end arith_unit;

-- =============================================================================
-- =============================== COMBINATORIAL ===============================
-- =============================================================================

architecture combinatorial of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;
	 
--signals

signal mux1, mux2 : unsigned(7 downto 0);
signal mux0, mux3 : unsigned(15 downto 0);
signal add0 : unsigned(15 downto 0);
signal mult0 : unsigned(15 downto 0);
signal mult1, mult2 : unsigned(31 downto 0);
signal B_extended, A_extended, A_shifted : unsigned(15 downto 0);

begin

done <= start; -- for combinatorial version, also ignoring reset and clk

A_extended <= x"00" & A;
B_extended <= x"00" & B;
A_shifted <= b"0000000" & A & b"0";

multiplication0 : multiplier port map(

	A => mux1,
	B => mux2,
	P => mult0 );
	
multiplication1 : multiplier16 port map(

	A => add0,
	B => mux3,
	P => mult1 );
	
multiplication2 : multiplier16 port map(

	A => mult0,
	B => mult0,
	P => mult2 );
	
	
mux : process(A, A_extended, B, C, A_shifted, add0, mult0, sel) is
begin 
	if (sel = '0') then
        mux0 <= A_extended;
        mux1 <= B;
        mux2 <= C;
        mux3 <= mult0;
    elsif (sel = '1') then
        mux0 <= A_shifted;
        mux1 <= A;
        mux2 <= A;
        mux3 <= add0;
	end if;
end process mux;

add0 <= B_extended + mux0;
D <= mult1 + mult2;	 
	 

end combinatorial;

-- =============================================================================
-- ============================= 1 STAGE PIPELINE ==============================
-- =============================================================================

architecture one_stage_pipeline of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;

--signals

signal mux1, mux2 : unsigned(7 downto 0);
signal mux0, mux3 : unsigned(15 downto 0);
signal add0 : unsigned(15 downto 0);
signal mult0 : unsigned(15 downto 0);
signal mult1, mult2 : unsigned(31 downto 0);	 
signal B_extended, A_extended, A_shifted : unsigned(15 downto 0);

--for pipeline
signal done_pipeline, sel_pipeline:std_logic; 
signal add0_pipeline, mult0_pipeline : unsigned(15 downto 0);
	 
	 
begin


A_extended <= x"00" & A;
B_extended <= x"00" & B;
A_shifted <= b"0000000" & A & b"0";

multiplication0 : multiplier port map(

	A => mux1,
	B => mux2,
	P => mult0);
	
multiplication1 : multiplier16 port map(

	A => add0_pipeline,
	B => mux3,
	P => mult1 );
	
multiplication2 : multiplier16 port map(

	A => mult0_pipeline,
	B => mult0_pipeline,
	P => mult2 );
	
	
mux : process(A, A_extended, B, C, A_shifted, add0, mult0, sel) is
begin 
	if (sel = '0') then
        mux0 <= A_extended;
        mux1 <= B;
        mux2 <= C;
    elsif (sel = '1') then
        mux0 <= A_shifted;
        mux1 <= A;
        mux2 <= A;
	end if;
end process mux;

mux_pipe : process (sel_pipeline, add0_pipeline, mult0_pipeline) is
	begin
		if(sel_pipeline = '0') then 
			mux3 <= mult0_pipeline;
		elsif(sel_pipeline = '1') then 
			mux3 <= add0_pipeline;
		end if;
end process mux_pipe;


process(reset_n, clk) is
	begin
		if(reset_n = '0') then
			done_pipeline <= '0';
			sel_pipeline <= '0';	
			add0_pipeline <= (others => '0');
			mult0_pipeline <= (others => '0');			
		elsif(rising_edge(clk)) then
			done_pipeline <= start;
			sel_pipeline <= sel;	
			add0_pipeline <= add0;
			mult0_pipeline <= mult0;			
		end if; 
end process;


add0 <= B_extended + mux0;
D <= mult1 + mult2;	 
done <= done_pipeline;			

end one_stage_pipeline;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE I =============================
-- =============================================================================

architecture two_stage_pipeline_1 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16
        port(
            A, B : in  unsigned(15 downto 0);
            P    : out unsigned(31 downto 0)
        );
    end component;
--signals

signal mux1, mux2 : unsigned(7 downto 0);
signal mux0, mux3 : unsigned(15 downto 0);
signal add0 : unsigned(15 downto 0);
signal mult0 : unsigned(15 downto 0);
signal mult1, mult2 : unsigned(31 downto 0);	 
signal B_extended, A_extended, A_shifted : unsigned(15 downto 0);

--for pipeline
signal done_pipeline, sel_pipeline :std_logic; 
signal done_pipeline_2 : std_logic;
signal add0_pipeline, mult0_pipeline : unsigned(15 downto 0);
signal mult1_pipeline_2, mult2_pipeline_2 : unsigned(31 downto 0);

	 
begin


A_extended <= x"00" & A;
B_extended <= x"00" & B;
A_shifted <= b"0000000" & A & b"0";

multiplication0 : multiplier port map(

	A => mux1,
	B => mux2,
	P => mult0);
	
multiplication1 : multiplier16 port map(

	A => add0_pipeline,
	B => mux3,
	P => mult1 );
	
multiplication2 : multiplier16 port map(

	A => mult0_pipeline,
	B => mult0_pipeline,
	P => mult2 );
	
	
mux : process(A, A_extended, B, C, A_shifted, add0, mult0, sel) is
begin 
	if (sel = '0') then
        mux0 <= A_extended;
        mux1 <= B;
        mux2 <= C;
    elsif (sel = '1') then
        mux0 <= A_shifted;
        mux1 <= A;
        mux2 <= A;
	end if;
end process mux;

mux_pipe : process (sel_pipeline, add0_pipeline, mult0_pipeline) is
	begin
		if(sel_pipeline = '0') then 
			mux3 <= mult0_pipeline;
		elsif(sel_pipeline = '1') then 
			mux3 <= add0_pipeline;
		end if;
end process mux_pipe;


process(reset_n, clk) is
	begin
		if(reset_n = '0') then
			done_pipeline <= '0';
			sel_pipeline <= '0';	
			add0_pipeline <= (others => '0');
			mult0_pipeline <= (others => '0');		
			
			--sec pipeline
			done_pipeline_2 <= '0';
			mult1_pipeline_2 <= (others => '0');
			mult2_pipeline_2 <= (others => '0');	
			
		elsif(rising_edge(clk)) then
			done_pipeline <= start;
			sel_pipeline <= sel;	
			add0_pipeline <= add0;
			mult0_pipeline <= mult0;	
			
			--sec pipeline
			done_pipeline_2 <= done_pipeline ;
			mult1_pipeline_2 <= mult1;
			mult2_pipeline_2 <= mult2;

		end if; 
end process;


add0 <= B_extended + mux0;
D <= mult1_pipeline_2 + mult2_pipeline_2;	 
done <= done_pipeline_2;			

end two_stage_pipeline_1;

-- =============================================================================
-- ============================ 2 STAGE PIPELINE II ============================
-- =============================================================================

architecture two_stage_pipeline_2 of arith_unit is
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

    component multiplier16_pipeline
        port(
            clk     : in  std_logic;
            reset_n : in  std_logic;
            A, B    : in  unsigned(15 downto 0);
            P       : out unsigned(31 downto 0)
        );
    end component;
	 
--signals

signal mux1, mux2 : unsigned(7 downto 0);
signal mux0, mux3 : unsigned(15 downto 0);
signal add0 : unsigned(15 downto 0);
signal mult0 : unsigned(15 downto 0);
signal mult1, mult2 : unsigned(31 downto 0);	 
signal B_extended, A_extended, A_shifted : unsigned(15 downto 0);

--for pipeline
signal done_pipeline, sel_pipeline :std_logic; 
signal done_pipeline_2 : std_logic;
signal add0_pipeline, mult0_pipeline : unsigned(15 downto 0);
	 
begin

A_extended <= x"00" & A;
B_extended <= x"00" & B;
A_shifted <= b"0000000" & A & b"0";

multiplication0 : multiplier port map(

	A => mux1,
	B => mux2,
	P => mult0);
	
multiplication1 : multiplier16_pipeline port map(

   clk    => clk, 
   reset_n => reset_n, 
	A => add0_pipeline,
	B => mux3,
	P => mult1 );
	
multiplication2 : multiplier16_pipeline port map(

   clk    => clk, 
   reset_n => reset_n, 
	A => mult0_pipeline,
	B => mult0_pipeline,
	P => mult2 );
	
	
mux : process(A, A_extended, B, C, A_shifted, add0, mult0, sel) is
begin 
	if (sel = '0') then
        mux0 <= A_extended;
        mux1 <= B;
        mux2 <= C;
    elsif (sel = '1') then
        mux0 <= A_shifted;
        mux1 <= A;
        mux2 <= A;
	end if;
end process mux;

mux_pipe : process (sel_pipeline, add0_pipeline, mult0_pipeline) is
	begin
		if(sel_pipeline = '0') then 
			mux3 <= mult0_pipeline;
		elsif(sel_pipeline = '1') then 
			mux3 <= add0_pipeline;
		end if;
end process mux_pipe;


process(reset_n, clk) is
	begin
		if(reset_n = '0') then
			done_pipeline <= '0';
			sel_pipeline <= '0';	
			add0_pipeline <= (others => '0');
			mult0_pipeline <= (others => '0');		
			done_pipeline_2 <= '0';
		
		elsif(rising_edge(clk)) then
			done_pipeline <= start;
			sel_pipeline <= sel;	
			add0_pipeline <= add0;
			mult0_pipeline <= mult0;	
			done_pipeline_2 <= done_pipeline ;

		end if; 
end process;


add0 <= B_extended + mux0;
D <= mult1 + mult2;	 
done <= done_pipeline_2;	

end two_stage_pipeline_2;
