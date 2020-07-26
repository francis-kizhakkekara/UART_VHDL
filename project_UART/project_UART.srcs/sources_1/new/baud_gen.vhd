-- Group 14
-- Baud Gen 
-- If SysClk = 50 MHz
-- Baud Rate = 19200 * 16 = 307200
-- max_tick is the clk output. It pulse at the begining instead of towards the end of the cycle.
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity baud_gen is
    generic(N: integer := 9;
        M: integer := 163);
    Port (
        clk, reset:in std_logic;
        max_tick: out std_logic;
        q: out std_logic_vector(N-1 downto 0)
    );
end baud_gen;

 architecture Behavioral of baud_gen is
    signal r_reg: unsigned(N-1 downto 0):= (others => '0'); 
    signal r_next: unsigned(N-1 downto 0);
begin
    process(clk, reset)
    begin
        if (reset = '1') then
            r_reg<= (others => '0');
        elsif(clk'event and clk='1') then
            r_reg<= r_next;
        end if;
    end process;
    
    r_next <= (others => '0') when r_reg = (M-1) else r_reg+ 1;
    q <= std_logic_vector(r_reg);
    -- I have changed max_tick
    max_tick<= '1' when r_reg=(0) else '0';
end Behavioral;
