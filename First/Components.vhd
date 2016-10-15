library std;
library ieee;
use ieee.std_logic_1164.all;

package ProcessorComponents is

  component ClockDivider is
  port (
    clk, reset: in std_logic;
    clk_slow: out std_logic
  );
  end component;
  component ClockDividerControl is
  port (
    T0, T1: out std_logic;
    S: in std_logic;
    clk, reset: in std_logic;
    clk_slow: out std_logic
  );
  end component;
  component ClockDividerData is
  port (
    T0, T1: in std_logic;
    S: out std_logic;
    clk, reset: in std_logic
  );
  end component;

  component DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable: in std_logic);
  end component DataRegister;

  component PriorityEncoder is
  port (
    din: in std_logic_vector(7 downto 0);
    dout: out std_logic_vector(2 downto 0)
  );
  end component PriorityEncoder;

  component Demux is
  port (
    din: in std_logic_vector(2 downto 0);
    dout: out std_logic_vector(7 downto 0)
  );
  end component Demux;

  component PriorityLoop is
  port (
    input: in std_logic_vector(7 downto 0);
    priority_select, clock: in std_logic;
    input_zero: out std_logic;
    output: out std_logic_vector(2 downto 0)
  );
  end component PriorityLoop;

  component SignExtender9 is
  port (
    input: in std_logic_vector(8 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component SignExtender9;

  component SignExtender6 is
  port (
    input: in std_logic_vector(5 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component SignExtender6;

  component LSBZeroPad is
  port (
    input: in std_logic_vector(9 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component LSBZeroPad;

  component LeftShift is
  port (
    input: in std_logic_vector(15 downto 0);
    output: out std_logic_vector(15 downto 0)
  );
  end component LeftShift;

  component ActiveDecoder is
  port (
    instruction: in std_logic_vector(1 downto 0);
    carry: in std_logic;
    zero: in std_logic;
    active: out std_logic
  );
  end component ActiveDecoder;

 component RegisterFile is
  port (
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
    clk          : in  std_logic
  );
  end component RegisterFile;

end package;

library ieee;
use ieee.std_logic_1164.all;
entity DataRegister is
  generic (data_width:integer);
  port (Din: in std_logic_vector(data_width-1 downto 0);
        Dout: out std_logic_vector(data_width-1 downto 0);
        clk, enable: in std_logic);
end entity;
architecture Behave of DataRegister is
begin
  process(clk)
  begin
    if(clk'event and (clk  = '1')) then
      if(enable = '1') then
        Dout <= Din;
      end if;
    end if;
  end process;
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity SignExtender9 is
port (
  input: in std_logic_vector(8 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity SignExtender9;
architecture Behave of SignExtender9 is
begin
output(8 downto 0) <= input(8 downto 0);
output(9) <= input(8);
output(10) <= input(8);
output(11) <= input(8);
output(12) <= input(8);
output(13) <= input(8);
output(14) <= input(8);
output(15) <= input(8);
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity SignExtender6 is
port (
  input: in std_logic_vector(8 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity SignExtender6;
architecture Behave of SignExtender6 is
begin
output(5 downto 0) <= input(5 downto 0);
output(6) <= input(5);
output(7) <= input(5);
output(8) <= input(5);
output(9) <= input(5);
output(10) <= input(5);
output(11) <= input(5);
output(12) <= input(5);
output(13) <= input(5);
output(14) <= input(5);
output(15) <= input(5);
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity LSBZeroPad is
port (
  input: in std_logic_vector(8 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity LSBZeroPad;
architecture Behave of LSBZeroPad is
begin
output(15 downto 7) <= input(8 downto 0);
output(6 downto 0) <= "0000000";
end Behave;

library ieee;
use ieee.std_logic_1164.all;
entity LeftShift is
port (
  input: in std_logic_vector(15 downto 0);
  output: out std_logic_vector(15 downto 0)
);
end entity LeftShift;
architecture Behave of LeftShift is
begin
output(15 downto 1) <= input(14 downto 0);
output(0) <= '0';
end Behave;
