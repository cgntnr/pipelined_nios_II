library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
    port(
        -- bus interface
        clk     : in  std_logic;
        reset_n : in  std_logic;
        cs      : in  std_logic;
        read    : in  std_logic;
        write   : in  std_logic;
        address : in  std_logic_vector(1 downto 0);
        wrdata  : in  std_logic_vector(31 downto 0);

        irq     : out std_logic;
        rddata  : out std_logic_vector(31 downto 0)
    );
end timer;

architecture synth of timer is

    signal s_counter : std_logic_vector(31 downto 0);
    signal s_period : std_logic_vector(31 downto 0);
    signal s_cont : std_logic;
    signal s_ito : std_logic;
    signal s_run : std_logic;
    signal s_to : std_logic;

    signal s_cs_read : std_logic;
    signal s_address : std_logic_vector(1 downto 0);

begin

    ff : process (clk, reset_n, cs, read, write, address, wrdata, s_counter, s_period, s_cont, s_ito, s_run, s_to, s_cs_read, s_address) is
    begin

    if (reset_n = '0') then -- asynchronous reset
        s_counter <= (others => '0');
        s_period <= (others => '0');
        s_cont <= '0';
        s_ito <= '0';
        s_run <= '0';
        s_to <= '0';
        s_cs_read <= '0';
        s_address <= (others => '0');
    elsif (rising_edge(clk)) then
        s_cs_read <= cs and read;
        s_address <= address;

        if (cs = '1' and write = '1') then
            if (address = b"01") then
                s_counter <= wrdata;
                s_period <= wrdata;
                s_run <= '0';
            elsif (address = b"10") then
                s_cont <= wrdata(0);
                s_ito <= wrdata(1);
                if (s_run = '1' and wrdata(2) = '1' and wrdata(3) = '0') then
                    s_run <= '0';
                elsif (s_run = '0' and wrdata(2) = '0' and wrdata(3) = '1') then
                    s_run <= '1';
                end if;
            elsif (address = b"11") then
                s_to <= wrdata(1) and s_to;
            end if;
        end if;
        if (s_run = '1') then
        --if (s_run = '1' and (cs /= '1' or write /= '1' or address /= b"01")) then
            if (unsigned(s_counter) = 0) then
                s_counter <= s_period;
                s_run <= s_cont;
                s_to <= '1';
            else
                s_counter <= std_logic_vector(unsigned(s_counter) - 1);
            end if;
        end if;
    end if;

    if (s_cs_read = '1') then
        if (s_address = b"00") then rddata <= s_counter;
        elsif (s_address = b"01") then rddata <= s_period;
        elsif (s_address = b"10") then rddata <= (0 => s_cont,
                                                  1 => s_ito,
                                                  others => '0');
        elsif (s_address = b"11") then rddata <= (0 => s_run,
                                                  1 => s_to,
                                                  others => '0');
        end if;
    else
        rddata <= (others => 'Z');
    end if;

    irq <= s_ito and s_to;

    end process ff;

end synth;
