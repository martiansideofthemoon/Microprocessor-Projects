library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;
use work.CacheComponent.all;

entity Cache is
  port(
    pc_target: out  std_logic_vector(15 downto 0);
    pc_in: in  std_logic_vector(15 downto 0);
    hit: out std_logic;
    reset: in std_logic;
    cache_write: in std_logic;
    cache_pc: in std_logic_vector(15 downto 0);
    cache_write_data: in std_logic_vector(15 downto 0)
    );
end Cache;

architecture Struct of Cache is
  signal comparator: std_logic_vector(15 downto 0) := (others => '0');
  signal cache_array: CacheArray := INIT_CACHE;
  signal last_index: integer := 0;
begin
-- outside the process so that it happens parallely
  comparator(0) <= '1' when cache_array(0)(31 downto 16) = pc_in else '0';
  comparator(1) <= '1' when cache_array(1)(31 downto 16) = pc_in else '0';
  comparator(2) <= '1' when cache_array(2)(31 downto 16) = pc_in else '0';
  comparator(3) <= '1' when cache_array(3)(31 downto 16) = pc_in else '0';
  comparator(4) <= '1' when cache_array(4)(31 downto 16) = pc_in else '0';
  comparator(5) <= '1' when cache_array(5)(31 downto 16) = pc_in else '0';
  comparator(6) <= '1' when cache_array(6)(31 downto 16) = pc_in else '0';
  comparator(7) <= '1' when cache_array(7)(31 downto 16) = pc_in else '0';
  comparator(8) <= '1' when cache_array(8)(31 downto 16) = pc_in else '0';
  comparator(9) <= '1' when cache_array(9)(31 downto 16) = pc_in else '0';
  comparator(10) <= '1' when cache_array(10)(31 downto 16) = pc_in else '0';
  comparator(11) <= '1' when cache_array(11)(31 downto 16) = pc_in else '0';
  comparator(12) <= '1' when cache_array(12)(31 downto 16) = pc_in else '0';
  comparator(13) <= '1' when cache_array(13)(31 downto 16) = pc_in else '0';
  comparator(14) <= '1' when cache_array(14)(31 downto 16) = pc_in else '0';
  comparator(15) <= '1' when cache_array(15)(31 downto 16) = pc_in else '0';

  process (pc_in) is
  variable nhit: std_logic := '0';
  variable index: integer := 0;
  variable ntarget: std_logic_vector(15 downto 0) := (others => '0');
  begin
    cache_array(0)(32) <= '0';
    cache_array(1)(32) <= '0';
    cache_array(2)(32) <= '0';
    cache_array(3)(32) <= '0';
    cache_array(4)(32) <= '0';
    cache_array(5)(32) <= '0';
    cache_array(6)(32) <= '0';
    cache_array(7)(32) <= '0';
    cache_array(8)(32) <= '0';
    cache_array(9)(32) <= '0';
    cache_array(10)(32) <= '0';
    cache_array(11)(32) <= '0';
    cache_array(12)(32) <= '0';
    cache_array(13)(32) <= '0';
    cache_array(14)(32) <= '0';
    cache_array(15)(32) <= '0';
    if (comparator = "0000000000000000") then
      nhit := '0';
      ntarget := (others => '0');
      cache_array(last_index)(32) <= '1';
    else
      nhit := '1';
      if (comparator(0) = '1') then
        index := 0;
      elsif (comparator(1) = '1') then
        index := 1;
      elsif (comparator(2) = '1') then
        index := 2;
      elsif (comparator(3) = '1') then
        index := 3;
      elsif (comparator(4) = '1') then
        index := 4;
      elsif (comparator(5) = '1') then
        index := 5;
      elsif (comparator(6) = '1') then
        index := 6;
      elsif (comparator(7) = '1') then
        index := 7;
      elsif (comparator(8) = '1') then
        index := 8;
      elsif (comparator(9) = '1') then
        index := 9;
      elsif (comparator(10) = '1') then
        index := 10;
      elsif (comparator(11) = '1') then
        index := 11;
      elsif (comparator(12) = '1') then
        index := 12;
      elsif (comparator(13) = '1') then
        index := 13;
      elsif (comparator(14) = '1') then
        index := 14;
      elsif (comparator(15) = '1') then
        index := 15;
      end if;
      ntarget := cache_array(index)(15 downto 0);
      cache_array(index)(32) <= '1';
      last_index <= index;
   end if;

    if (reset = '1') then
      hit <= '0';
      pc_target <= (others => '0');
    else
      hit <= nhit;
      pc_target <= ntarget;
    end if;
  end process;

  process (cache_write, cache_write_data) is
  variable nhit: std_logic := '0';
  variable index: integer := 0;
  variable ntarget: std_logic_vector(15 downto 0) := (others => '0');
  begin
    if (cache_array(0)(32) = '1') then
      index := 0;
    elsif (cache_array(1)(32) = '1') then
      index := 1;
    elsif (cache_array(2)(32) = '1') then
      index := 2;
    elsif (cache_array(3)(32) = '1') then
      index := 3;
    elsif (cache_array(4)(32) = '1') then
      index := 4;
    elsif (cache_array(5)(32) = '1') then
      index := 5;
    elsif (cache_array(6)(32) = '1') then
      index := 6;
    elsif (cache_array(7)(32) = '1') then
      index := 7;
    elsif (cache_array(8)(32) = '1') then
      index := 8;
    elsif (cache_array(9)(32) = '1') then
      index := 9;
    elsif (cache_array(10)(32) = '1') then
      index := 10;
    elsif (cache_array(11)(32) = '1') then
      index := 11;
    elsif (cache_array(12)(32) = '1') then
      index := 12;
    elsif (cache_array(13)(32) = '1') then
      index := 13;
    elsif (cache_array(14)(32) = '1') then
      index := 14;
    elsif (cache_array(15)(32) = '1') then
      index := 15;
    end if;
    if cache_write = '1' then
      cache_array(index)(32) <= '1';
      cache_array(index)(31 downto 16) <=  cache_pc;
      cache_array(index)(15 downto 0) <= cache_write_data;
    end if;
  end process;

end Struct;