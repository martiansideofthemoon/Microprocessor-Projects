library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;

entity RegisterFile is
  port(
    dout1        : out std_logic_vector(15 downto 0);
    dout2        : out std_logic_vector(15 downto 0);
    din          : in  std_logic_vector(15 downto 0);
    register_write : in  std_logic;
    readA1       : in  std_logic_vector(2 downto 0);
    readA2       : in  std_logic_vector(2 downto 0);
    writeA3      : in  std_logic_vector(2 downto 0);
    PC_write     : in  std_logic;
    PC_in        : in std_logic_vector(15 downto 0);
    PC_out       : out  std_logic_vector(15 downto 0);
    clk          : in  std_logic
    );
end RegisterFile;


architecture Struct of RegisterFile is
  type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers : registerFile;
begin
  regFile : process (clk) is
  begin
    if rising_edge(clk) then
      -- Read A and B before bypass
      dout1 <= registers(to_integer(unsigned(readA1)));
      dout2 <= registers(to_integer(unsigned(readA2)));

      -- Write and bypass
      if register_write = '1' then
        registers(to_integer(unsigned(writeA3))) <= din;  -- Write
        if readA1 = writeA3 then  -- Bypass for read A
          dout1 <= din;
        end if;
        if readA2 = writeA3 then  -- Bypass for read B
          dout2 <= din;
        end if;
      end if;

      if PC_write = '1' then
        registers(7) <= PC_in;  -- Write
      end if;
      PC_out <= registers(7);
    end if;
  end process regFile;
end Struct;