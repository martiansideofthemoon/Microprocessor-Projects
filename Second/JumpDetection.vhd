library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity JumpExecuteStage is
  port (
    op_code: in std_logic_vector(3 downto 0);
    carry_logic: in std_logic_vector(1 downto 0);
    cache_data: in std_logic_vector(21 downto 0);
    cache_prediction: in std_logic_vector(15 downto 0);
    alu_output: in std_logic_vector(15 downto 0);
    flag_condition: in std_logic;
    reset: in std_logic;
    jump: out std_logic;
    jump_address: out std_logic_vector(15 downto 0);
    cache_write: out std_logic;
    cache_history: out std_logic;
    cache_addr: out std_logic_vector(15 downto 0)
  );
end entity;

architecture Struct of JumpExecuteStage is
signal is_jump: std_logic;
signal jump_stage: std_logic_vector(2 downto 0);
signal pc_hit: std_logic;
signal pc_addr: std_logic_vector(15 downto 0);
signal pc_history: std_logic;
begin
is_jump <= cache_data(18);
jump_stage <= cache_data(21 downto 19);
pc_addr <= cache_prediction(15 downto 0);
pc_hit <= cache_data(17);
pc_history <= cache_data(16);
-- Process to determine state of jump signals
process(op_code, alu_output, is_jump, jump_stage, carry_logic, flag_condition, reset)
variable njump: std_logic;
variable njump_address: std_logic_vector(15 downto 0);
begin
  njump := '0';
  njump_address := (others => '0');
  if (is_jump = '0' or jump_stage /= "100") then
    -- This jump doesn't belong here / is not even a jump
    njump := '0';
    njump_address := (others => '0');
  else
    if (op_code = "0000" and carry_logic = "00") then
      -- Add instruction with writeA3 = R7
      njump := '1';
      njump_address := alu_output;
    else
      njump := '0';
      njump_address := (others => '0');
    end if;
  end if;
  if (reset = '1') then
    jump <= '0';
    jump_address <= (others => '0');
  else
    jump <= njump;
    jump_address <= njump_address;
  end if;
end process;
-- Process to determine state of cache
process(op_code, cache_data, alu_output, is_jump, jump_stage, carry_logic, flag_condition,
        pc_addr, pc_hit, pc_history, reset)
variable ncache_write: std_logic;
variable ncache_addr: std_logic_vector(15 downto 0);
variable ncache_history: std_logic;
begin
  ncache_history := '0';
  ncache_addr := (others => '0');
  ncache_history := '0';
  if (is_jump = '0' or jump_stage /= "100") then
    -- This jump doesn't belong here / is not even a jump
    ncache_write := '0';
    ncache_addr := (others => '0');
    ncache_history := '0';
  else
    if (op_code = "0000" and carry_logic = "00") then
      -- Add instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = alu_output) then
      -- This is the case of a successful hit
        ncache_write := '0';
        ncache_addr := (others => '0');
        ncache_history := '0';
      else
        ncache_write := '1';
        ncache_addr := alu_output;
        ncache_history := '1';
      end if;
    else
      ncache_write := '0';
      ncache_addr := (others => '0');
      ncache_history := '0';
    end if;
  end if;
  if (reset = '1') then
    cache_write <= '0';
    cache_addr <= (others => '0');
    cache_history <= '0';
  else
    cache_write <= ncache_write;
    cache_addr <= ncache_addr;
    cache_history <= ncache_history;
  end if;
end process;
end Struct;