-- Group 14
-- Tx TB

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Tx_TB is
end Tx_TB;

architecture Behavioral of Tx_TB is
    component uart_tx is
        generic(
            DBIT: integer := 8;
            SB_TICK: integer := 16
        );    
        port(
            clk, reset: in std_logic;
            tx_start: in std_logic;
            s_tick: in std_logic;
            din: in std_logic_vector(7 downto 0);
            tx_done_tick: out std_logic;
            tx: out std_logic
        );
    end component;
    
    signal clk, reset, tx_start, s_tick, tx_done_tick, tx: std_logic;
    signal din: std_logic_vector(7 downto 0):= (others => '0');
begin
    TX1: uart_tx port map(
        clk => clk, reset => reset, tx_start => tx_start, s_tick => s_tick,
        din => din, tx_done_tick => tx_done_tick, tx => tx
    );
    
    process begin
        reset <='1';
        tx_start <= '0';
        clk <= '1';
        wait for 10 ns;
        -- LSB IS SEND FIRST
        --din <= "10101010"; --0xAA
        din <= "00110011"; -- 0x33
        clk <= '0';
        wait for 10 ns;
        
        
        tx_start <= '1';
        reset <= '0';
        
        for i in 0 to 350 loop
            -- Clk is double the s_tick rate
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
            
            s_tick <= '0';
            clk <= '1';
            wait for 10 ns;
            clk <= '0';
            wait for 10 ns;
            
            s_tick <= '1';                            
        end loop; 
               
    end process; 
    
end Behavioral;