-- Group 14
-- RAM TB
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Using the custom type to see the RAM
-- DELETE FROM HERE
package my_package is
    type ram_type is array (0 to 2**4-1) of std_logic_vector (8-1 downto 0);
end package;
-- DELETE TO HERE
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.my_package.all;    -- DELETE THIS ALSO

entity RAM_TB is
end RAM_TB;

architecture Behavioral of RAM_TB is
    component ram is
        generic(
            w: integer := 8;  --number of bits per RAM word
            r: integer := 4    --2^r = number of words in RAM
        );
        port(
            clk     : in std_logic;
            w_en    : in std_logic;
            en      : in std_logic;
            addr    : in std_logic_vector(r-1 downto 0);
            di      : in std_logic_vector(w-1 downto 0);
            do      : out std_logic_vector(w-1 downto 0);
            RAM_T   : out ram_type
        );
    end component;
    
    signal clk, w_en, en: std_logic;
    signal addr: std_logic_vector(4-1 downto 0):= (others => '0');
    signal di, do: std_logic_vector(8-1 downto 0):= (others => '0');
    SIGNAL RAM_T : ram_type:= (others => (others => '0'));
begin
    RAM1: ram port map(
        clk => clk, w_en => w_en, en => en, addr => addr,
        di => di, do => do, RAM_T => RAM_T
    );
    
    process begin
        -- Initialize pins
        en <= '0';
        w_en <= '0';
        addr <= "0000";
        di <= "00110011"; -- 0x33
        --din <= "10101010"; --0xAA
        
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        -- Enable pins
        en <= '1';
        w_en <= '1';
                
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 10 ns;
        
        addr <= "0100";
        di <= "10101010"; --0xAA
        clk <= '1';        
        wait for 10 ns;        
        clk <= '0';
        wait for 1000 ns;
        
               
    end process;
end Behavioral;