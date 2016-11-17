library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;
use work.MemoryComponent.all;

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
  --signal memory_low : Memory;
  signal mem_array: MemArray := INIT_MEMORY;
  signal addr_plus: std_logic_vector(15 downto 0);
begin
  addr_plus <= std_logic_vector(unsigned(addr) + 1);
  process (clk) is
  begin
    if rising_edge(clk) then
      -- Write and bypass
      if mem_write = '1' then
        mem_array(to_integer(unsigned(addr(6 downto 0)))) <= data(7 downto 0);
        mem_array(to_integer(unsigned(addr_plus(6 downto 0)))) <= data(15 downto 8);
      end if;

    end if;
  end process;

  mem_out(15 downto 8) <= mem_array(to_integer(unsigned(addr_plus(6 downto 0))));
  mem_out(7 downto 0) <= mem_array(to_integer(unsigned(addr(6 downto 0))));
end Struct;