library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity InstructionDecoder is
  port (
    instruction: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(DecodeSize-1 downto 0);
    jump_output: out std_logic_vector(3 downto 0);
    reset: in std_logic
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
signal r7_increment: std_logic;
signal alu2_select: std_logic_vector(1 downto 0);
signal alu1_select: std_logic_vector(1 downto 0);
signal immediate: std_logic_vector(8 downto 0);
signal reg_write_select: std_logic_vector(1 downto 0);
signal carry_check: std_logic;
signal zero_check: std_logic;
signal is_jump: std_logic;
signal jump_stage: std_logic_vector(2 downto 0) := "000";
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
  r7_increment <= not pc_updated;
  output(14) <= r7_increment;
  output(23 downto 15) <= immediate;
  output(25 downto 24) <= alu2_select;
  output(27 downto 26) <= alu1_select;
  output(31 downto 28) <= op_code;
  output(33 downto 32) <= reg_write_select;
  output(34) <= carry_check;
  output(35) <= zero_check;

  jump_output(0) <= is_jump;
  jump_output(3 downto 1) <= jump_stage(2 downto 0);

  process(instruction, op_code, carry_logic)
    variable npc_updated: std_logic := '0';
    variable nis_jump: std_logic := '0';
  begin
    if (op_code = "0000" and instruction(5 downto 3) = "111") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "0001" and instruction(8 downto 6) = "111") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "0010" and instruction(5 downto 3) = "111") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "0100" and instruction(11 downto 9) = "111") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "0011" and instruction(11 downto 9) = "111") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "0110" and instruction(7) = '1') then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "1100" or op_code = "1000" or op_code = "1001") then
      npc_updated := '1';
      nis_jump := '1';
    elsif (op_code = "1111") then
      npc_updated := '1';
      nis_jump := '0';
    else
      npc_updated := '0';
      nis_jump := '0';
    end if;
    if (reset = '1') then
      pc_updated <= '1';
      is_jump <= '0';
    else
      pc_updated <= npc_updated;
      is_jump <= nis_jump;
    end if;
  end process;

  process(reset, instruction, op_code, carry_logic)
  begin
    if (reset = '0' and op_code = "0000" and carry_logic = "00") then
      -- Generic ADD type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '1';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0000" and carry_logic = "10") then
      -- Generic ADC type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '1';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '1';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0000" and carry_logic = "01") then
      -- Generic ADZ type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '0';
      zero_check <= '1';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '1';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0010" and carry_logic = "00") then
      -- Generic NDU type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '1';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0010" and carry_logic = "10") then
      -- Generic NDC type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '1';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '1';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0010" and carry_logic = "01") then
      -- Generic NDZ type instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= instruction(8 downto 6);
      carry_check <= '0';
      zero_check <= '1';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '1';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '1';
      reg_A3 <= instruction(5 downto 3);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0001") then
      -- Generic ADI instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(11 downto 9);
      reg_A2 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "01";
      alu1_select <= "00";
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '1';
      set_zero <= '1';
      reg_A3 <= instruction(8 downto 6);
      jump_stage <= "100";
    elsif (reset = '0' and op_code = "0011") then
      -- Generic LHI instruction
      -- Signals for Register Read stage
      reg_A1 <= "000";
      reg_A2 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "10";
      alu1_select <= "01";
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= instruction(11 downto 9);
      jump_stage <= "011";
    elsif (reset = '0' and op_code = "0100") then
      -- Generic LW instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(8 downto 6);
      reg_A2 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "01";
      alu1_select <= "00";
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "01";
      set_carry <= '0';
      set_zero <= '1';
      reg_A3 <= instruction(11 downto 9);
      jump_stage <= "101";
    elsif (reset = '0' and op_code = "0101") then
      -- Generic SW instruction
      -- Signals for Register Read stage
      reg_A1 <= instruction(8 downto 6);
      reg_A2 <= instruction(11 downto 9);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "01";
      alu1_select <= "00";
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '1';
      -- Signals for Register Write stage
      reg_write <= '0';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= instruction(11 downto 9);
      jump_stage <= "000";
    elsif (reset = '0' and op_code = "0110") then
      -- Generic LM instruction
      -- Signals for Register Read stage
      reg_A2 <= "000";
      reg_A1 <= instruction(11 downto 9);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "11";
      alu1_select <= "00";
      immediate <= "000000000";
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '1';
      reg_write_select <= "01";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= "000";
      jump_stage <= "101";
    elsif (reset = '0' and op_code = "0111") then
      -- Generic SM instruction
      -- Signals for Register Read stage
      reg_A2 <= "000";
      reg_A1 <= instruction(11 downto 9);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "11";
      alu1_select <= "00";
      immediate <= "000000000";
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '1';
      -- Signals for Register Write stage
      reg_write <= '0';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= "000";
      jump_stage <= "000";
    elsif (reset = '0' and op_code = "1100") then
      -- Generic BEQ instruction
      -- Signals for Register Read stage
      reg_A2 <=instruction(8 downto 6);
      reg_A1 <= instruction(11 downto 9);
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "01"; -- for subtract
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '0';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= "000";
      jump_stage <= "100";
      -- To ensure 2's complement
    elsif (reset = '0' and op_code = "1000") then
      -- Generic JAL instruction
      -- Signals for Register Read stage
      reg_A2 <= "000";
      reg_A1 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00"; -- for subtract
      immediate <= instruction(8 downto 0);
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      if (instruction(11 downto 9) /= "111") then
        reg_write <= '1';
      else
        reg_write <= '0';
      end if;
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= instruction(11 downto 9);
     jump_stage <= "100";
     -- To ensure 2's complement
    elsif (reset = '0' and op_code = "1001") then
      -- Generic JLR instruction
      -- Signals for Register Read stage
      reg_A2 <= instruction(8 downto 6);
      reg_A1 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "10"; -- for add with 0
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      if (instruction(11 downto 9) /= "111") then
        reg_write <= '1';
      else
        reg_write <= '0';
      end if;
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= instruction(11 downto 9);
     jump_stage <= "100";
     -- To ensure 2's complement
    else
      -- Signals for Register Read stage
      reg_A1 <= "000";
      reg_A2 <= "000";
      carry_check <= '0';
      zero_check <= '0';
      alu2_select <= "00";
      alu1_select <= "00";
      immediate <= (others => '0');
      -- Signals for Execute stage
      alu_op <= '0';
      -- Signals for Memory stage
      mem_write <= '0';
      -- Signals for Register Write stage
      reg_write <= '0';
      reg_write_select <= "00";
      set_carry <= '0';
      set_zero <= '0';
      reg_A3 <= "000";
      jump_stage <= "000";
    end if;
  end process;
end Struct;
