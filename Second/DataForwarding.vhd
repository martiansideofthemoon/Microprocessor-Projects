library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity DataForwarding is
  port (
    input1: in std_logic_vector(2 downto 0);
    input2: in std_logic_vector(2 downto 0);
    alu_out5: in std_logic_vector(15 downto 0);
    op_code: in std_logic_vector(3 downto 0);
    stage5: in std_logic_vector(2 downto 0);
    stage6: in std_logic_vector(2 downto 0);
    alu_out6: in std_logic_vector(15 downto 0);
    ip_forward1: out std_logic;
    ip_forward2: out std_logic;
    ip_forward_data1: out std_logic_vector(15 downto 0);
    ip_forward_data2: out std_logic_vector(15 downto 0);
    reset: in std_logic
  );
end entity DataForwarding;

architecture Struct of DataForwarding is
begin
process(input1, stage5, stage6, alu_out5, alu_out6, reset)
  variable nip_forward1: std_logic := '0';
  variable nip_forward_data1: std_logic_vector(15 downto 0) := (others => '0');
begin

  if (op_code = "0000" or op_code = "0001" or op_code = "0010") then  
    if (input1 = stage5) then
      nip_forward1 := '1';
      nip_forward_data1 := alu_out5;
    elsif (input1 = stage6) then
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
  
  if reset = '1' then
    ip_forward_data1 <= (others => '0');
    ip_forward1 <= '0';
  else
    ip_forward_data1 <= nip_forward_data1;
    ip_forward1 <= nip_forward1;
  end if;
end process;

process(input2, stage5, stage6, alu_out5, alu_out6, reset)
  variable nip_forward2: std_logic := '0';
  variable nip_forward_data2: std_logic_vector(15 downto 0) := (others => '0');
begin

  if (op_code = "0000" or op_code = "0010") then  
    if (input2 = stage5) then
      nip_forward2 := '1';
      nip_forward_data2 := alu_out5;
    elsif (input2 = stage6) then
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
  
  if reset = '1' then
    ip_forward_data2 <= (others => '0');
    ip_forward2 <= '0';
  else
    ip_forward_data2 <= nip_forward_data2;
    ip_forward2 <= nip_forward2;
  end if;
end process;

end Struct;