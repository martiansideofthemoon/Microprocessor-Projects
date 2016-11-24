library std;
library ieee;
use ieee.std_logic_1164.all;

package ProcessorComponents is

  type OperationCode is (NONE, R_TYPE, LW, SW, ADI, LHI, LM, SM, BEQ, JAL, JLR);
  constant DecodeSize: Integer := 36;

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

  component KillInstruction is
  port (Decode_in: in std_logic_vector(DecodeSize-1 downto 0);
        Decode_out: out std_logic_vector(DecodeSize-1 downto 0)
        );
  end component;

  component KillStallInstruction is
  port (Decode_in: in std_logic_vector(DecodeSize-1 downto 0);
        Decode_out: out std_logic_vector(DecodeSize-1 downto 0)
        );
  end component;

  component DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable, reset: in std_logic);
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
    priority_select, clock, reset: in std_logic;
    input_zero: out std_logic;
    offset: out std_logic_vector(15 downto 0);
    output: out std_logic_vector(2 downto 0);
    pl_enable: in std_logic
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

  component Increment is
  port (
    input: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component Increment;

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
    clk          : in  std_logic;
    zero         : out std_logic;
    external_r0: out std_logic_vector(15 downto 0);
    external_r1: out std_logic_vector(15 downto 0);
    external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
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
    output: out std_logic_vector(DecodeSize-1 downto 0);
    jump_output: out std_logic_vector(3 downto 0);
    reset: in std_logic
  );
  end component;

  component Datapath is
  port (
    clk, reset: in std_logic;

    -- Data coming from outside
    external_r0: out std_logic_vector(15 downto 0);
    external_r1: out std_logic_vector(15 downto 0);
    external_r2: out std_logic_vector(15 downto 0);
    external_r3: out std_logic_vector(15 downto 0);
    external_r4: out std_logic_vector(15 downto 0);
    external_r5: out std_logic_vector(15 downto 0);
    external_r6: out std_logic_vector(15 downto 0)
  );
  end component;

  component FlagForwarding is
  port (
    set_carry5: in std_logic;
    set_zero5: in std_logic;
    carry5: in std_logic;
    zero5: in std_logic;
    zero5_load: in std_logic;
    op_code: in std_logic_vector(3 downto 0);
    set_carry6: in std_logic;
    set_zero6: in std_logic;
    carry6: in std_logic;
    zero6: in std_logic;
    carry_forward: out std_logic;
    zero_forward: out std_logic;
    carry_val: out std_logic;
    zero_val: out std_logic;
    reset: in std_logic
  );
  end component FlagForwarding;

  component DataForwarding is
    port (
      -- STAGE 3
      -- stage3 opcode --> 9 downto 6
      -- stage3 regA1 --> 5 downto 3
      -- stage3 regA2 --> 2 downto 0
      stage3_signals: in std_logic_vector(9 downto 0);

      -- STAGE 4
      -- stage4 opcode --> 9 downto 6
      -- stage4 regA1 --> 5 downto 3
      -- stage4 regA2 --> 2 downto 0
      stage4_signals: in std_logic_vector(9 downto 0);

      -- STAGE 5
      -- stage5 reg_write --> 8
      -- stage5 r7_write --> 7
      -- stage5 opcode --> 6 downto 3
      -- stage5 writeA3 --> 2 downto 0
      stage5_signals: in std_logic_vector(8 downto 0);
      -- stage5 r7_data --> 31 downto 16
      -- stage5 regdata_in --> 15 downto 0
      stage5_data: in std_logic_vector(31 downto 0);

      -- STAGE 6
      -- stage6 reg_write --> 4
      -- stage6 r7_write --> 3
      -- stage6 writeA3 --> 2 downto 0
      stage6_signals: in std_logic_vector(4 downto 0);
      -- stage6 r7_data --> 31 downto 16
      -- stage6 regdata_in --> 15 downto 0
      stage6_data: in std_logic_vector(31 downto 0);

      -- Load-Read Distress Signal
      -- Pipeline should be stalled for one cycle
      -- Forwarding will happen when load reaches stage 6
      load5_read4: out std_logic;

      -- Forward to Stage 3
      forward3_regA1: out std_logic;
      forward3_regA2: out std_logic;
      forward3_dataA1: out std_logic_vector(15 downto 0);
      forward3_dataA2: out std_logic_vector(15 downto 0);
      -- Forward to Stage 4
      forward4_regA1: out std_logic;
      forward4_regA2: out std_logic;
      forward4_dataA1: out std_logic_vector(15 downto 0);
      forward4_dataA2: out std_logic_vector(15 downto 0);
      -- Reset Signal
      reset: in std_logic
    );
  end component DataForwarding;

  component RegisterControl is
    port (
      instruction: in std_logic_vector(15 downto 0);
      pl_input_zero: in std_logic;
      load5_read4: in std_logic;
      pc_enable: out std_logic;
      p1_enable: out std_logic;
      p2_enable: out std_logic;
      p3_enable: out std_logic;
      p4_enable: out std_logic;
      p5_enable: out std_logic;
      reset: in std_logic
    );
  end component RegisterControl;

  component Cache is
  port(
    -- Read signals
    target_address: out  std_logic_vector(15 downto 0);
    target_history: out std_logic;
    target_pc: in  std_logic_vector(15 downto 0);
    target_hit: out std_logic;
    clk: in std_logic;
    reset: in std_logic;
    -- Write signals
    write_pc: in std_logic_vector(15 downto 0);
    write_address: in std_logic_vector(15 downto 0);
    write_history: in std_logic;
    cache_write: in std_logic
  );
  end component Cache;

  component PCForwarding is
  port (
    pc_stage3: in std_logic_vector(15 downto 0);
    pc_stage4: in std_logic_vector(15 downto 0);
    pc_stage5: in std_logic_vector(15 downto 0);
    pc_stage3_flag: in std_logic;
    pc_stage4_flag: in std_logic;
    pc_stage5_flag: in std_logic;
    pc_forwarding_out: out std_logic_vector(15 downto 0);
    pc_forwarding: out std_logic;
    kill1 : out std_logic;
    kill2 : out std_logic;
    kill3 : out std_logic;
    kill4 : out std_logic;
    reset: in std_logic
  );
  end component PCForwarding;

  component JumpRegReadStage is
    port (
      op_code: in std_logic_vector(3 downto 0);
      cache_data: in std_logic_vector(21 downto 0);
      cache_prediction: in std_logic_vector(15 downto 0);
      new_pcval: in std_logic_vector(15 downto 0);
      reset: in std_logic;
      jump: out std_logic;
      jump_address: out std_logic_vector(15 downto 0);
      cache_values: out std_logic_vector(17 downto 0)
    );
  end component;

  component JumpExecuteStage is
    port (
      op_code: in std_logic_vector(3 downto 0);
      carry_logic: in std_logic_vector(1 downto 0);
      cache_data: in std_logic_vector(21 downto 0);
      cache_prediction: in std_logic_vector(15 downto 0);
      alu_output: in std_logic_vector(15 downto 0);
      branch_address: in std_logic_vector(15 downto 0);
      flag_condition: in std_logic_vector(1 downto 0);
      writeA3: in std_logic_vector(2 downto 0);
      reset: in std_logic;
      jump: out std_logic;
      jump_address: out std_logic_vector(15 downto 0);
      cache_values: out std_logic_vector(17 downto 0)
    );
  end component;

  component JumpMemStage is
    port (
      op_code: in std_logic_vector(3 downto 0);
      cache_data: in std_logic_vector(21 downto 0);
      cache_prediction: in std_logic_vector(15 downto 0);
      memread: in std_logic_vector(15 downto 0);
      reset: in std_logic;
      jump: out std_logic;
      jump_address: out std_logic_vector(15 downto 0);
      cache_values: out std_logic_vector(17 downto 0)
    );
  end component;

end package;

library ieee;
use ieee.std_logic_1164.all;
entity DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable, reset: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
  process(clk)
  begin
    if (reset = '1') then
      Dout <= (others => '0');
    end if;
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;
entity KillInstruction is
port (
  Decode_in: in std_logic_vector(DecodeSize-1 downto 0);
  Decode_out: out std_logic_vector(DecodeSize-1 downto 0)
);
end entity KillInstruction;
architecture Behave of KillInstruction is
begin
-- Bit 14 set to one as we want R7_write
Decode_out <= (14 => '1', others => '0');

end Behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;
entity KillStallInstruction is
port (
  Decode_in: in std_logic_vector(DecodeSize-1 downto 0);
  Decode_out: out std_logic_vector(DecodeSize-1 downto 0)
);
end entity KillStallInstruction;
architecture Behave of KillStallInstruction is
begin
-- Bit 14 set to one as we want R7_write
Decode_out <= (31 => '1', 30 => '1', 29 => '1', 28 => '1', others => '0');

end Behave;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity Increment is
port (
  input: in std_logic_vector(15 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity Increment;
architecture Behave of Increment is
begin
output <= std_logic_vector(unsigned(input) + 1);
end Behave;
