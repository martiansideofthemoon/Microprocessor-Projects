library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity PCForwarding is
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
end entity PCForwarding;

architecture Struct of PCForwarding is
begin
process(pc_stage5, pc_stage4, pc_stage3, pc_stage5_flag, pc_stage4_flag, pc_stage3_flag, reset)
  variable npc_forwarding_out: std_logic_vector(15 downto 0) := (others => '0');
  variable npc_forwarding: std_logic := '0';
  variable nkill1: std_logic := '0';
  variable nkill2: std_logic := '0';
  variable nkill3: std_logic := '0';
  variable nkill4: std_logic := '0';
begin
  if(pc_stage5_flag = '1') then
    npc_forwarding_out := pc_stage5;
    npc_forwarding := '1';
    nkill4 := '1';
    nkill3 := '1';
    nkill2 := '1';
    nkill1 := '1';
  elsif (pc_stage4_flag = '1') then
    npc_forwarding_out := pc_stage4;
    npc_forwarding := '1';
    nkill4 := '0';
    nkill3 := '1';
    nkill2 := '1';
    nkill1 := '1';
  elsif (pc_stage3_flag = '1') then
    npc_forwarding_out := pc_stage3;
    npc_forwarding := '1';
    nkill4 := '0';
    nkill3 := '0';
    nkill2 := '1';
    nkill1 := '1';
  else
    npc_forwarding_out := (others => '0');
    npc_forwarding := '0';
    nkill4 := '0';
    nkill3 := '0';
    nkill2 := '0';
    nkill1 := '0';
  end if;

  if (reset = '1') then
    pc_forwarding_out <= (others => '0');
    pc_forwarding <= '0';
    kill4 <= '0';
    kill3 <= '0';
    kill2 <= '0';
    kill1 <= '0';
  else
    pc_forwarding_out <= npc_forwarding_out;
    pc_forwarding <= npc_forwarding;
    kill4 <= nkill4;
    kill3 <= nkill3;
    kill2 <= nkill2;
    kill1 <= nkill1;
  end if;
end process;
end Struct;