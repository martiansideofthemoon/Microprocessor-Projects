library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity InstructionDecoder is
  port (
    instruction: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(11 downto 0)
  );
end entity InstructionDecoder;

architecture Struct of InstructionDecoder is
signal op_code: std_logic_vector(3 downto 0);
signal carry_logic: std_logic_vector(1 downto 0);
begin
  op_code <= instruction(15 downto 12);
  carry_logic <= instruction(1 downto 0);
  process(op_code, carry_logic)
  begin
    if (op_code = "0000" and carry_logic = "00") then
      -- Generic ADD type instruction

      -- Signals for Register Read stage
      output(5 downto 3) <= instruction(11 downto 9);
      output(2 downto 0) <= instruction(8 downto 6);
      -- Signals for Execute stage
      -- ALU_op
      output(6) <= '0';
      -- Signals for Memory stage
      -- mem_write Signal
      output(7) <= '0';
      -- Signals for Register Write
      -- reg_write signal
      output(8) <= '1';
      output(11 downto 9) <= instruction(5 downto 3);
    else
      output <= (others => '0');
    end if;
  end process;
end Struct;
