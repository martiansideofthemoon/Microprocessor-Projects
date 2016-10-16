library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;

entity Memory is
  port(
    mem_out      : out std_logic_vector(15 downto 0);
    data         : in std_logic_vector(15 downto 0);
    addr         : in  std_logic_vector(15 downto 0);
    mem_write    : in  std_logic;
    clk          : in  std_logic
    );
end Memory;


architecture Struct of Memory is
  type Memory is array(0 to 255) of std_logic_vector(7 downto 0);
  signal memory_low : Memory;
  signal memory_high : Memory;
  signal addr_high: std_logic_vector(7 downto 0);
  signal addr_low: std_logic_vector(7 downto 0);
  signal out_low: std_logic_vector(7 downto 0);
  signal out_high: std_logic_vector(7 downto 0);
  signal data_low: std_logic_vector(7 downto 0);
  signal data_high: std_logic_vector(7 downto 0);
begin
  addr_high <= addr(15 downto 8);
  addr_low <= addr(7 downto 0);
  data_high <= data(15 downto 8);
  data_low <= data(7 downto 0);
  mem : process (clk) is
  begin
    if rising_edge(clk) then
      -- Write and bypass
      if mem_write = '1' then
        memory_low(to_integer(unsigned(addr_low))) <= data_low;
        memory_high(to_integer(unsigned(addr_high))) <= data_high;
      end if;

    end if;
  end process mem;
        -- Read A and B before bypass
  out_low <= memory_low(to_integer(unsigned(addr_low)));
  out_high <= memory_high(to_integer(unsigned(addr_high)));
  mem_out(15 downto 8) <= out_high;
  mem_out(7 downto 0) <= out_low;
end Struct;