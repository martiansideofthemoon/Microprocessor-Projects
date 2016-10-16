library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity InstructionDecoder is
  port (
    op_code: in std_logic_vector(3 downto 0);
    output: out OperationCode
  );
end entity InstructionDecoder;

architecture Struct of InstructionDecoder is
begin
  process(op_code)
  begin
    if (op_code = "0000" or op_code = "0010") then
      output <= R_TYPE;
    elsif (op_code = "0001" or op_code = "0100" or op_code = "0101") then
      output <= I_TYPE;
    elsif (op_code = "0011") then
      output <= LHI;
    elsif (op_code = "0110") then
      output <= LM;
    elsif (op_code = "0111") then
      output <= SM;
    elsif (op_code = "1000") then
      output <= JAL;
    elsif (op_code = "1001") then
      output <= JLR;
    elsif (op_code = "1100") then
      output <= BEQ;
    else
      output <= NONE;
    end if;
  end process;
end Struct;
