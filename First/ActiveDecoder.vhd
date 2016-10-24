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
  variable n_active: std_logic := '0';
  begin
    if (instruction = "00") then
      n_active := '1';
    elsif (instruction = "01") then
      n_active := zero;
    elsif (instruction = "10") then
      n_active := carry;
    elsif (instruction = "11") then
      n_active := carry and zero;
    else
      n_active := '0';
    end if;
    active <= n_active;
  end process;
end Struct;
