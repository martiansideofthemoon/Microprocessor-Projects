library ieee;
use ieee.std_logic_1164.all;
library std;
use std.textio.all;
library work;
use work.ProcessorComponents.all;

entity TestbenchMemory is
end entity;
architecture Behave of TestbenchMemory is
  signal mem_out: std_logic_vector(15 downto 0);
  signal data: std_logic_vector(15 downto 0);
  signal addr : std_logic_vector(15 downto 0) := "0000000000000000";
  signal mem_write: std_logic;
  signal clk: std_logic := '0';
  signal reset: std_logic := '1';

  function to_string(x: string) return string is
      variable ret_val: string(1 to x'length);
      alias lx : string (1 to x'length) is x;
  begin
      ret_val := lx;
      return(ret_val);
  end to_string;

  function to_std_logic_vector(x: bit_vector) return std_logic_vector is
    alias lx: bit_vector(1 to x'length) is x;
    variable ret_var : std_logic_vector(1 to x'length);
  begin
     for I in 1 to x'length loop
        if(lx(I) = '1') then
           ret_var(I) :=  '1';
        else
           ret_var(I) :=  '0';
  end if;
     end loop;
     return(ret_var);
  end to_std_logic_vector;

  function to_std_logic(x: bit) return std_logic is
      variable ret_val: std_logic;
  begin
      if (x = '1') then
        ret_val := '1';
      else
        ret_val := '0';
      end if;
      return(ret_val);
  end to_std_logic;

begin
  clk <= not clk after 5 ns; -- assume 10ns clock.

  -- reset process
  process
  begin
     wait until clk = '1';
     reset <= '0';
     wait;
  end process;

  process
    variable err_flag : boolean := false;
    File INFILE: text open read_mode is "Tracefiles/tracefile_memory.txt";
    FILE OUTFILE: text  open write_mode is "Outputs/output_memory.txt";

    ---------------------------------------------------
    -- edit the next few lines to customize
    variable m_write: bit;
    variable ad: bit_vector (15 downto 0);
    variable din: bit_vector (15 downto 0);
    variable dout: bit_vector (15 downto 0);
    ----------------------------------------------------
    variable INPUT_LINE: Line;
    variable OUTPUT_LINE: Line;
    variable LINE_COUNT: integer := 0;

  begin
    wait until clk = '1';
    mem_write <= '1';
    addr <= "0000000000000000";
    data <= "0000000000000000";

    wait until clk = '1';

    while not endfile(INFILE) loop
      readLine(INFILE, INPUT_LINE);
      read(INPUT_LINE, m_write);
      read(INPUT_LINE, ad);
      read(INPUT_LINE, din);
      LINE_COUNT := LINE_COUNT + 1;
      mem_write <= to_std_logic(m_write);
      addr <= to_std_logic_vector(ad);
      data <= to_std_logic_vector(din);

      wait until clk = '0';

        readLine(INFILE, INPUT_LINE);
        read(INPUT_LINE, dout);
        LINE_COUNT := LINE_COUNT + 1;

        if (mem_out /= to_std_logic_vector(dout)) then
          write(OUTPUT_LINE,to_string("ERROR: in RESULT , line "));
          write(OUTPUT_LINE, LINE_COUNT);
          writeline(OUTFILE, OUTPUT_LINE);
          err_flag := true;
        end if;

    	wait until clk = '1';

    end loop;

    assert (err_flag) report "SUCCESS, all tests passed." severity note;
    assert (not err_flag) report "FAILURE, some tests failed." severity error;

    wait;
  end process;

  dut: Memory
  port map (
    mem_out => mem_out,
    data => data,
    addr => addr,
    mem_write => mem_write,
    clk => clk
  );
end Behave;

