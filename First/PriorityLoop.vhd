library std;
library ieee;
use ieee.std_logic_1164.all;


entity PriorityEncoder is
  port (
    din: in std_logic_vector(7 downto 0);
    dout: out std_logic_vector(2 downto 0)
  );
end entity PriorityEncoder;

architecture Struct of PriorityEncoder is
begin
  process(din)
  begin
    if (din(0) = '1') then
      dout <= "000";
    elsif (din(1) = '1') then
      dout <= "001";
    elsif (din(2) = '1') then
      dout <= "010";
    elsif (din(3) = '1') then
      dout <= "011";
    elsif (din(4) = '1') then
      dout <= "100";
    elsif (din(5) = '1') then
      dout <= "101";
    elsif (din(6) = '1') then
      dout <= "110";
    elsif (din(7) = '1') then
      dout <= "111";
    end if;
  end process;
end Struct;



library ieee;
use ieee.std_logic_1164.all;
entity Demux is
  port (
    din: in std_logic_vector(2 downto 0);
    dout: out std_logic_vector(7 downto 0)
  );
end entity Demux;

architecture Struct of Demux is
begin
  process(din)
  begin
    if (din = "000") then
      dout <= "00000001";
    elsif (din = "001") then
      dout <= "00000010";
    elsif (din = "010") then
      dout <= "00000100";
    elsif (din = "011") then
      dout <= "00001000";
    elsif (din = "100") then
      dout <= "00010000";
    elsif (din = "101") then
      dout <= "00100000";
    elsif (din = "110") then
      dout <= "01000000";
    elsif (din = "111") then
      dout <= "10000000";
    end if;
  end process;
end Struct;



library ieee;
use ieee.std_logic_1164.all;
library work;
use work.ProcessorComponents.all;
entity PriorityLoop is
  port (
    input: in std_logic_vector(7 downto 0);
    priority_select, clock: in std_logic;
    output: out std_logic_vector(2 downto 0)
  );
end entity PriorityLoop;

architecture Struct of PriorityLoop is
  signal feedback: std_logic_vector(7 downto 0);
  signal priority_out: std_logic_vector(2 downto 0);
  signal priority_in: std_logic_vector(7 downto 0);
  signal input_reg_in: std_logic_vector(7 downto 0);
  signal demux_out: std_logic_vector(7 downto 0);
begin
  input_reg_in <= input when priority_select = '1' else feedback;
  input_reg: DataRegister
             generic map (data_width => 8)
             port map (
                Din => input_reg_in,
                Dout => priority_in,
                enable => '1',
                clk => clock
              );
  encoder: PriorityEncoder
           port map (
              din => priority_in,
              dout => priority_out
           );
  output <= priority_out;
  demux1: Demux
         port map (
            din => priority_out,
            dout => demux_out
         );
  feedback <= demux_out xor priority_in;
end Struct;
