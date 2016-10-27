library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.ProcessorComponents.all;

entity RegisterFile is
  port(
    dout1        : out std_logic_vector(15 downto 0);
    dout2        : out std_logic_vector(15 downto 0);
    din          : in  std_logic_vector(15 downto 0);
    register_write : in  std_logic;
    readA1       : in  std_logic_vector(2 downto 0);
    readA2       : in  std_logic_vector(2 downto 0);
    writeA3      : in  std_logic_vector(2 downto 0);
    PC_write     : in  std_logic;
    PC_in        : in std_logic_vector(15 downto 0);
    PC_out       : out  std_logic_vector(15 downto 0);
    clk          : in  std_logic;
    zero         : out std_logic;
    external_r0  : out std_logic_vector(15 downto 0);
    external_r1  : out std_logic_vector(15 downto 0);
    external_r2  : out std_logic_vector(15 downto 0);
    external_r3  : out std_logic_vector(15 downto 0);
    external_r4  : out std_logic_vector(15 downto 0);
    external_r5  : out std_logic_vector(15 downto 0);
    external_r6  : out std_logic_vector(15 downto 0)
    );
end RegisterFile;


architecture Struct of RegisterFile is
  type registerFile is array(0 to 7) of std_logic_vector(15 downto 0);
  signal registers: registerFile := (others => (others => '0'));
  signal pc_data_in: std_logic_vector(15 downto 0);
  signal pc_enable: std_logic;
begin
  external_r0 <= registers(0);
  external_r1 <= registers(1);
  external_r2 <= registers(2);
  external_r3 <= registers(3);
  external_r4 <= registers(4);
  external_r5 <= registers(5);
  external_r6 <= registers(6);
  pc_data_in <= PC_in when PC_write = '1' else din;
  pc_enable <= '1' when PC_write = '1' or (writeA3 = "111" and register_write = '1') else '0';
  regFile : process (clk) is
  begin
    if rising_edge(clk) then
      -- Write and bypass
      if register_write = '1' and writeA3 /= "111" then
        registers(to_integer(unsigned(writeA3))) <= din;  -- Write
      end if;
      if pc_enable = '1' then
        registers(7) <= pc_data_in;
      end if;
    end if;
  end process regFile;
        -- Read A and B before bypass
  dout1 <= registers(to_integer(unsigned(readA1)));
  dout2 <= registers(to_integer(unsigned(readA2)));
  PC_out <= registers(7);
  zero <= '1' when din = "0000000000000000" else '0';
end Struct;