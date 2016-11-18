library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity FlagForwarding is
  port (
    set_carry5: in std_logic;
    set_zero5: in std_logic;
    carry5: in std_logic;
    zero5: in std_logic;
    set_carry6: in std_logic;
    set_zero6: in std_logic;
    carry6: in std_logic;
    zero6: in std_logic;
    reset: in std_logic;
    carry_forward: out std_logic;
    zero_forward: out std_logic;
    carry_val: out std_logic;
    zero_val: out std_logic
  );
end entity FlagForwarding;

architecture Struct of FlagForwarding is
begin
process(set_carry5, carry5, set_carry6, carry6, reset)
  variable ncarry_forward: std_logic := '0';
  variable ncarry_val: std_logic := '0';
begin

  if (set_carry5 = '1') then
    ncarry_forward := '1';
    ncarry_val := carry5;
  elsif (set_carry6 = '1') then
    ncarry_forward := '1';
    ncarry_val := '0';
  else
    ncarry_forward := '0';
    ncarry_val := '0';
  end if;

  if reset = '1' then
    carry_val <= '0';
    carry_forward <= '0';
  else
    carry_val <= ncarry_val;
    carry_forward <= ncarry_forward;
  end if;
end process;

process(set_zero5, set_zero6, zero5, zero6, reset)
  variable nzero_forward: std_logic := '0';
  variable nzero_val: std_logic := '0';
begin
  if (set_zero5 = '1') then
    nzero_forward := '1';
    nzero_val := zero5;
  elsif (set_zero6 = '1') then
    nzero_forward := '1';
    nzero_val := zero6;
  else
    nzero_forward := '0';
    nzero_val := '0';
  end if;

  if reset = '1' then
    zero_val <= '0';
    zero_forward <= '0';
  else
    zero_val <= nzero_val;
    zero_forward <= nzero_forward;
  end if;
end process;
end Struct;