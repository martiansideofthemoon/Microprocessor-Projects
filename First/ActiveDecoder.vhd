library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity ActiveDecoder is
  port (
    instruction: in std_logic_vector(1 downto 0);
    carry: in std_logic;
    zero: in std_logic;
    active: out std_logic
  );
end entity ActiveDecoder;

architecture Struct of ActiveDecoder is
begin
  process(instruction, carry, zero)
  begin
    if (instruction = "00") then
      active <= '1';
    elsif (instruction = "01") then
      active <= zero;
    elsif (instruction = "10") then
      active <= carry;
    elsif (instruction = "11") then
      active <= carry and zero;
    end if;
  end process;
end Struct;
