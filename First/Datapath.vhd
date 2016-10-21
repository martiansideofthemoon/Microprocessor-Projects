library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Datapath is
  port (
    inst_write, mem_write, memreg_write: in std_logic;
    pc_write, reg_write, t1_write, t2_write: in std_logic;
    alu_op, alureg_write: in std_logic;
    pc_in_select: in std_logic;
    alu_op_select: in std_logic;
    alu1_select: in std_logic_vector(1 downto 0);
    alu2_select: in std_logic_vector(2 downto 0);
    addr_select: in std_logic_vector(1 downto 0);
    regread2_select: in std_logic;
    regdata_select: in std_logic_vector(1 downto 0);
    regwrite_select: in std_logic_vector(1 downto 0);
    set_carry, set_zero: in std_logic;
    pl_select: in std_logic;
    active: out std_logic;
    plinput_zero: out std_logic;
    inst_type: out OperationCode;
    zero_flag: out std_logic;
    clk, reset: in std_logic
  );
end entity;

architecture Mixed of Datapath is
  -- Constants
  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_2: std_logic_vector(15 downto 0) := (1 => '1', others => '0');

  -- Instruction Register signals
  signal INSTRUCTION: std_logic_vector(15 downto 0);
  signal INST_ALU: std_logic;

  -- Memory signals
  signal ADDRESS_in: std_logic_vector(15 downto 0);
  signal MEMDATA_in: std_logic_vector(15 downto 0);
  signal MEM_out: std_logic_vector(15 downto 0);

  -- Memory Register (T4)
  signal MEMREG_out: std_logic_vector(15 downto 0);

  -- Register File signals
  signal PC_in: std_logic_vector(15 downto 0);
  signal PC_out: std_logic_vector(15 downto 0);
  signal DATA1: std_logic_vector(15 downto 0);
  signal DATA2: std_logic_vector(15 downto 0);
  signal READ1: std_logic_vector(2 downto 0);
  signal READ2: std_logic_vector(2 downto 0);
  signal WRITE3: std_logic_vector(2 downto 0);
  signal REGDATA_in: std_logic_vector(15 downto 0);

  -- Zero Pad / Left Shift / Sign Extender signals
  signal ZERO_PAD9: std_logic_vector(15 downto 0);
  signal LEFT_SHIFT6: std_logic_vector(15 downto 0);
  signal SE6_out: std_logic_vector(15 downto 0);
  signal SE9_out: std_logic_vector(15 downto 0);

  -- Register File Temp Registers (T1, T2)
  signal T1_out: std_logic_vector(15 downto 0);
  signal T2_out: std_logic_vector(15 downto 0);

  -- ALU signals
  signal ALU1_in: std_logic_vector(15 downto 0);
  signal ALU2_in: std_logic_vector(15 downto 0);
  signal ALU_out: std_logic_vector(15 downto 0);
  signal ALU_carry: std_logic;
  signal ALU_zero: std_logic;
  signal ALU_opcode: std_logic;

  -- ALU Register (T3)
  signal ALUREG_out: std_logic_vector(15 downto 0);

  -- Flag Register
  signal CARRY_in: std_logic_vector(0 downto 0);
  signal ZERO_in: std_logic_vector(0 downto 0);
  signal CARRY: std_logic_vector(0 downto 0);
  signal ZERO: std_logic_vector(0 downto 0);

  -- Priority Loop Registers
  signal PL_INPUT: std_logic_vector(7 downto 0);
  signal PL_OUTPUT: std_logic_vector(2 downto 0);

