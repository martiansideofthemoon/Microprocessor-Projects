library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;

entity Cache is
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
end Cache;

architecture Struct of Cache is
  signal comparisons: std_logic_vector(15 downto 0) := (others => '0');
  signal write_comparisons: std_logic_vector(15 downto 0) := (others => '0');
  signal free_slots: std_logic_vector(15 downto 0) := (others => '0');
  signal first_free_slot: integer := 0;
  signal active_write_entry: integer := 0;
  signal active_read_entry: integer := 0;
  signal last_used: std_logic_vector(3 downto 0) := "0000";
  signal write_index: std_logic_vector(3 downto 0) := "0000";
  signal write_value: std_logic_vector(33 downto 0) := (others => '0');
  -- Cache array is a fully associative cache of size 34
  -- Is Branch bit --> 33
  -- History bit --> 32
  -- Value of the taken jump address --> 31 downto 16
  -- Value of the PC --> 15 downto 0
  type CacheArray is array(15 downto 0) of std_logic_vector(33 downto 0);
  signal cache_array: CacheArray := (others => (others => '0'));

begin
-- Checking whether target_pc matches or not. Along with match, checks if cache has been filled
  GenerateLabel: for i in cache_array'range generate
    comparisons(i) <= '1' when cache_array(i)(15 downto 0) = target_pc and
                               cache_array(i)(33) = '1' else '0';
  end generate;

-- Process acts like a priority encoder of comparisons
process(comparisons, reset)
  variable nactive_read_entry: integer := 0;
begin
  nactive_read_entry := 0;
  if comparisons(0) = '1' then
    nactive_read_entry := 0;
  elsif comparisons(1) = '1' then
    nactive_read_entry := 1;
  elsif comparisons(2) = '1' then
    nactive_read_entry := 2;
  elsif comparisons(3) = '1' then
    nactive_read_entry := 3;
  elsif comparisons(4) = '1' then
    nactive_read_entry := 4;
  elsif comparisons(5) = '1' then
    nactive_read_entry := 5;
  elsif comparisons(6) = '1' then
    nactive_read_entry := 6;
  elsif comparisons(7) = '1' then
    nactive_read_entry := 7;
  elsif comparisons(8) = '1' then
    nactive_read_entry := 8;
  elsif comparisons(9) = '1' then
    nactive_read_entry := 9;
  elsif comparisons(10) = '1' then
    nactive_read_entry := 10;
  elsif comparisons(11) = '1' then
    nactive_read_entry := 11;
  elsif comparisons(12) = '1' then
    nactive_read_entry := 12;
  elsif comparisons(13) = '1' then
    nactive_read_entry := 13;
  elsif comparisons(14) = '1' then
    nactive_read_entry := 14;
  elsif comparisons(15) = '1' then
    nactive_read_entry := 15;
  else
    nactive_read_entry := 0;
  end if;
  if reset = '1' then
    active_read_entry <= 0;
  else
    active_read_entry <= nactive_read_entry;
  end if;
end process;

-- Process to decide HIT / MISS and to return HIT value if any
process (comparisons, last_used, cache_array, clk, active_read_entry, reset) is
  variable nhit: std_logic := '0';
  variable nhistory: std_logic;
  variable nlast_used: std_logic_vector(3 downto 0) := "0000";
  variable ntarget: std_logic_vector(15 downto 0) := (others => '0');
