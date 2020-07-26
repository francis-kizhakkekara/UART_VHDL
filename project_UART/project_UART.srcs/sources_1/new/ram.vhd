-- Group 14
-- RAM
-- Write First Mode
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Using the custom type to see the RAM
-- DELETE FROM HERE
package ram_cont_pkg is
    type ram_type is array (0 to 2**4-1) of std_logic_vector (8-1 downto 0);
    type state_type is (idle, write, read);
end package;
-- DELETE TO HERE
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.ram_cont_pkg.all;    -- DELETE THIS ALSO

entity ram is
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
        do      : out std_logic_vector(w-1 downto 0); -- DELETE SEMICOLON NON TESTING
        RAM_T   : out ram_type      -- DELETE THIS ONCE TESTING IS DONE
    );
end ram;

architecture Behavioral of ram is
    -- CHANGE BELOW LINE IF TYPE DEF IS NOT DELETED
    --type ram_type is array (0 to 2**r-1) of std_logic_vector (w-1 downto 0);    
    signal RAM : ram_type:= (others => (others => '0'));
    begin
        process (clk)
        begin
            if (clk'event and clk= '1') then
                if (en= '1') then
                    if (w_en = '1') then
                        RAM(to_integer(unsigned(addr))) <= di;
                        do <= di;
                    else
                        do <= RAM(to_integer(unsigned(addr)));
                    end if;
                end if;
            end if;
        end process;
        
        RAM_T <= RAM;
end Behavioral;