begin
  -- ALU Dataflow logic
  ALU1_in <= PC_out when alu1_select = "00" else
             T1_out when alu1_select = "01" else
             ALUREG_out when alu1_select = "10" else
             CONST_0;
  ALU2_in <= CONST_2 when alu2_select = "000" else
             T2_out when alu2_select = "001" else
             SE6_out when alu2_select = "010" else
             SE9_out when alu2_select = "011" else
             LEFT_SHIFT6 when alu2_select = "100" else
             CONST_0;

  ALU_opcode <= alu_op when alu_op_select = '0' else
                INST_ALU when alu_op_select = '1';

  -- Memory Dataflow logic
  ADDRESS_in <= PC_out when addr_select = "00" else
                ALU_out when addr_select = "01" else
                T1_out when addr_select = "10" else
                CONST_0;
  MEMDATA_in <= T2_out;

  -- Program Counter Dataflow logic
  PC_in <= ALU_out when pc_in_select = '0' else
           T2_out;

  -- Register File Dataflow
  READ1 <= INSTRUCTION(8 downto 6);
  READ2 <= INSTRUCTION(11 downto 9) when regread2_select = '0' else
           PL_OUTPUT;
  WRITE3 <= INSTRUCTION(5 downto 3) when regwrite_select = "00" else
            INSTRUCTION(11 downto 9) when regwrite_select = "01";
  REGDATA_in <= ALUREG_out when regdata_select = "00" else
                MEMREG_out when regdata_select = "01" else
                ZERO_PAD9 when regdata_select = "10" else
                PC_out when regdata_select = "11";

  -- Flags data flow logic
  zero_flag <= ZERO(0);
  CARRY_in <= ALU_carry;
  ZERO_in <= ALU_zero;

  -- Priority Loop data flow logic
  PL_INPUT <= INSTRUCTION(7 downto 0);

  -- Instruction Register and Decoder Port Maps
  IR: DataRegister
      generic map (data_width => 15)
      port map (
        Din => MEM_out,
        Dout => INSTRUCTION,
        Enable => inst_write,
        clk => clk
      );
  ID: InstructionDecoder
      port map (
        op_code => INSTRUCTION(15 downto 12),
        output => inst_type,
        alu_out => INST_ALU
      );
  AD: ActiveDecoder
      port map (
        instruction => INSTRUCTION(1 downto 0),
        carry => CARRY(0),
        zero => ZERO(0),
        active => active
      );

  -- Register File port maps
  RF: RegisterFile
      port map (
        clk => clk,
        PC_in => PC_in,
        PC_out => PC_out,
        PC_write => pc_write,
        dout1 => DATA1,
        dout2 => DATA2,
        readA1 => READ1,
        readA2 => READ2,
        writeA3 => WRITE3,
        register_write => reg_write,
        din => REGDATA_in
      );
  T1: DataRegister
      generic map (data_width => 15)
      port map (
        Din => DATA1,
        Dout => T1_out,
        Enable => t1_write,
        clk => clk
      );
  T2: DataRegister
      generic map (data_width => 15)
      port map (
        Din => DATA2,
        Dout => T2_out,
        Enable => t2_write,
        clk => clk
      );
  PAD: LSBZeroPad
       port map (
         input => INSTRUCTION(8 downto 0),
         output => ZERO_PAD9
       );

  -- Memory Port Maps
  ME: Memory
      port map (
        clk => clk,
        mem_write => mem_write,
        addr => ADDRESS_in,
        data => MEMDATA_in,
        mem_out => MEM_out
      );
  T4: DataRegister
      generic map (data_width => 15)
      port map (
        Din => MEM_out,
        Dout => MEMREG_out,
        Enable => memreg_write,
        clk => clk
      );

  -- ALU Port Maps
  SE: SignExtender6
      port map (
        input => INSTRUCTION(5 downto 0),
        output => SE6_out
      );
  SE9: SignExtender9
       port map (
         input => INSTRUCTION(8 downto 0),
         output => SE9_out
       );
  LS: LeftShift
      port map (
        input => SE6_out,
        output => LEFT_SHIFT6
      );

  AL: ALU
      port map (
        alu_in_1 => ALU1_in,
        alu_in_2 => ALU2_in,
        op_in => ALU_opcode,
        alu_out => ALU_out,
        carry => ALU_carry,
        zero => ALU_zero
      );
  T3: DataRegister
      generic map (data_width => 15)
      port map (
        Din => ALU_out,
        Dout => ALUREG_out,
        Enable => alureg_write,
        clk => clk
      );
  CR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => CARRY_in,
        Dout => CARRY,
        Enable => set_carry,
        clk => clk
      );
  ZR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => ZERO_in,
        Dout => ZERO,
        Enable => set_zero,
        clk => clk
      );

  PL: PriorityLoop
      port map (
        input => PL_INPUT,
        priority_select => pl_select,
        clock => clk,
        input_zero => plinput_zero,
        output => PL_OUTPUT
      );

end Mixed;