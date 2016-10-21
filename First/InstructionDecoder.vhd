library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity InstructionDecoder is
  port (
    op_code: in std_logic_vector(3 downto 0);
    output: out OperationCode;
    alu_op: out std_logic;
    alu_carry: out std_logic;
    alu_zero: out std_logic
  );
end entity InstructionDecoder;

architecture Struct of InstructionDecoder is
begin
  process(op_code)
  variable nalu_op: std_logic := '0';
  variable nalu_carry: std_logic := '0';
  variable nalu_zero: std_logic := '0';
  begin
    if (op_code = "0000" or op_code = "0001") then
      nalu_op := '0';
      nalu_carry := '1';
      nalu_zero := '1';
    elsif (op_code = "0010" or op_code = "0100") then
      nalu_op := '1';
      nalu_carry := '0';
      nalu_zero := '1';
    else
      nalu_op := '0';
      nalu_carry := '0';
      nalu_zero := '0';
    end if;
    alu_op <= nalu_op;
    alu_carry <= nalu_carry;
    alu_zero <= nalu_zero;
  end process;
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
