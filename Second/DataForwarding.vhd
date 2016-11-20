library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity DataForwarding is
  port (
    input1: in std_logic_vector(2 downto 0);
    input2: in std_logic_vector(2 downto 0);
    ip1_frm3: in std_logic_vector(2 downto 0);
    ip2_frm3: in std_logic_vector(2 downto 0);
    alu_out5: in std_logic_vector(15 downto 0);
    op_code4: in std_logic_vector(3 downto 0);
    op_code3: in std_logic_vector(3 downto 0);
    stage5: in std_logic_vector(2 downto 0);
    stage6: in std_logic_vector(2 downto 0);
    alu_out6: in std_logic_vector(15 downto 0);
    reg_write5: in std_logic;
    reg_write6: in std_logic;
    ip_forward1: out std_logic;
    ip_forward2: out std_logic;
    ip_forward_data1: out std_logic_vector(15 downto 0);
    ip_forward_data2: out std_logic_vector(15 downto 0);
    forward3_1: out std_logic;
    forward3_2: out std_logic;
    forward3_data1: out std_logic_vector(15 downto 0);
    forward3_data2: out std_logic_vector(15 downto 0);
    reset: in std_logic
  );
end entity DataForwarding;

architecture Struct of DataForwarding is
begin
process(input1, stage5, stage6, alu_out5, alu_out6, reset)
  variable nip_forward1: std_logic := '0';
  variable nip_forward_data1: std_logic_vector(15 downto 0) := (others => '0');
  variable nforward3_1: std_logic := '0';
  variable nforward3_data1: std_logic_vector(15 downto 0) := (others => '0');
begin

  if (op_code4 = "0000" or op_code4 = "0001" or op_code4 = "0010") then  
    if (input1 = stage5 and reg_write5 = '1') then 
      nip_forward1 := '1';
      nip_forward_data1 := alu_out5;
    elsif (input1 = stage6 and reg_write6 = '1') then
      nip_forward1 := '1';
      nip_forward_data1 := alu_out6;
    else
      nip_forward1 := '0';
      nip_forward_data1 := (others => '0');
    end if;
  else 
    nip_forward1 := '0';
    nip_forward_data1 := (others => '0');
  end if;

  if (op_code3 = "0000" or op_code3 = "0001" or op_code3 = "0010") then  
    if (ip1_frm3 = stage6 and reg_write6 = '1') then 
      nforward3_1 := '1';
      nforward3_data1 := alu_out6;
    else
      nforward3_1 := '0';
      nforward3_data1 := (others => '0');
    end if;
  else 
    nforward3_1 := '0';
    nforward3_data1 := (others => '0');
  end if;
  
  if reset = '1' then
    ip_forward_data1 <= (others => '0');
    ip_forward1 <= '0';
    forward3_1 <= '0';
    forward3_data1 <= (others => '0');
  else
    ip_forward_data1 <= nip_forward_data1;
    ip_forward1 <= nip_forward1;
    forward3_1 <= nforward3_1;
    forward3_data1 <= nforward3_data1;
  end if;
end process;

process(input2, stage5, stage6, alu_out5, alu_out6, reset)
  variable nip_forward2: std_logic := '0';
  variable nip_forward_data2: std_logic_vector(15 downto 0) := (others => '0');
  variable nforward3_2: std_logic := '0';
  variable nforward3_data2: std_logic_vector(15 downto 0) := (others => '0');
begin

  if (op_code4 = "0000" or op_code4 = "0010") then  
    if (input2 = stage5 and reg_write5 = '1') then
      nip_forward2 := '1';
      nip_forward_data2 := alu_out5;
    elsif (input2 = stage6 and reg_write6 = '1') then
      nip_forward2 := '1';
      nip_forward_data2 := alu_out6;
    else
      nip_forward2 := '0';
      nip_forward_data2 := (others => '0');
    end if;
  else 
    nip_forward2 := '0';
    nip_forward_data2 := (others => '0');
  end if;

  if (op_code3 = "0000" or op_code3 = "0010") then  
    if (ip2_frm3 = stage6 and reg_write6 = '1') then 
      nforward3_2 := '1';
      nforward3_data2 := alu_out6;
    else
      nforward3_2 := '0';
      nforward3_data2 := (others => '0');
    end if;
  else 
    nforward3_2 := '0';
    nforward3_data2 := (others => '0');
  end if;
  
  if reset = '1' then
    ip_forward_data2 <= (others => '0');
    ip_forward2 <= '0';
    forward3_2 <= '0';
    forward3_data2 <= (others => '0');
  else
    ip_forward_data2 <= nip_forward_data2;
    ip_forward2 <= nip_forward2;
    forward3_2 <= nforward3_2;
    forward3_data2 <= nforward3_data2;
  end if;
end process;

end Struct;