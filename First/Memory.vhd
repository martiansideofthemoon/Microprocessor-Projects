library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;

entity Memory is
  port(
    dout1        : out std_logic_vector(15 downto 0);
    dout2        : out std_logic_vector(15 downto 0);
    din          : in  std_logic_vector(15 downto 0);
    register_write : in  std_logic;
    readA1       : in  std_logic_vector(2 downto 0);
    readA2       : in  std_logic_vector(2 downto 0);
    writeA3      : in  std_logic_vector(2 downto 0);
    clk          : in  std_logic
    );
end Memory;


architecture Struct of Memory is
  type Memory is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers : Memory;
begin
  regFile : process (clk) is
  begin
    if rising_edge(clk) then
      -- Write and bypass
      if register_write = '1' then
        registers(to_integer(unsigned(writeA3))) <= din;  -- Write
      end if;

    end if;
  end process regFile;
        -- Read A and B before bypass
  dout1 <= registers(to_integer(unsigned(readA1)));
  dout2 <= registers(to_integer(unsigned(readA2)));
end Struct;