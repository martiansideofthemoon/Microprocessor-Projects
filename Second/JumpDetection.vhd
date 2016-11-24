library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;

-----------------------------------------------------------RegReadStage-----------------------------------------------------------------

entity JumpRegReadStage is
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
end entity;

architecture Struct of JumpRegReadStage is
signal is_jump: std_logic;
signal jump_stage: std_logic_vector(2 downto 0);
signal pc_hit: std_logic;
signal pc_addr: std_logic_vector(15 downto 0);
signal pc_history: std_logic;
signal cache_write: std_logic;
signal cache_addr: std_logic_vector(15 downto 0);
signal cache_history: std_logic;
begin
is_jump <= cache_data(18);
jump_stage <= cache_data(21 downto 19);
pc_addr <= cache_prediction(15 downto 0);
pc_hit <= cache_data(17);
pc_history <= cache_data(16);
-- Process to determine state of jump signals
process(op_code, new_pcval, is_jump, jump_stage, reset, pc_hit, pc_addr)
variable njump: std_logic;
variable njump_address: std_logic_vector(15 downto 0);
begin
  njump := '0';
  njump_address := (others => '0');
  if (is_jump = '0' or jump_stage /= "011") then
    -- This jump doesn't belong here / is not even a jump
    njump := '0';
    njump_address := (others => '0');
  else
    if (op_code = "0011" ) then
      -- LHI instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = new_pcval) then
        -- Successful jump
        njump := '0';
        njump_address := (others => '0');
      else
        njump := '1';
        njump_address := new_pcval;
      end if;
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

cache_values(17) <= cache_write;
cache_values(16) <= cache_history;
cache_values(15 downto 0) <= cache_addr;

-- Process to determine state of cache
process(op_code, cache_data, new_pcval, is_jump, jump_stage, pc_addr, pc_hit, pc_history, reset)
variable ncache_write: std_logic;
variable ncache_addr: std_logic_vector(15 downto 0);
variable ncache_history: std_logic;
begin
  ncache_history := '0';
  ncache_addr := (others => '0');
  ncache_history := '0';
  if (is_jump = '0' or jump_stage /= "011") then
    -- This jump doesn't belong here / is not even a jump
    ncache_write := '0';
    ncache_addr := (others => '0');
    ncache_history := '0';
  else
    if (op_code = "0011") then
      -- ADD/NDU/ADI instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = new_pcval) then
      -- This is the case of a successful hit
        ncache_write := '0';
        ncache_addr := (others => '0');
        ncache_history := '0';
      else
        ncache_write := '1';
        ncache_addr := new_pcval;
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

----------------------------------------------Execute Stage----------------------------------------------------------
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
    flag_condition: in std_logic_vector(1 downto 0);
    reset: in std_logic;
    jump: out std_logic;
    jump_address: out std_logic_vector(15 downto 0);
    cache_values: out std_logic_vector(17 downto 0)
  );
end entity;

architecture Struct of JumpExecuteStage is
signal is_jump: std_logic;
signal jump_stage: std_logic_vector(2 downto 0);
signal pc_hit: std_logic;
signal pc_addr: std_logic_vector(15 downto 0);
signal pc_history: std_logic;
signal cache_write: std_logic;
signal cache_addr: std_logic_vector(15 downto 0);
signal cache_history: std_logic;
begin
is_jump <= cache_data(18);
jump_stage <= cache_data(21 downto 19);
pc_addr <= cache_prediction(15 downto 0);
pc_hit <= cache_data(17);
pc_history <= cache_data(16);
-- Process to determine state of jump signals
process(op_code, alu_output, is_jump, jump_stage, carry_logic, flag_condition, reset, pc_hit, pc_addr)
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
    if (((op_code = "0000" or op_code = "0010") and carry_logic = "00") or op_code = "0001" ) then
      -- ADD / NDU / ADI instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = alu_output) then
        -- Successful jump
        njump := '0';
        njump_address := (others => '0');
      else
        njump := '1';
        njump_address := alu_output;
      end if;
    elsif ((op_code = "0000" or op_code = "0010") and carry_logic = "10") then
      -- ADC / NDC instruction with writeA3 = R7
      if (flag_condition(0) = '1') then
        --checks if carry is high
        if (pc_hit = '1' and pc_addr = alu_output) then
          -- Successful jump
          njump := '0';
          njump_address := (others => '0');
        else
          njump := '1';
          njump_address := alu_output;
        end if;
      else
        njump := '0';
        njump_address := (others => '0'); 
      end if;
    elsif ((op_code = "0000" or op_code = "0010") and carry_logic = "01") then
      -- ADZ / NDZ instruction with writeA3 = R7
      if (flag_condition(1) = '1') then
        --checks if zero is high
        if (pc_hit = '1' and pc_addr = alu_output) then
          -- Successful jump
          njump := '0';
          njump_address := (others => '0');
        else
          njump := '1';
          njump_address := alu_output;
        end if;
      else
        njump := '0';
        njump_address := (others => '0'); 
      end if;
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

