library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity control_registers is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        write_n   : in  std_logic;
        backup_n  : in  std_logic;
        restore_n : in  std_logic;
        address   : in  std_logic_vector(2 downto 0);
        irq       : in  std_logic_vector(31 downto 0);
        wrdata    : in  std_logic_vector(31 downto 0);

        ipending  : out std_logic;
        rddata    : out std_logic_vector(31 downto 0)
    );
end control_registers;

architecture synth of control_registers is
    signal pie : std_logic;
    signal epie : std_logic;
    signal ienable : std_logic_vector(31 downto 0);
    constant zero : std_logic_vector(31 downto 0) := (others => '0');
begin

process(clk, reset_n, write_n, backup_n, restore_n, address, wrdata, pie, epie)
begin
    if (reset_n = '0') then
        pie <= '0';
        epie <= '0';
        ienable <= (others => '0');
    elsif (rising_edge(clk)) then
        if (write_n = '0') then
            if (address = "000") then
                pie <= wrdata(0);
            elsif (address = "011") then
                ienable <= wrdata;
            end if;
        elsif (backup_n = '0') then
            epie <= pie;
            pie <= '0';
        elsif (restore_n = '0') then
            pie <= epie;
        end if;
    end if;
end process;

process(address, irq, pie, epie, ienable)
begin
    if (address = "000") then
        rddata <= (0 => pie, others => '0');
    elsif (address = "001") then
        rddata <= (0 => epie, others => '0');
    elsif (address = "011") then
        rddata <= ienable;
    elsif (address = "100") then
        rddata <= irq and ienable;
    end if;
end process;

ipending <= '1' when (pie = '1' and ((irq and ienable) /= zero)) else '0';

end synth;
