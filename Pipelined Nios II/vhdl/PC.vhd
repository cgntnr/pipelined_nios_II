library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is

signal s_addr : std_logic_vector(15 downto 0);
signal s_next_addr : std_logic_vector(15 downto 0);

begin

process(sel_a, sel_imm, branch, a, d_imm, e_imm, pc_addr)
begin
    if (sel_a = '0' and sel_imm = '0') then
        if (branch = '0') then
            s_addr <= std_logic_vector(unsigned(s_next_addr) + 4);
        elsif (branch = '1') then
            s_addr <= std_logic_vector(unsigned(pc_addr) + unsigned(e_imm) + 4);
        end if;
    elsif (sel_a = '1' and sel_imm = '0') then
        s_addr <= std_logic_vector(unsigned(a) + 4);
    elsif (sel_a = '0' and sel_imm = '1') then
        s_addr <= d_imm(13 downto 0) & b"00";
    end if;
end process;

process(clk, reset_n, s_addr)
begin
    if (reset_n = '0') then
        s_next_addr <= (others => '0');
    elsif (rising_edge(clk)) then
        s_next_addr <= s_addr;
    end if;
end process;

addr <= s_addr;
next_addr <= s_next_addr;

end synth;
