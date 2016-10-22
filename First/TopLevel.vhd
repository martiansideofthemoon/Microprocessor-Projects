library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity TopLevel is
  port (
    clk, reset: in std_logic;
    -- Data coming from outside
    external_addr: in std_logic_vector(15 downto 0);
    external_data: in std_logic_vector(15 downto 0);
    external_mem_write: in std_logic
  );
end entity TopLevel;

architecture Struct of TopLevel is
  -- Instruction Register write
  signal inst_write: std_logic;

  -- Program counter write / select
  signal pc_write: std_logic;
  signal pc_in_select: std_logic_vector(1 downto 0);

  -- Select the two ALU inputs / op_code
  signal alu_op: std_logic;
  signal alu_op_select: std_logic;
  signal alu1_select: std_logic_vector(2 downto 0);
  signal alu2_select: std_logic_vector(2 downto 0);
  signal alureg_write: std_logic;

  -- Select the correct inputs to memory
  signal addr_select: std_logic_vector(1 downto 0);
  signal mem_write: std_logic;
  signal memreg_write: std_logic;

  -- Choices for Register file
  signal regread2_select: std_logic;
  signal regdata_select: std_logic_vector(1 downto 0);
  signal regwrite_select: std_logic_vector(1 downto 0);
  signal reg_write: std_logic;
  signal t1_write: std_logic;
  signal t2_write: std_logic;

  -- Control signals which decide whether or not to set carry flag
  signal set_carry: std_logic;
  signal set_zero: std_logic;
  signal carry_enable_select: std_logic;
  signal zero_enable_select: std_logic;

  -- Choice between input register and feedback
  signal pl_select: std_logic;

  -- Active signal, if high ADC / ADZ / NDC / NDZ executed
  signal active: std_logic;

  -- Returns whether priority loop input is zero or not
  signal plinput_zero: std_logic;

  -- Used to transition from S2
  signal inst_type: OperationCode;

  -- zero flag which is useful for BEQ control
  signal zero_flag: std_logic;

  -- Tells you whether PC will be updated in this instruction
  signal pc_updated: std_logic;
begin

CP: Controller
    port map (
    inst_write => inst_write,
    pc_write => pc_write,
    pc_in_select => pc_in_select,
    alu_op => alu_op,
    alu_op_select => alu_op_select,
    alu1_select => alu1_select,
    alu2_select => alu2_select,
    alureg_write => alureg_write,
    addr_select => addr_select,
    mem_write => mem_write,
    memreg_write => memreg_write,
    regread2_select => regread2_select,
    regdata_select => regdata_select,
    regwrite_select => regwrite_select,
    reg_write => reg_write,
    t1_write => t1_write,
    t2_write => t2_write,
    set_carry => set_carry,
    set_zero => set_zero,
    carry_enable_select => carry_enable_select,
    zero_enable_select => zero_enable_select,
    pl_select => pl_select,
    active => active,
    plinput_zero => plinput_zero,
    inst_type => inst_type,
    zero_flag => zero_flag,
    pc_updated => pc_updated,
    clk => clk,
    reset => reset
    );
DP: Datapath
    port map (
    inst_write => inst_write,
    pc_write => pc_write,
    pc_in_select => pc_in_select,
    alu_op => alu_op,
    alu_op_select => alu_op_select,
    alu1_select => alu1_select,
    alu2_select => alu2_select,
    alureg_write => alureg_write,
    addr_select => addr_select,
    mem_write => mem_write,
    memreg_write => memreg_write,
    regread2_select => regread2_select,
    regdata_select => regdata_select,
    regwrite_select => regwrite_select,
    reg_write => reg_write,
    t1_write => t1_write,
    t2_write => t2_write,
    set_carry => set_carry,
    set_zero => set_zero,
    carry_enable_select => carry_enable_select,
    zero_enable_select => zero_enable_select,
    pl_select => pl_select,
    active => active,
    plinput_zero => plinput_zero,
    inst_type => inst_type,
    zero_flag => zero_flag,
    pc_updated => pc_updated,
    clk => clk,
    reset => reset,
    external_addr => external_addr,
    external_data => external_data,
    external_mem_write => external_mem_write
    );
end Struct;