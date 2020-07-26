-- Group 14
-- UART TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Using the custom type to see the RAM
package ram_cont_pkg is
    type ram_type is array (0 to 2**4-1) of std_logic_vector (8-1 downto 0);
    type state_type is (idle, write, read);
end package;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ram_cont_pkg.all;    -- Add the package

entity Test_TB is
end Test_TB;

architecture Behavioral of Test_TB is
    component Test_UART is
        port (
            sys_clk, sys_reset, sys_rx: in std_logic;
            sys_tx: out std_logic;
            RAM_out: out ram_type;
            -- DEBUB
            baud_ticker: out std_logic;
            dout_ux_fifo1, dout_fifo1_Ram, dout_Ram_fifo2, dout_fifo2_tx: out std_logic_vector(7 downto 0);
            rx_dn_tick1, tx_dn_tick1, tx_start_tick, ram_tx_rdy: out std_logic
            
        );
    end component;
    
    signal sys_clk, sys_reset, sys_rx, sys_tx, baud_ticker: std_logic;
    signal RAM_out: ram_type;
    signal sTickCtr, clkCtr: integer := 0;
    -- DEBUG
    SIGNAL dout_ux_fifo1, dout_fifo1_Ram, dout_Ram_fifo2, dout_fifo2_tx: std_logic_vector(7 downto 0);
    signal rx_dn_tick1, tx_dn_tick1, tx_start_tick, ram_tx_rdy: std_logic;
    constant CLOCK_PERIOD: TIME := 2ns;
begin
    UART1: Test_UART port map(
        sys_clk => sys_clk, sys_reset => sys_reset,
        sys_rx => sys_rx, sys_tx => sys_tx, 
        RAM_out => RAM_out,
        baud_ticker => baud_ticker,
        -- DEBUG
        dout_ux_fifo1 => dout_ux_fifo1, dout_fifo1_Ram => dout_fifo1_Ram,
        dout_Ram_fifo2 => dout_Ram_fifo2, dout_fifo2_tx => dout_fifo2_tx,
        rx_dn_tick1 => rx_dn_tick1, tx_dn_tick1 => tx_dn_tick1,
        tx_start_tick => tx_start_tick, ram_tx_rdy => ram_tx_rdy
    );
    
    rx_proc: process begin
        -- Reset on and off
        sys_reset <='1';        
        wait for CLOCK_PERIOD*2;
        sys_reset <='0';        
        wait for CLOCK_PERIOD*2;
        
        -- Start bit has to be 0
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        
        -- Rx goes from LSB TO MSB
        -- Creating 0x77 or 0111 0111
        -- 1110 1110 for rx        
        -- 111
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*3;
        -- 0
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        -- 111
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*3;
        -- 0
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        
        -- Stop bit has to be 1 and then idle at 1
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*4;
        
        -- 0xCC or 1100 1100
        -- Start bit has to be 0
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16;
        -- LSB
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16*2;
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*2;
        sys_rx <= '0';
        wait for CLOCK_PERIOD*163*16*2;
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*2;
        -- Stop bit has to be 1 and then idle at 1
        sys_rx <= '1';
        wait for CLOCK_PERIOD*163*16*20;     -- idle for some time                  
               
    end process;
    
    -- Clock process
    clock_process: process
    begin
        sys_clk <= '0';
        wait for CLOCK_PERIOD/2;
        sys_clk <= '1';
        wait for CLOCK_PERIOD/2;
    end process;
    
    -- This is to check the clk and s_ticks needed to get to the output
    process(sys_clk, baud_ticker)
    begin
        if(rising_edge(sys_clk)) then
            clkCtr <= clkCtr + 1;             
        end if;
        if(rising_edge(baud_ticker)) then
            sTickCtr <= sTickCtr + 1;
        end if;
    end process;
    
end Behavioral;