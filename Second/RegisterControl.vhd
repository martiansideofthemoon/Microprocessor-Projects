library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity RegisterControl is
  port (
    instruction: in std_logic_vector(15 downto 0);
    pl_input_zero: in std_logic;
    pc_enable: out std_logic;
    p1_enable: out std_logic;
    reset: in std_logic
  );
end entity RegisterControl;

architecture Struct of RegisterControl is
  signal op_code: std_logic_vector(3 downto 0);
begin
op_code <= instruction(15 downto 12);

process(instruction, op_code, pl_input_zero, reset)
  variable npc_enable: std_logic := '0';
  variable np1_enable: std_logic := '0';
begin
  if (op_code = "0110" and instruction(7 downto 0) = "00000000") then
    -- Case of LM with all zeros in input
    npc_enable := '1';
    np1_enable := '1';
  elsif (op_code = "0110" and pl_input_zero = '1') then
    -- LM execution has finished
    npc_enable := '1';
    np1_enable := '1';
  elsif (op_code = "0110" and pl_input_zero = '0') then
    -- LM execution in progress
    npc_enable := '0';
    np1_enable := '0';
  else
    npc_enable := '1';
    np1_enable := '1';
  end if;

  if reset = '1' then
    pc_enable <= '1';
    p1_enable <= '1';
  else
    pc_enable <= npc_enable;
    p1_enable <= np1_enable;
  end if;

end process;
end Struct;