-- Group 14
-- Test UART
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
use work.ram_cont_pkg.all;    -- Add the custom package

entity Test_UART is
    port (
        sys_clk, sys_reset, sys_rx: in std_logic;
        sys_tx: out std_logic;
        RAM_out: out ram_type;
        -- DEBUB
        baud_ticker: out std_logic;
        dout_ux_fifo1, dout_fifo1_Ram, dout_Ram_fifo2, dout_fifo2_tx: out std_logic_vector(7 downto 0);
        rx_dn_tick1, tx_dn_tick1, tx_start_tick, ram_tx_rdy: out std_logic
        
    );
end Test_UART;

architecture Behavioral of Test_UART is    
    -- Baud Component
    component baud_gen is
        generic(N: integer := 9;
            M: integer := 163);
        Port (
            clk, reset:in std_logic;
            max_tick: out std_logic;
            q: out std_logic_vector(N-1 downto 0)
        );
    end component;
    -- Baud tick
    signal baud_tick: std_logic;
    
    -- Rx Component
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
    -- RX signals
    signal rx_done_tick1: std_logic := '0';
    signal rx_dout: std_logic_vector(7 downto 0):= (others => '0');
    
    -- FIFO Component
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
    -- FIFO 1 signals
    signal fifo_read_in1, fifo_empty_out1: std_logic;
    signal fifo_data_out1: std_logic_vector(7 downto 0);
    -- FIFO 2 signals
    signal fifo_read_in2, fifo_empty_out2: std_logic;
    signal fifo_data_out2: std_logic_vector(7 downto 0);
    
    -- RAM Controller Component
    component ram_cont is
        port(
            clk, reset, rx_ready, tx_ready  : in std_logic;
            di                              : in std_logic_vector(7 downto 0);
            tx_done, rx_done                : out std_logic;
            do                              : out std_logic_vector(7 downto 0);
            state_OUT                       : out state_type;
            RAM_T                           : out ram_type;
            curr_addr, wr_addr, r_addr      : out unsigned(3 downto 0)
        );
    end component;
    -- RAM Controller signals
    signal ram_rx_ready, ram_tx_ready, ram_tx_done: std_logic;
    signal tx_always_rdy: std_logic;
    signal ram_do: std_logic_vector(7 downto 0);
    
    -- Tx Component
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
    -- Tx signals
    signal tx_start: std_logic;
        
begin
    -- BAUD INSTANCE
    BGEN1: baud_gen port map(
        clk => sys_clk, reset => sys_reset,
        max_tick => baud_tick
    );
    baud_ticker <= baud_tick;
    
    -- RX INSTANCE
    RX1: uart_rx port map(
        clk => sys_clk, reset => sys_reset, 
        rx => sys_rx,
        s_tick => baud_tick,
        rx_done_tick => rx_done_tick1,
        dout => rx_dout
    );
    dout_ux_fifo1 <= rx_dout;
    rx_dn_tick1 <= rx_done_tick1;
    
    -- FIFO 1 INSTANCE
    FIFO1: fifo_buffer port map(
        clk => sys_clk, rst => sys_reset,
        read => fifo_read_in1,
        write => rx_done_tick1,
        data_in => rx_dout,
        data_out => fifo_data_out1,
        empty => fifo_empty_out1 
    );
    dout_fifo1_Ram <= fifo_data_out1;
    
    -- RAM CONT INSTANCE
    ram_rx_ready <= not fifo_empty_out1;
    tx_always_rdy <= '1';
    RAM_CONT1: ram_cont port map(
        clk => sys_clk, reset => sys_reset, 
        rx_ready => ram_rx_ready, 
        tx_ready => tx_always_rdy,
        di => fifo_data_out1, 
        tx_done => ram_tx_done, 
        rx_done => fifo_read_in1, 
        do => ram_do,
        RAM_T => RAM_out
    );
    dout_Ram_fifo2 <= ram_do;
    ram_tx_rdy <= tx_always_rdy;
    
    -- FIFO 2 INSTANCE
    FIFO2: fifo_buffer port map(
        clk => sys_clk, rst => sys_reset,
        read => fifo_read_in2,
        write => ram_tx_done,
        data_in => ram_do,
        data_out => fifo_data_out2,
        empty => fifo_empty_out2,
        full => ram_tx_ready
    );
    dout_fifo2_tx <= fifo_data_out2;
    
    -- TX INSTANCE
    tx_start <= not fifo_empty_out2;
    TX1: uart_tx port map(
        clk => sys_clk, reset => sys_reset,
        tx_start => tx_start,
        s_tick => baud_tick,
        din => fifo_data_out2,
        tx_done_tick => fifo_read_in2,
        tx => sys_tx
    );
    tx_start_tick <= tx_start;
    tx_dn_tick1 <= fifo_read_in2;
    
end Behavioral;
