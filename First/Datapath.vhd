library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Datapath is
  port (
    -- Instruction Register write
    inst_write: in std_logic;

    -- Program counter write / select
    pc_write: in std_logic;
    pc_in_select: in std_logic_vector(2 downto 0);

    -- Select the two ALU inputs / op_code
    alu_op: in std_logic;
    alu_op_select: in std_logic;
    alu1_select: in std_logic_vector(2 downto 0);
    alu2_select: in std_logic_vector(2 downto 0);
    alureg_write: in std_logic;

    -- Select the correct inputs to memory
    addr_select: in std_logic_vector(1 downto 0);
    mem_write: in std_logic;
    memreg_write: in std_logic;

    -- Choices for Register file
    regread2_select: in std_logic;
    regdata_select: in std_logic_vector(1 downto 0);
    regwrite_select: in std_logic_vector(1 downto 0);
    reg_write: in std_logic;
    t1_write, t2_write: in std_logic;

    -- Control signals which decide whether or not to set carry flag
    set_carry, set_zero: in std_logic;
    carry_enable_select, zero_enable_select: in std_logic;

    -- Choice between input register and feedback
    pl_select: in std_logic;

    -- Active signal, if high ADC / ADZ / NDC / NDZ executed
    active: out std_logic;

    -- Returns whether priority loop input is zero or not
    plinput_zero: out std_logic;

    -- Used to transition from S2
    inst_type: out OperationCode;

    -- choice for input into zero flag
    zero_select: in std_logic;

    -- zero flag which is useful for BEQ control
    zero_flag: out std_logic;

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic;

    -- Tells you whether PC will be updated in this instruction
    pc_updated: out std_logic;

    -- Data coming from outside
    external_addr: in std_logic_vector(15 downto 0);
    external_data: in std_logic_vector(15 downto 0);
    external_mem_write: in std_logic;
    external_pc_out: out std_logic_vector(15 downto 0);
    external_ir: out std_logic_vector(15 downto 0);
    external_r0: out std_logic_vector(15 downto 0);
    external_r1: out std_logic_vector(15 downto 0);
    external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
  );
end entity;

architecture Mixed of Datapath is
  -- Constants
  signal CONST_0: std_logic_vector(15 downto 0) := (others => '0');
  signal CONST_1: std_logic_vector(15 downto 0) := (0 => '1', others => '0');
  signal CONST_32: std_logic_vector(15 downto 0) := (5 => '1', others => '0');

  -- Instruction Register signals
  signal INSTRUCTION: std_logic_vector(15 downto 0) := (others => '0');
  signal INST_ALU: std_logic;
  signal INST_CARRY: std_logic;
  signal INST_ZERO: std_logic;

  -- Memory signals
  signal ADDRESS_in: std_logic_vector(15 downto 0);
  signal LSHIFT_ADDRESS_in: std_logic_vector(15 downto 0);
  signal MEMDATA_in: std_logic_vector(15 downto 0);
  signal MEM_out: std_logic_vector(15 downto 0);
  signal MEMWRITE: std_logic;

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
  signal REGLOAD_zero: std_logic;

  -- Zero Pad / Left Shift / Sign Extender signals
  signal ZERO_PAD9: std_logic_vector(15 downto 0);
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

  -- Twos Complement for BEQ subtraction
  signal TwosCmp_out: std_logic_vector(15 downto 0);

  -- Flag Register
  signal CARRY_in: std_logic_vector(0 downto 0);
  signal ZERO_in: std_logic_vector(0 downto 0);
  signal CARRY: std_logic_vector(0 downto 0);
  signal ZERO: std_logic_vector(0 downto 0);
  signal CARRY_ENABLE: std_logic;
  signal ZERO_ENABLE: std_logic;

  -- Priority Loop Registers
  signal PL_INPUT: std_logic_vector(7 downto 0);
  signal PL_OUTPUT: std_logic_vector(2 downto 0);