cache_values(17) <= cache_write;
cache_values(16) <= cache_history;
cache_values(15 downto 0) <= cache_addr;

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
    if (((op_code = "0000" or op_code = "0010") and carry_logic = "00") or op_code = "0001") then
      -- ADD/NDU/ADI instruction with writeA3 = R7
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
    elsif ((op_code = "0000" or op_code = "0010") and carry_logic = "10") then
      -- ADC/NDC instruction with writeA3 = R7
      if (flag_condition(0) = '1') then
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
    elsif ((op_code = "0000" or op_code = "0010") and carry_logic = "01") then
      -- ADC/NDC instruction with writeA3 = R7
      if (flag_condition(1) = '1') then
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

----------------------------------------------MemStage----------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;

entity JumpMemStage is
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
end entity;

architecture Struct of JumpMemStage is
signal is_jump: std_logic;
signal jump_stage: std_logic_vector(2 downto 0);
signal pc_hit: std_logic;
signal pc_addr: std_logic_vector(15 downto 0);
signal pc_history: std_logic;
signal cache_write: std_logic;
signal cache_addr: std_logic_vector(15 downto 0);
signal cache_history: std_logic;
begin
is_jump <= cache_data(18);
jump_stage <= cache_data(21 downto 19);
pc_addr <= cache_prediction(15 downto 0);
pc_hit <= cache_data(17);
pc_history <= cache_data(16);
-- Process to determine state of jump signals
process(op_code, memread, is_jump, jump_stage, reset, pc_hit, pc_addr)
variable njump: std_logic;
variable njump_address: std_logic_vector(15 downto 0);
begin
  njump := '0';
  njump_address := (others => '0');
  if (is_jump = '0' or jump_stage /= "101") then
    -- This jump doesn't belong here / is not even a jump
    njump := '0';
    njump_address := (others => '0');
  else
    if (op_code = "0100" ) then
      -- LW instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = memread) then
        -- Successful jump
        njump := '0';
        njump_address := (others => '0');
      else
        njump := '1';
        njump_address := memread;
      end if;
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

cache_values(17) <= cache_write;
cache_values(16) <= cache_history;
cache_values(15 downto 0) <= cache_addr;

-- Process to determine state of cache
process(op_code, cache_data, memread, is_jump, jump_stage, pc_addr, pc_hit, pc_history, reset)
variable ncache_write: std_logic;
variable ncache_addr: std_logic_vector(15 downto 0);
variable ncache_history: std_logic;
begin
  ncache_history := '0';
  ncache_addr := (others => '0');
  ncache_history := '0';
  if (is_jump = '0' or jump_stage /= "101") then
    -- This jump doesn't belong here / is not even a jump
    ncache_write := '0';
    ncache_addr := (others => '0');
    ncache_history := '0';
  else
    if (op_code = "0100") then
      -- LW instruction with writeA3 = R7
      if (pc_hit = '1' and pc_addr = memread) then
      -- This is the case of a successful hit
        ncache_write := '0';
        ncache_addr := (others => '0');
        ncache_history := '0';
      else
        ncache_write := '1';
        ncache_addr := memread;
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