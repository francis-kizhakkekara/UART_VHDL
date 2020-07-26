-- Group 14
-- Rx TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Rx_TB is
end Rx_TB;

architecture Behavioral of Rx_TB is
    component uart_rx is
        generic(
            DBIT: integer := 8;
            SB_TICK: integer := 16
        );
        port(
            clk, reset: in std_logic;
            rx: in std_logic;
            s_tick: in std_logic;
            rx_done_tick: out std_logic;
            dout: out std_logic_vector(7 downto 0)
        );
    end component;
    
    signal clk, reset, rx, s_tick, rx_done_tick: std_logic := '0';
    signal dout: std_logic_vector(7 downto 0):= (others => '0');
    signal sTickCtr, clkCtr: integer := 0;
    constant CLOCK_PERIOD: TIME := 2ns;
            
begin
    RX1: uart_rx port map(
        clk => clk, reset => reset, rx => rx, s_tick => s_tick,
        rx_done_tick => rx_done_tick, dout => dout
    );
    
    -- Total real time would take:
    -- Time = clk_period * 163(clk divider) * 16 (for oversampling or to match baud rate)
    --        * 10 bits (including start/end bits. 11 if parity is added)
    --        * 2 (for rx and tx) + few clk cycles the round trip thru fifo and ram
    -- Time = clk_period * 26080(for rx) * 2
    -- Rx Time = 2ns * 26080 = 52,160ns = 52.2us
    -- Total Time = 2ns * 26080 * 2 = 104,320
    rx_proc: process begin
        -- Reset on and off
        reset <='1';        
        wait for CLOCK_PERIOD*2;
        reset <='0';        
        wait for CLOCK_PERIOD*2;
        
        -- Star tbit has to be 0
        rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        
        -- Rx goes from LSB TO MSB
        -- Creating 0x77 or 0111 0111
        -- 1110 1110 for rx        
        -- 111
        rx <= '1';
        wait for CLOCK_PERIOD*163*16*3;
        -- 0
        rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        -- 111
        rx <= '1';
        wait for CLOCK_PERIOD*163*16*3;
        -- 0
        rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        
        -- Stop bit has to be 1 and then idle at 1
        rx <= '1';
        wait for CLOCK_PERIOD*163*16*4;                          
               
    end process;
    
    -- Clock process
    clock_process: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD/2;
        clk <= '1';
        wait for CLOCK_PERIOD/2;
    end process;
    
    -- s_tick process
    s_tick_process: process
    begin
        s_tick <= '0';
        wait for CLOCK_PERIOD*162;
        s_tick <= '1';
        wait for CLOCK_PERIOD;
    end process;
    
    -- This is to check the clk and s_ticks needed to get to the output
    process(clk, s_tick)
    begin
        if(rising_edge(clk)) then
            clkCtr <= clkCtr + 1;             
        end if;
        if(rising_edge(s_tick)) then
            sTickCtr <= sTickCtr + 1;
        end if;
    end process;
end Behavioral;