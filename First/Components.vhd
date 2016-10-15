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
    output: out std_logic_vector(2 downto 0)
  );
  end component PriorityLoop;

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


