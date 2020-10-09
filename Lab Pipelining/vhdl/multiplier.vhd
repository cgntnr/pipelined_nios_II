-- =============================================================================
-- ================================= multiplier ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
    port(
        A, B : in  unsigned(7 downto 0);
        P    : out unsigned(15 downto 0)
    );
end multiplier;

architecture combinatorial of multiplier is


signal s_int0 :unsigned(7 downto 0);
signal s_int1 :unsigned(7 downto 0);
signal s_int2 :unsigned(7 downto 0);
signal s_int3 :unsigned(7 downto 0);
signal s_int4 :unsigned(7 downto 0);
signal s_int5 :unsigned(7 downto 0);
signal s_int6 :unsigned(7 downto 0);
signal s_int7 :unsigned(7 downto 0);


--results for first sum
signal s_res0 :unsigned(9 downto 0);
signal s_res1 :unsigned(9 downto 0);
signal s_res2 :unsigned(9 downto 0);
signal s_res3 :unsigned(9 downto 0);

--results for second sum
signal s_last0 : unsigned(12 downto 0);
signal s_last1 : unsigned(12 downto 0);

--final result
signal res  :unsigned(17 downto 0);


begin

	proc0 : process(A,B) is
	begin
	
	
	if(A(0) = '0') then s_int0 <= (others => '0'); else s_int0 <= B;end if;
	if(A(1) = '0') then s_int1 <= (others => '0'); else s_int1 <= B;end if;
	if(A(2) = '0') then s_int2 <= (others => '0'); else s_int2 <= B;end if;
	if(A(3) = '0') then s_int3 <= (others => '0'); else s_int3 <= B;end if;
	if(A(4) = '0') then s_int4 <= (others => '0'); else s_int4 <= B;end if;
	if(A(5) = '0') then s_int5 <= (others => '0'); else s_int5 <= B;end if;
	if(A(6) = '0') then s_int6 <= (others => '0'); else s_int6 <= B;end if;
	if(A(7) = '0') then s_int7 <= (others => '0'); else s_int7 <= B;end if;

	end process proc0;
	
	
	proc1 : process(s_int0,s_int1,s_int2,s_int3,s_int4,s_int5,s_int6,s_int7) is
	begin
	
	s_res0 <= (b"00" & s_int0) + (b"0" & s_int1 & b"0");
	s_res1 <= (b"00" & s_int2) + (b"0" & s_int3 & b"0");
	s_res2 <= (b"00" & s_int4) + (b"0" & s_int5 & b"0");
	s_res3 <= (b"00" & s_int6) + (b"0" & s_int7 & b"0");
	
	end process proc1;
	
	proc2 : process(s_res0,s_res1, s_res2, s_res3) is
	begin
	
	s_last0 <= (b"000" & s_res0) + (b"0" & s_res1 & b"00");
	s_last1 <= (b"000" & s_res2) + (b"0" & s_res3 & b"00");
	
	end process proc2;
	
	res <= (b"00000" & s_last0) + (b"0" & s_last1 & b"0000");
	P <= res(15 downto 0);



end combinatorial;

-- =============================================================================
-- =============================== multiplier16 ================================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16 is
    port(
        A, B : in  unsigned(15 downto 0);
        P    : out unsigned(31 downto 0)
    );
end multiplier16;

architecture combinatorial of multiplier16 is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;
	  
signal low_product : unsigned(15 downto 0);
signal mix_product_0 : unsigned(15 downto 0);
signal mix_product_1 : unsigned(15 downto 0);
signal high_product : unsigned(15 downto 0);


begin

low_pro : multiplier port map(

	A => A(7 downto 0),
	B => B(7 downto 0),
	P => low_product
);

high_pro : multiplier port map(

	A => A(15 downto 8),
	B => B(15 downto 8),
	P => high_product
);

mix_pro_0 : multiplier port map(

	A => A(15 downto 8),
	B => B(7 downto 0),
	P => mix_product_0
);

mix_pro_1 : multiplier port map(

	A => A(7 downto 0),
	B => B(15 downto 8),
	P => mix_product_1
);


P <= (high_product & x"0000")  + (x"00" & mix_product_0 & x"00") + (x"00" & mix_product_1 & x"00") + (x"0000" & low_product);



end combinatorial;

-- =============================================================================
-- =========================== multiplier16_pipeline ===========================
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier16_pipeline is
    port(
        clk     : in  std_logic;
        reset_n : in  std_logic;
        A, B    : in  unsigned(15 downto 0);
        P       : out unsigned(31 downto 0)
    );
end multiplier16_pipeline;

architecture pipeline of multiplier16_pipeline is

    -- 8-bit multiplier component declaration
    component multiplier
        port(
            A, B : in  unsigned(7 downto 0);
            P    : out unsigned(15 downto 0)
        );
    end component;

signal low_product : unsigned(15 downto 0);
signal mix_product_0 : unsigned(15 downto 0);
signal mix_product_1 : unsigned(15 downto 0);
signal high_product : unsigned(15 downto 0);

signal low_product_pipelined : unsigned(15 downto 0);
signal mix_product_0_pipelined : unsigned(15 downto 0);
signal mix_product_1_pipelined : unsigned(15 downto 0);
signal high_product_pipelined : unsigned(15 downto 0);



begin

low_pro : multiplier port map(

	A => A(7 downto 0),
	B => B(7 downto 0),
	P => low_product
);

high_pro : multiplier port map(

	A => A(15 downto 8),
	B => B(15 downto 8),
	P => high_product
);

mix_pro_0 : multiplier port map(

	A => A(15 downto 8),
	B => B(7 downto 0),
	P => mix_product_0
);

mix_pro_1 : multiplier port map(

	A => A(7 downto 0),
	B => B(15 downto 8),
	P => mix_product_1
);


P <= (high_product_pipelined & x"0000")  + (x"00" & mix_product_0_pipelined & x"00") + (x"00" & mix_product_1_pipelined & x"00") + (x"0000" & low_product_pipelined);

pipeline : process(clk, reset_n) is
	begin
		if(reset_n = '0') then
			low_product_pipelined <= (others => '0');
			high_product_pipelined <= (others => '0');
			mix_product_0_pipelined <= (others => '0');
			mix_product_1_pipelined <= (others => '0');
		else
			if(rising_edge(clk)) then
				low_product_pipelined <= low_product;
				high_product_pipelined <= high_product;
				mix_product_0_pipelined <= mix_product_0;
				mix_product_1_pipelined <= mix_product_1;
			end if;
		end if;
	
	end process pipeline;

end pipeline;
