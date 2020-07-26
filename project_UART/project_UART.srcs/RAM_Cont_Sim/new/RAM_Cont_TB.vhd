-- Group 14
-- RAM Controller TB
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

entity RAM_Cont_TB is
end RAM_Cont_TB;

architecture Behavioral of RAM_Cont_TB is
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
    
    signal clk, reset, rx_ready, tx_ready, tx_done, rx_done: std_logic;
    signal di: std_logic_vector(7 downto 0):= (others => '0');
    signal do: std_logic_vector(7 downto 0);
    SIGNAL RAM_T : ram_type:= (others => (others => '0'));
    SIGNAL STATE: state_type;
    SIGNAL curr_addr, wr_addr, r_addr: unsigned(3 downto 0);
begin
    RAM_CONT1: ram_cont port map(
        clk => clk, 
        reset => reset, 
        rx_ready => rx_ready, 
        tx_ready => tx_ready,
        di => di, 
        tx_done => tx_done, 
        rx_done => rx_done, 
        do => do
        , state_OUT => STATE, RAM_T => RAM_T, curr_addr => curr_addr, wr_addr => wr_addr, r_addr => r_addr
    );
    
    process begin
        -- Initialize pins
        reset <= '1';
        rx_ready <= '0';
        tx_ready <= '0';        
        clk <= '1';         -- Reset Cycle     
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns; 
        
        -- Enable WRITE ONLY
        reset <= '0';
        rx_ready <= '1';
        di <= "00110011"; -- 0x33                        
        clk <= '1';        
        wait for 10 ns;     -- Write Cycle     
        clk <= '0';
        wait for 10 ns;        
        rx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable WRITE ONLY
        rx_ready <= '1';
        di <= "10101010"; --0xAA                        
        clk <= '1';        
        wait for 10 ns;     -- Write Cycle     
        clk <= '0';
        wait for 10 ns;        
        rx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable WRITE ONLY
        rx_ready <= '1';
        di <= "11101110"; --0xEE                        
        clk <= '1';        
        wait for 10 ns;     -- Write Cycle     
        clk <= '0';
        wait for 10 ns;        
        rx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable READ ONLY
        tx_ready <= '1';
        clk <= '1';        
        wait for 10 ns;     -- READ Cycle      
        clk <= '0';
        wait for 10 ns;
        tx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable READ ONLY
        tx_ready <= '1';
        clk <= '1';        
        wait for 10 ns;     -- READ Cycle      
        clk <= '0';
        wait for 10 ns;
        tx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable READ ONLY
        tx_ready <= '1';
        clk <= '1';        
        wait for 10 ns;     -- READ Cycle      
        clk <= '0';
        wait for 10 ns;
        tx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns; 
        
        -- Enable READ ONLY
        tx_ready <= '1';
        clk <= '1';        
        wait for 10 ns;     -- READ Cycle      
        clk <= '0';
        wait for 10 ns;
        tx_ready <= '0';        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;         
               
    end process;
end Behavioral;