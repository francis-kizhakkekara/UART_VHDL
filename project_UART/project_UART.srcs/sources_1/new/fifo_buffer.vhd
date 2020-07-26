-- Group 14
-- FIFO
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo_buffer is
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
end fifo_buffer;

architecture Behavioral of fifo_buffer is
    type register_file_type is array( 0 to 2**(ADDRESS_BITS - 1)) of STD_LOGIC_VECTOR((BUFFER_WIDTH - 1) downto 0);
    
    signal register_file: register_file_type := (others => (others => '0'));
    signal currently_full, currently_empty : STD_LOGIC;
    signal read_ptr, write_ptr : UNSIGNED(ADDRESS_BITS downto 0) := (others => '0');

begin
    process(rst, clk)
    begin
        if (rst = '1') then
            -- Set the read and write pointers to 0, and clear the register file
            read_ptr <= (others => '0');
            write_ptr <= (others => '0');
            register_file <= (others => (others => '0'));
        
        elsif (rising_edge(clk)) then
            if (currently_full = '0' and write = '1') then
                -- If the register file is not full and a write is requested, then store the
                -- desired value at teh next available location in the register file
                register_file(TO_INTEGER(write_ptr(ADDRESS_BITS downto 0))) <= data_in;
                write_ptr <= write_ptr + 1; -- Advance the write pointer
            end if;
            
            if (currently_empty = '0' and read = '1') then
                -- If the register file is not empty and the read signal is active, then
                -- advance the read pointer 
                read_ptr <= read_ptr + 1;
            end if;
        end if;
    end process;

    -- output the current data file to the 
    data_out <= register_file(TO_INTEGER(read_ptr((ADDRESS_BITS - 1) downto 0)));
    
    -- Indicate whether the buffer is currently full. This will be 1 when the MSBs of 
    -- the read and write pointers are different (indicate full buffer)
    currently_full <= '1' when ((read_ptr XOR write_ptr) = 2**(ADDRESS_BITS)) else '0';
    full <= currently_full; -- Map to external output signal
    
    currently_empty <= '1' when (read_ptr = write_ptr) else '0';
    empty <= currently_empty; -- Map to external output signal

end Behavioral;
