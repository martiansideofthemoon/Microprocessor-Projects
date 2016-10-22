library std;
library ieee;
use ieee.std_logic_1164.all;

package ProcessorComponents is

  type OperationCode is (NONE, R_TYPE, LW, SW, ADI, LHI, LM, SM, BEQ, JAL, JLR);

  component ClockDivider is
  port (
    clk, reset: in std_logic;
    clk_slow: out std_logic
  );
  end component;
  component ClockDividerControl is
  port (
    T0, T1: out std_logic;
    S: in std_logic;
    clk, reset: in std_logic;
    clk_slow: out std_logic
  );
  end component;
  component ClockDividerData is
  port (
    T0, T1: in std_logic;
    S: out std_logic;
    clk, reset: in std_logic
  );
  end component;

  component DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable: in std_logic);
  end component DataRegister;

  component PriorityEncoder is
  port (
    din: in std_logic_vector(7 downto 0);
    dout: out std_logic_vector(2 downto 0)
  );
  end component PriorityEncoder;

  component Demux is
  port (
    din: in std_logic_vector(2 downto 0);
    dout: out std_logic_vector(7 downto 0)
  );
  end component Demux;

  component PriorityLoop is
  port (
    input: in std_logic_vector(7 downto 0);
    priority_select, clock: in std_logic;
    input_zero: out std_logic;
    output: out std_logic_vector(2 downto 0)
  );
  end component PriorityLoop;

  component SignExtender9 is
  port (
    input: in std_logic_vector(8 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component SignExtender9;

  component SignExtender6 is
  port (
    input: in std_logic_vector(5 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component SignExtender6;

  component TwosComplement is
  port (
    input: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component TwosComplement;

  component LSBZeroPad is
  port (
    input: in std_logic_vector(8 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component LSBZeroPad;

  component LeftShift is
  port (
    input: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component LeftShift;

  component ActiveDecoder is
  port (
    instruction: in std_logic_vector(1 downto 0);
    carry: in std_logic;
    zero: in std_logic;
    active: out std_logic
  );
  end component ActiveDecoder;

 component RegisterFile is
  port (
    dout1        : out std_logic_vector(15 downto 0);
    dout2        : out std_logic_vector(15 downto 0);
    din          : in  std_logic_vector(15 downto 0);
    register_write : in  std_logic;
    readA1       : in  std_logic_vector(2 downto 0);
    readA2       : in  std_logic_vector(2 downto 0);
    writeA3      : in  std_logic_vector(2 downto 0);
    PC_write     : in  std_logic;
    PC_in        : in std_logic_vector(15 downto 0);
    PC_out       : out  std_logic_vector(15 downto 0);
    clk          : in  std_logic
  );
  end component RegisterFile;

  component Memory is
  port (
    mem_out      : out std_logic_vector(15 downto 0);
    data         : in std_logic_vector(15 downto 0);
    addr         : in  std_logic_vector(15 downto 0);
    mem_write    : in  std_logic;
    clk          : in  std_logic
  );
  end component;

 component ALU is
  port (
    alu_in_1, alu_in_2: in std_logic_vector(15 downto 0);
    op_in: in std_logic;
    alu_out: out std_logic_vector(15 downto 0);
    carry: out std_logic;
    zero: out std_logic);
  end component ALU;

  component InstructionDecoder is
  port (
    instruction: in std_logic_vector(15 downto 0);
    output: out OperationCode;
    alu_op: out std_logic;
    alu_carry: out std_logic;
    alu_zero: out std_logic;
    pc_updated: out std_logic
  );
  end component InstructionDecoder;

  component Datapath is
  port (
    -- Instruction Register write
    inst_write: in std_logic;

    -- Program counter write / select
    pc_write: in std_logic;
    pc_in_select: in std_logic_vector(1 downto 0);

    -- Select the two ALU inputs / op_code
    alu_op: in std_logic;
    alu_op_select: in std_logic;
    alu1_select: in std_logic_vector(1 downto 0);
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

    -- zero flag which is useful for BEQ control
    zero_flag: out std_logic;

    -- Tells you whether PC will be updated in this instruction
    pc_updated: out std_logic;

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic;

    -- Data coming from outside
    external_addr: in std_logic_vector(15 downto 0);
    external_data: in std_logic_vector(15 downto 0);
    external_mem_write: in std_logic
  );
  end component;

  component Controller is
  port (
    -- Instruction Register write
    inst_write: out std_logic;

    -- Program counter write / select
    pc_write: out std_logic;
    pc_in_select: out std_logic_vector(1 downto 0);

    -- Select the two ALU inputs / op_code
    alu_op: out std_logic;
    alu_op_select: out std_logic;
    alu1_select: out std_logic_vector(1 downto 0);
    alu2_select: out std_logic_vector(2 downto 0);
    alureg_write: out std_logic;

    -- Select the correct inputs to memory
    addr_select: out std_logic_vector(1 downto 0);
    mem_write: out std_logic;
    memreg_write: out std_logic;

    -- Choices for Register file
    regread2_select: out std_logic;
    regdata_select: out std_logic_vector(1 downto 0);
    regwrite_select: out std_logic_vector(1 downto 0);
    reg_write: out std_logic;
    t1_write, t2_write: out std_logic;

    -- Control signals which decide whether or not to set carry flag
    set_carry, set_zero: out std_logic;
    carry_enable_select, zero_enable_select: out std_logic;

    -- Choice between input register and feedback
    pl_select: out std_logic;

    -- Active signal, if high ADC / ADZ / NDC / NDZ executed
    active: in std_logic;

    -- Returns whether priority loop input is zero or not
    plinput_zero: in std_logic;

    -- Used to transition from S2
    inst_type: in OperationCode;

    -- zero flag which is useful for BEQ control
    zero_flag: in std_logic;

    -- Tells you whether PC will be updated in this instruction
    pc_updated: in std_logic;

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic
  );
  end component;

  component TopLevel is
    port (
      clk, reset: in std_logic;
      -- Data coming from outside
      external_addr: in std_logic_vector(15 downto 0);
      external_data: in std_logic_vector(15 downto 0);
      external_mem_write: in std_logic
    );
  end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
entity DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
  process(clk)
  begin
    if(clk'event and (clk  = '1')) then
      if(enable = '1') then
        Dout <= Din;
      end if;
    end if;
  end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity SignExtender9 is
port (
  input: in std_logic_vector(8 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity SignExtender9;
architecture Behave of SignExtender9 is
begin
output(8 downto 0) <= input(8 downto 0);
output(9) <= input(8);
output(10) <= input(8);
output(11) <= input(8);
output(12) <= input(8);
output(13) <= input(8);
output(14) <= input(8);
output(15) <= input(8);
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity SignExtender6 is
port (
  input: in std_logic_vector(5 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity SignExtender6;
architecture Behave of SignExtender6 is
begin
output(5 downto 0) <= input(5 downto 0);
output(6) <= input(5);
output(7) <= input(5);
output(8) <= input(5);
output(9) <= input(5);
output(10) <= input(5);
output(11) <= input(5);
output(12) <= input(5);
output(13) <= input(5);
output(14) <= input(5);
output(15) <= input(5);
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity LSBZeroPad is
port (
  input: in std_logic_vector(8 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity LSBZeroPad;
architecture Behave of LSBZeroPad is
begin
output(15 downto 7) <= input(8 downto 0);
output(6 downto 0) <= "0000000";
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity LeftShift is
port (
  input: in std_logic_vector(15 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity LeftShift;
architecture Behave of LeftShift is
begin
output(15 downto 1) <= input(14 downto 0);
output(0) <= '0';
end Behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity TwosComplement is
port (
  input: in std_logic_vector(15 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity TwosComplement;
architecture Behave of TwosComplement is
begin
output <= std_logic_vector(unsigned(not input) + 1);
end Behave;
