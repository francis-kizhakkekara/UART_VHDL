-- Group 14
-- RAM Controller
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

entity ram_cont is
    port(
        clk, reset, rx_ready, tx_ready  : in std_logic;
        di                              : in std_logic_vector(7 downto 0);
        tx_done, rx_done           : out std_logic;
        do                              : out std_logic_vector(7 downto 0);
        state_OUT                       : out state_type;
        RAM_T                           : out ram_type;
        curr_addr, wr_addr, r_addr      : out unsigned(3 downto 0)
    );
end ram_cont;

architecture Behavioral of ram_cont is
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
            do      : out std_logic_vector(w-1 downto 0); -- DELETE SEMICOLO FOR NON TESTIN
            RAM_T   : out ram_type      -- DELETE THIS ONCE TESTING IS DONE
        );
    end component;
    
    signal w_en, ram_en: std_logic;
    signal ram_addr: std_logic_vector(3 downto 0):= (others => '0');
    
    --type state_type is (idle, write, read);
    signal curr_state, next_state: state_type;
    signal validPtr: boolean:= false;
    signal rdPointer, wrPointer, rdNext, wrNext: unsigned(3 downto 0):= (others => '0');
begin
    RAM1: ram port map(
        clk => clk, w_en => w_en, en => ram_en, addr => ram_addr,
        di => di, do => do
        , RAM_T => RAM_T
    );
    
    process(clk, reset) begin
        if(reset = '1') then
            curr_state <= idle;
            rdPointer <= (others => '0');
            wrPointer <= (others => '0');
        elsif(clk'event and clk='1') then
            curr_state <= next_state;
            rdPointer <= rdNext;
            wrPointer <= wrNext;
        end if;
    end process;
    
    -- Next State Logic
    process(curr_state, rx_ready, tx_ready, rdPointer, wrPointer, validPtr) begin
        next_state <= curr_state;
        rdNext <= rdPointer;
        wrNext <= wrPointer;
        
        next_state <= curr_state;
        w_en <= '0';
        ram_en <= '0';
        rx_done <= '0';
        tx_done <= '0';
        
        case curr_state is
            when idle =>
                if(rx_ready = '1') then
                    w_en <= '1';
                    ram_en <= '1';                    
                    ram_addr <= std_logic_vector(wrPointer);
                    wrNext <= wrPointer +1;
                    next_state <= write;
                elsif(tx_ready = '1') then
                    if(validPtr) then
                        ram_en <= '1';                        
                        ram_addr <= std_logic_vector(rdPointer);
                        rdnext <= rdPointer + 1;
                        next_state <= read;
                    end if;
                end if;
            when write =>
                rx_done <= '1';
                next_state <= idle;
            when read =>
                tx_done <= '1';
                next_state <= idle;
        end case;
    end process;
                       
    validPtr <= false when (rdPointer = wrPointer) else true;
    state_OUT <= curr_state;
    curr_addr <= unsigned(ram_addr);
    wr_addr <= wrNext;
    r_addr <= rdNext;
end Behavioral;
