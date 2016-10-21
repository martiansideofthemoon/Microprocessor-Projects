library std;
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity Controller is
  port (
    -- Instruction Register write
    inst_write: out std_logic;

    -- Program counter write / select
    pc_write: out std_logic;
    pc_in_select: out std_logic;

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

    -- clock and reset pins, if reset is high, external memory signals
    -- active.
    clk, reset: in std_logic
  );
end entity;
architecture Struct of Controller is
  type FsmState is (S0, S1, S2, S3);
  signal state: FsmState;
begin

  -- Next state process
  process(clk, reset, active, inst_type)
    variable nstate: FsmState;
  begin
    nstate := S0;
    case state is
      when S0 =>
        nstate := S1;
      when S1 =>
        nstate := S2;
      when S2 =>
        if inst_type = R_TYPE then
          nstate := S3;
        else
          nstate := S1;
        end if;
      when S3 =>
        nstate := S0;
    end case;

    if(clk'event and clk = '1') then
      if(reset = '1') then
        state <= S0;
      else
        state <= nstate;
      end if;
    end if;
  end process;

  -- Control Signal process

end Struct;