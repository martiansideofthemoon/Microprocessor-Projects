library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity InstructionDecoder is
  port (
    instruction: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(DecodeSize-1 downto 0)
  );
end entity InstructionDecoder;

architecture Struct of InstructionDecoder is
signal op_code: std_logic_vector(3 downto 0);
signal carry_logic: std_logic_vector(1 downto 0);

signal reg_A1: std_logic_vector(2 downto 0);
signal reg_A2: std_logic_vector(2 downto 0);
signal alu_op: std_logic;
signal mem_write: std_logic;
signal reg_write: std_logic;
signal set_carry: std_logic;
signal set_zero: std_logic;
signal reg_A3: std_logic_vector(2 downto 0);
signal pc_updated: std_logic;
begin
  op_code <= instruction(15 downto 12);
  carry_logic <= instruction(1 downto 0);

  output(2 downto 0) <= reg_A2;
  output(5 downto 3) <= reg_A1;
  output(6) <= alu_op;
  output(7) <= mem_write;
  output(8) <= reg_write;
  output(9) <= set_carry;
  output(10) <= set_zero;
  output(13 downto 11) <= reg_A3;
  output(14) <= pc_updated;

  process(instruction, op_code, carry_logic)
    variable npc_updated: std_logic := '0';
  begin
    if (op_code = "0000" and instruction(5 downto 3) = "111") then
      npc_updated := '1';
    elsif (op_code = "0001" and instruction(8 downto 6) = "111") then
      npc_updated := '1';
    elsif (op_code = "0010" and instruction(5 downto 3) = "111") then
      npc_updated := '1';
    elsif (op_code = "0100" and instruction(11 downto 9) = "111") then
      npc_updated := '1';
    elsif (op_code = "0011" and instruction(11 downto 9) = "111") then
      npc_updated := '1';
    elsif (op_code = "0110" and instruction(7) = '1') then
      npc_updated := '1';
    elsif (op_code = "1100" or op_code = "1000" or op_code = "1001") then
      npc_updated := '1';
    else
      npc_updated := '0';
    end if;
    pc_updated <= npc_updated;
  end process;

  process(instruction, op_code, carry_logic)
  begin
    if (op_code = "0000" and carry_logic = "00") then
      -- Generic ADD type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      set_carry <= '1';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
    elsif (op_code = "0010" and carry_logic = "00") then
      -- Generic NDU type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      -- Signals for Execute stage
      alu_op <= '1';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      set_carry <= '0';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
    else
      -- Signals for Register Read stage
      reg_A1 <= "000";
      reg_A2 <= "000";
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '0';
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= "000";
    end if;
  end process;
end Struct;
