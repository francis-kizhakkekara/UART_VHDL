-- Group 14
-- Baud Gen TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Baud_Gen_TB is
end Baud_Gen_TB;

architecture Behavioral of Baud_Gen_TB is
    -- N is number of bits, M is the 1 tick per M cycle of clk
    CONSTANT NINT: INTEGER := 9;
    -- Component
    component baud_gen is
        generic(N: integer := NINT;
            M: integer := 163);
        Port (
            clk, reset:in std_logic;
            max_tick: out std_logic;
            q: out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    signal clk, reset: std_logic := '0';
    signal max_tick: std_logic;
    signal q: std_logic_vector(NINT-1 downto 0);
begin
    BGEN1: baud_gen port map(
        clk => clk, reset => reset, max_tick => max_tick, q => q
    );
    
    
    process begin
        reset <='1';
        clk <= '1';
        wait for 10 ns;
        clk <= '0';
        wait for 10 ns;
        
        
        reset <= '0';       
        for i in 0 to 350 loop
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;                
        end loop; 
               
    end process;
    
end Behavioral;