begin
  nhit := '0';
  nhistory := '0';
  ntarget := (others => '0');
  nlast_used := last_used;
  if (comparisons = "0000000000000000") then
    -- MISS case
    nhit := '0';
    nhistory := '0';
    ntarget := (others => '0');
    nlast_used := last_used;
  else
    nhit := '1';
    nlast_used := std_logic_vector(to_unsigned(active_read_entry, 4));
    nhistory := cache_array(active_read_entry)(32);
    ntarget := cache_array(active_read_entry)(31 downto 16);
  end if;

  if (reset = '1') then
    target_hit <= '0';
    target_history <= '0';
    target_address <= (others => '0');
  else
    target_hit <= nhit;
    target_history <= nhistory;
    target_address <= ntarget;
  end if;

  if (clk = '1' and clk'event) then
    if (reset = '1') then
      last_used <= "0000";
    else
      last_used <= nlast_used;
    end if;
  end if;

end process;

-- Checking whether write_pc matches or not. Along with match, that PC must be an branch
GenerateLabel2: for i in cache_array'range generate
  write_comparisons(i) <= '1' when cache_array(i)(15 downto 0) = write_pc and
                                   cache_array(i)(33) = '1' else '0';
end generate;

GenerateLabel3: for i in cache_array'range generate
  free_slots(i) <= '1' when cache_array(i)(33) = '0' else '0';
end generate;

-- Process acts like a priority encoder of write_comparisons
process(write_comparisons, reset)
  variable nactive_write_entry: integer := 0;
begin
  nactive_write_entry := 0;
  if write_comparisons(0) = '1' then
    nactive_write_entry := 0;
  elsif write_comparisons(1) = '1' then
    nactive_write_entry := 1;
  elsif write_comparisons(2) = '1' then
    nactive_write_entry := 2;
  elsif write_comparisons(3) = '1' then
    nactive_write_entry := 3;
  elsif write_comparisons(4) = '1' then
    nactive_write_entry := 4;
  elsif write_comparisons(5) = '1' then
    nactive_write_entry := 5;
  elsif write_comparisons(6) = '1' then
    nactive_write_entry := 6;
  elsif write_comparisons(7) = '1' then
    nactive_write_entry := 7;
  elsif write_comparisons(8) = '1' then
    nactive_write_entry := 8;
  elsif write_comparisons(9) = '1' then
    nactive_write_entry := 9;
  elsif write_comparisons(10) = '1' then
    nactive_write_entry := 10;
  elsif write_comparisons(11) = '1' then
    nactive_write_entry := 11;
  elsif write_comparisons(12) = '1' then
    nactive_write_entry := 12;
  elsif write_comparisons(13) = '1' then
    nactive_write_entry := 13;
  elsif write_comparisons(14) = '1' then
    nactive_write_entry := 14;
  elsif write_comparisons(15) = '1' then
    nactive_write_entry := 15;
  else
    nactive_write_entry := 0;
  end if;
  if reset = '1' then
    active_write_entry <= 0;
  else
    active_write_entry <= nactive_write_entry;
  end if;
end process;

-- Process acts like a priority encoder
process(free_slots, reset)
  variable lowest_free: integer := 0;
begin
  lowest_free := 0;
  if free_slots(0) = '1' then
    lowest_free := 0;
  elsif free_slots(1) = '1' then
    lowest_free := 1;
  elsif free_slots(2) = '1' then
    lowest_free := 2;
  elsif free_slots(3) = '1' then
    lowest_free := 3;
  elsif free_slots(4) = '1' then
    lowest_free := 4;
  elsif free_slots(5) = '1' then
    lowest_free := 5;
  elsif free_slots(6) = '1' then
    lowest_free := 6;
  elsif free_slots(7) = '1' then
    lowest_free := 7;
  elsif free_slots(8) = '1' then
    lowest_free := 8;
  elsif free_slots(9) = '1' then
    lowest_free := 9;
  elsif free_slots(10) = '1' then
    lowest_free := 10;
  elsif free_slots(11) = '1' then
    lowest_free := 11;
  elsif free_slots(12) = '1' then
    lowest_free := 12;
  elsif free_slots(13) = '1' then
    lowest_free := 13;
  elsif free_slots(14) = '1' then
    lowest_free := 14;
  elsif free_slots(15) = '1' then
    lowest_free := 15;
  else
    lowest_free := 0;
  end if;
  if reset = '1' then
    first_free_slot <= 0;
  else
    first_free_slot <= lowest_free;
  end if;
end process;

-- Process to determine write_index
process(write_comparisons, free_slots, first_free_slot, active_write_entry, last_used)
begin
  if (write_comparisons = "0000000000000000") then
    -- In this case, PC is not already in cache
    -- We need to find first free slot / use NMRU
    if (free_slots = "0000000000000000") then
      -- In this case, the entire cache is full
      -- Hence use NMRU policy. Use MRU + 1
      write_index <= std_logic_vector(unsigned(last_used) + 1);
    else
      -- In this case, some slot is empty
      -- Use priority encoder to find first free slot
      write_index <= std_logic_vector(to_unsigned(first_free_slot, 4));
    end if;
  else
    -- In this case, PC already exists in cache
    -- We need to find corresponding index
    write_index <= std_logic_vector(to_unsigned(active_write_entry, 4));
  end if;
end process;

write_value(15 downto 0) <= write_pc;
write_value(31 downto 16) <= write_address;
write_value(32) <= write_history;
write_value(33) <= '1';

process(write_index, clk, write_value, cache_write)
begin
  if (clk = '1' and clk'event) then
    if (cache_write = '1') then
      cache_array(to_integer(unsigned(write_index))) <= write_value;
    end if;
  end if;
end process;

end Struct;