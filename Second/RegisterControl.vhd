library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity RegisterControl is
  port (
    instruction: in std_logic_vector(15 downto 0);
    pl_input_zero: in std_logic;
    load5_read4: in std_logic;
    kill_stage1: in std_logic;
    kill_stage2: in std_logic;
    kill_stage3: in std_logic;
    kill_stage4: in std_logic;
    pc_enable: out std_logic;
    p1_enable: out std_logic;
    p2_enable: out std_logic;
    p3_enable: out std_logic;
    p4_enable: out std_logic;
    p5_enable: out std_logic;
    reset: in std_logic
  );
end entity RegisterControl;

architecture Struct of RegisterControl is
  signal op_code: std_logic_vector(3 downto 0);
  signal enable_signals: std_logic_vector(5 downto 0) := (others => '1');
begin

op_code <= instruction(15 downto 12);

-- Decision for enable_signals(0)
process(instruction, op_code, pl_input_zero, reset)
variable n_enable0: std_logic;
begin
  n_enable0 := '1';
  if reset = '1' then
    enable_signals(0) <= '1';
  else
    enable_signals(0) <= n_enable0;
  end if;
end process;

-- Decision for enable_signals(1)
process(instruction, op_code, pl_input_zero, reset)
variable n_enable1: std_logic;
begin
  n_enable1 := '1';
  if (op_code = "0110" and instruction(7 downto 0) = "00000000") then
    -- Case of LM with all zeros in input
    n_enable1 := '1';
  elsif (op_code = "0111" and instruction(7 downto 0) = "00000000") then
    -- Case of SM with all zeros in input
    n_enable1 := '1';
  elsif (op_code = "0110" and pl_input_zero = '1') then
    -- LM execution has finished
    n_enable1 := '1';
  elsif (op_code = "0111" and pl_input_zero = '1') then
    -- SM execution has finished
    n_enable1 := '1';
  elsif (op_code = "0110" and pl_input_zero = '0') then
    -- LM execution in progress
    n_enable1 := '0';
  elsif (op_code = "0111" and pl_input_zero = '0') then
    -- SM execution in progress
    n_enable1 := '0';
  else
    n_enable1 := '1';
  end if;
  if reset = '1' then
    enable_signals(1) <= '1';
  else
    enable_signals(1) <= n_enable1;
  end if;
end process;

-- Decision for enable_signals(2)
process(instruction, op_code, pl_input_zero, reset)
variable n_enable2: std_logic;
begin
  n_enable2 := '1';
  if reset = '1' then
    enable_signals(2) <= '1';
  else
    enable_signals(2) <= n_enable2;
  end if;
end process;

-- Decision for enable_signals(3)
process(instruction, op_code, pl_input_zero, load5_read4, reset)
variable n_enable3: std_logic;
begin
  n_enable3 := '1';
  if (load5_read4 = '1') then
    n_enable3 := '0';
  else
    n_enable3 := '1';
  end if;
  if reset = '1' then
    enable_signals(3) <= '1';
  else
    enable_signals(3) <= n_enable3;
  end if;
end process;

-- Decision for enable_signals(4)
process(instruction, op_code, pl_input_zero, reset)
variable n_enable4: std_logic;
begin
  n_enable4 := '1';
  if reset = '1' then
    enable_signals(4) <= '1';
  else
    enable_signals(4) <= n_enable4;
  end if;
end process;

-- Decision for enable_signals(5)
process(instruction, op_code, pl_input_zero, reset)
variable n_enable5: std_logic;
begin
  n_enable5 := '1';
  if reset = '1' then
    enable_signals(5) <= '1';
  else
    enable_signals(5) <= n_enable5;
  end if;
end process;


process(enable_signals, kill_stage1, kill_stage2, kill_stage3, kill_stage4, reset)
  variable npc_enable: std_logic;
  variable np1_enable: std_logic;
  variable np2_enable: std_logic;
  variable np3_enable: std_logic;
  variable np4_enable: std_logic;
  variable np5_enable: std_logic;
begin
  npc_enable := '0';
  np1_enable := '0';
  np2_enable := '0';
  np3_enable := '0';
  np4_enable := '0';
  np5_enable := '0';
  if enable_signals(5) = '0' then
    npc_enable := '0';
    np1_enable := '0';
    np2_enable := '0';
    np3_enable := '0';
    np4_enable := '0';
    np5_enable := '0';
  elsif enable_signals(4) = '0' then
    npc_enable := '0';
    np1_enable := '0';
    np2_enable := '0';
    np3_enable := '0';
    np4_enable := '0';
    np5_enable := '1';
  elsif enable_signals(3) = '0' then
    npc_enable := '0';
    np1_enable := '0';
    np2_enable := '0';
    np3_enable := '0';
    np4_enable := '1';
    np5_enable := '1';
  elsif enable_signals(2) = '0' then
    npc_enable := '0';
    np1_enable := '0';
    np2_enable := '0';
    np3_enable := '1';
    np4_enable := '1';
    np5_enable := '1';
  elsif enable_signals(1) = '0' then
    npc_enable := '0';
    np1_enable := '0';
    np2_enable := '1';
    np3_enable := '1';
    np4_enable := '1';
    np5_enable := '1';
  elsif enable_signals(0) = '0' then
    npc_enable := '0';
    np1_enable := '1';
    np2_enable := '1';
    np3_enable := '1';
    np4_enable := '1';
    np5_enable := '1';
  else
    npc_enable := '1';
    np1_enable := '1';
    np2_enable := '1';
    np3_enable := '1';
    np4_enable := '1';
    np5_enable := '1';
  end if;

  if kill_stage1 = '1' then
    npc_enable := '1';
  end if;

  if kill_stage2 = '1' then
    np1_enable := '1';
  end if;

  if kill_stage3 = '1' then
    np2_enable := '1';
  end if;

  if kill_stage4 = '1' then
    np3_enable := '1';
  end if;

  if reset = '1' then
    pc_enable <= '1';
    p1_enable <= '1';
    p2_enable <= '1';
    p3_enable <= '1';
    p4_enable <= '1';
    p5_enable <= '1';
  else
    pc_enable <= npc_enable;
    p1_enable <= np1_enable;
    p2_enable <= np2_enable;
    p3_enable <= np3_enable;
    p4_enable <= np4_enable;
    p5_enable <= np5_enable;
  end if;
end process;

end Struct;
