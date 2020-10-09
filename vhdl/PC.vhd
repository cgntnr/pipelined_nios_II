library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk          : in  std_logic;
        reset_n      : in  std_logic;
        en           : in  std_logic;
        sel_a        : in  std_logic;
        sel_imm      : in  std_logic;
        sel_ihandler : in  std_logic;
        add_imm      : in  std_logic;
        imm          : in  std_logic_vector(15 downto 0);
        a            : in  std_logic_vector(15 downto 0);
        addr         : out std_logic_vector(31 downto 0)
    );
end PC;

architecture synth of PC is
    
	 
SIGNAL s_addr_lsb : std_logic_vector(15 downto 0);
begin



process(clk,reset_n)
begin
		if(reset_n = '0') then --asynchronous reset
			
			s_addr_lsb <= (others => '0');
		
		elsif(rising_edge(clk)) then 
			if(en = '1') then 		
				if(sel_ihandler = '1') then			
					s_addr_lsb <= x"0004";
				elsif(sel_a = '1') then
					s_addr_lsb <= a; 
				elsif(sel_imm = '1') then
					s_addr_lsb <= imm(13 downto 0) & "00"; --shifting 2 bits 
				elsif(add_imm = '1') then 
					s_addr_lsb <= std_logic_vector(unsigned(s_addr_lsb) + unsigned(imm));
				else
					s_addr_lsb <= std_logic_vector(unsigned(s_addr_lsb) + 4); --increment 4 as usual 
				end if;
			end if;
		end if;

end process;

addr <= x"0000" & s_addr_lsb(15 downto 2) & b"00"; --extends and guarentees 2 lsb is '0'
    
end synth;
