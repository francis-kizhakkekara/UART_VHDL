-- Group 14
-- FIFO TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FIFO_Buffer_TB is
end FIFO_Buffer_TB;

architecture Behavioral of FIFO_Buffer_TB is
    component fifo_buffer is
        generic(
            ADDRESS_BITS: Integer := 3; -- The number of address bits (2**ADDRESS_BITS = BUFFER_WIDTH)
            BUFFER_WIDTH: Integer := 8  -- The width of the buffer in bits
        );
        port (
            clk, rst, read, write : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR ((BUFFER_WIDTH - 1) downto 0);
            data_out : out STD_LOGIC_VECTOR ((BUFFER_WIDTH - 1) downto 0);
            empty, full : out STD_LOGIC
        );
    end component;
    
    signal clk, rst, read, write, empty, full: STD_LOGIC;
    signal data_in, data_out : STD_LOGIC_VECTOR (7 downto 0);
    constant CLOCK_PERIOD: TIME := 10ns;
begin
    FIFO1: fifo_buffer port map(
        read => read, write => write, data_in => data_in, data_out => data_out,
        empty => empty, full => full, clk => clk, rst => rst
    );
    
    clock_process: process
    begin
        clk <= '0';
        wait for CLOCK_PERIOD/2;
        clk <= '1';
        wait for CLOCK_PERIOD/2;
    end process;
    
    test_proc: process
    begin
        rst <= '0';
        read <= '0';
        write <= '1';
        data_in <= STD_LOGIC_VECTOR(TO_UNSIGNED(3, 8));
        wait for CLOCK_PERIOD;
        
        write <= '0';
        read <= '1';
        wait for CLOCK_PERIOD;
        
        read <= '1';
        wait for CLOCK_PERIOD;
        
        data_in <= STD_LOGIC_VECTOR(TO_UNSIGNED(4, 8));
        wait for CLOCK_PERIOD;
        
        write <= '1';
        data_in <= STD_LOGIC_VECTOR(TO_UNSIGNED(5, 8));
        wait for CLOCK_PERIOD;
        
        write <= '1';
        data_in <= STD_LOGIC_VECTOR(TO_UNSIGNED(6, 8));
        wait for CLOCK_PERIOD;
        
        read <= '1';
        wait for CLOCK_PERIOD;
        
        read <= '1';
        wait for CLOCK_PERIOD;
        
        read <= '1';
        wait for CLOCK_PERIOD;
        
        read <= '1';
        wait for CLOCK_PERIOD;
        
        rst <= '1';
        wait for CLOCK_PERIOD;
        
        rst <= '0';
        wait for CLOCK_PERIOD;
        
    end process;    
    
end Behavioral;