begin
  -- External mapping
  external_ir <= INSTRUCTION;
  external_pc_out <= PC_out;
  -- ALU Dataflow logic
  ALU1_in <= PC_out when alu1_select = "000" else
             T1_out when alu1_select = "001" else
             ALUREG_out when alu1_select = "010" else
             SE6_out when alu1_select = "011" else
             CONST_0 when alu1_select = "100" else
             CONST_1 when alu1_select = "101" else
             CONST_32;

  ALU2_in <= CONST_1 when alu2_select = "000" else
             T2_out when alu2_select = "001" else
             SE6_out when alu2_select = "010" else
             SE9_out when alu2_select = "011" else
             TwosCmp_out when alu2_select = "101" else
             CONST_32;

  ALU_opcode <= alu_op when alu_op_select = '0' else
                INST_ALU when alu_op_select = '1';

  -- Memory Dataflow logic
  ADDRESS_in <= external_addr when reset = '1' else
                PC_out when reset = '0' and addr_select = "00" else
                ALUREG_out when reset = '0' and addr_select = "01" else
                T1_out when reset = '0' and addr_select = "10" else
                T2_out when reset = '0' and addr_select = "11" else
                CONST_0;

  MEMDATA_in <= T2_out when reset = '0' else external_data;
  MEMWRITE <= mem_write when reset = '0' else external_mem_write;

  -- Program Counter Dataflow logic
  PC_in <= CONST_0 when pc_in_select = "000" else
           ALU_out when pc_in_select = "001" else
           T1_out when pc_in_select = "010" else
           T2_out when pc_in_select = "011" else
           ALUREG_out when pc_in_select = "100"else
           CONST_32;

  -- Register File Dataflow
  READ1 <= INSTRUCTION(8 downto 6);
  READ2 <= INSTRUCTION(11 downto 9) when regread2_select = '0' else
           PL_OUTPUT;
  WRITE3 <= INSTRUCTION(5 downto 3) when regwrite_select = "00" else
            INSTRUCTION(11 downto 9) when regwrite_select = "01" else
            INSTRUCTION(8 downto 6) when regwrite_select = "10" else
            PL_OUTPUT when regwrite_select = "11" else
            "000";
  REGDATA_in <= ALUREG_out when regdata_select = "00" else
                MEMREG_out when regdata_select = "01" else
                ZERO_PAD9 when regdata_select = "10" else
                PC_out when regdata_select = "11" else
                CONST_0;

  -- Flags data flow logic
  zero_flag <= ALU_zero;
  CARRY_in(0) <= ALU_carry;
  ZERO_in(0) <= ALU_zero when zero_select = '0' else REGLOAD_zero;
  CARRY_ENABLE <= INST_CARRY when carry_enable_select = '1' else set_carry;
  ZERO_ENABLE <= INST_ZERO when zero_enable_select = '1' else set_zero;

  -- Priority Loop data flow logic
  PL_INPUT <= INSTRUCTION(7 downto 0);

  -- Instruction Register and Decoder Port Maps
  IR: DataRegister
      generic map (data_width => 16)
      port map (
        Din => MEM_out,
        Dout => INSTRUCTION,
        Enable => inst_write,
        clk => clk
      );
  ID: InstructionDecoder
      port map (
        instruction => INSTRUCTION,
        output => inst_type,
        alu_op => INST_ALU,
        alu_carry => INST_CARRY,
        alu_zero => INST_ZERO,
        pc_updated => pc_updated
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
        din => REGDATA_in,
        zero => REGLOAD_zero,
        external_r0 => external_r0,
        external_r1 => external_r1,
        external_r2 => external_r2,
        external_r3 => external_r3,
        external_r4 => external_r4,
        external_r5 => external_r5,
        external_r6 => external_r6
      );
  T1: DataRegister
      generic map (data_width => 16)
      port map (
        Din => DATA1,
        Dout => T1_out,
        Enable => t1_write,
        clk => clk
      );
  T2: DataRegister
      generic map (data_width => 16)
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
        mem_write => MEMWRITE,
        addr => LSHIFT_ADDRESS_in,
        data => MEMDATA_in,
        mem_out => MEM_out
      );
  T4: DataRegister
      generic map (data_width => 16)
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
        input => ADDRESS_in,
        output => LSHIFT_ADDRESS_in
      );
  TwoCmp: TwosComplement
      port map (
        input => T2_out,
        output => TwosCmp_out
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
      generic map (data_width => 16)
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
        Enable => CARRY_ENABLE,
        clk => clk
      );
  ZR: DataRegister
      generic map (data_width => 1)
      port map (
        Din => ZERO_in,
        Dout => ZERO,
        Enable => ZERO_ENABLE,
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