library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RAM is
    generic(
        addr_width : integer := 128; -- store 32 elements
        addr_bits  : integer := 7; -- required bits to store 32 elements
        data_width : integer := 9 -- each element has 9-bits
        );
port(
    addr : in std_logic_vector(addr_bits-1 downto 0);
	 clk:in std_logic;
    data : in std_logic_vector(data_width-1 downto 0);
	 w: in std_logic;
	 q : out std_logic_vector(data_width-1 downto 0));
end RAM;

architecture arch of RAM is

    type ram_type is array (0 to addr_width-1) of std_logic_vector(data_width-1 downto 0);
    
    signal RAM : ram_type; 
	 signal r_addr : std_logic_vector(0 to addr_bits-1);
  
  -- note that 'ram_init_file' is not the user-defined-name (it is attribute name)
    attribute ram_init_file : string; 
    -- "rom_data.mif" is the relative address with respect to project directory
    -- suppose ".mif" file is saved in folder "ROM", then use "ROM/rom_data.mif"
    attribute ram_init_file of RAM : signal is "myram.mif";

begin
RAMproc: process(clk) is
begin 
if rising_edge(clk) then
if w ='1' then
RAM(to_integer(unsigned(addr))) <= data ;
end if;
r_addr<= addr;
end if;
end process RAMproc;
q<= RAM(to_integer(unsigned(r_addr)));
end arch; 

